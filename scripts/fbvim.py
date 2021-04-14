#!/usr/bin/python3

'''
Facebook services integration for vim. For setup instructions, see

https://our.intern.facebook.com/intern/wiki/index.php/KensVimSetup
'''

import vim
import os
import os.path
import time
import re
import subprocess
import posixpath
import json
import threading
import localstate

from fbvimutils import vimfunc, vc

import fbvimtypeahead

if not hasattr(vim, 'bindeval'):
    raise Exception('must use newer vim with python and bindeval support')

# fb specific knowledge
repos = {
    'www': {
        'big_grep_cmd': '/usr/local/bin/tbgs --stripdir',
        'mural_tags_path': '/home/engshare/pfff/TAGS',
        'hg': {
            'default':      "mononoke://mononoke.internal.tfbnw.net/www",
            'default-push': "mononoke://mononoke.internal.tfbnw.net/www",
        },
        'svn': {
            'url': 'svn+ssh://tubbs/svnroot',
            'trunk': 'tfb/trunk/www:refs/remotes/trunk',
        },
    },
    'fbcode': {
        'big_grep_cmd': '/usr/local/bin/fbgs --stripdir',
        'hg': {
            'default':      "mononoke://mononoke.internal.tfbnw.net/fbsource",
            'default-push': "mononoke://mononoke.internal.tfbnw.net/fbsource",
        },
        'git': {
            'origin': 'ssh://fbcode.git.vip.facebook.com/data/gitrepos/fbcode.git',
        },
    },
    'configerator': {
        'big_grep_cmd': '/usr/local/bin/cbgs --stripdir',
        'hg': {
            'default':      "mononoke://mononoke.internal.tfbnw.net/configerator",
            'default-push': "mononoke://mononoke.internal.tfbnw.net/configerator",
        },
    }
}

find_cmd = 'find ./ -type d -name .git -prune -o -type d -name autogen -prune ' + \
         '-o -type d -name .hg -prune ' + \
         '-o -name \'*.sql3\' -prune -o -name \'*.png\' -prune ' + \
         '-o -name \'*.gif\' -prune -o -type f -print'

# Where to store saved sessions on the local machine
vim_sessions_dir = '~/vim-sessions'

# Function which detects current scm from current working directory
def _detect_scm():
    (status, output) = run_cmd('git rev-parse')
    if status == 0:
        return 'git'
    (status, output) = run_cmd('hg root')
    if status == 0:
        return 'hg'

# Function which detects, given current working directory, which facebook
# source repository we're looking at. Return values match up with keys in
# global repos variable.
def _detect_repo():
    scm = _get_current_scm()
    if scm == 'git':
        (status, output) = run_cmd('git config -l')
        lines = output.splitlines()
        gitvars = dict()
        for l in lines:
            (key, val) = l.split('=', 1)
            gitvars.setdefault(key, []).append(val)

        if repos['www']['svn']['url'] in gitvars.get('svn-remote.svn.url', []) and \
           repos['www']['svn']['trunk'] in gitvars.get('svn-remote.svn.fetch', []):
            return 'www'

        if repos['fbcode']['git']['origin'] in gitvars.get('remote.origin.url', []):
            return 'fbcode'
    elif scm == 'hg':
        (status, output) = run_cmd('hg paths')
        lines = output.splitlines()
        hgvars = {}
        for l in lines:
            (key, val) = l.split(' = ')
            hgvars[key] = val
        for repo, spec in repos.items():
            if hgvars.get('default') == spec['hg']['default'] and \
               hgvars.get('default-push') == spec['hg']['default-push']:
                return repo
        return "dev"


def repo_rel_path_to_url(repo, path):
    return os.path.join(_get_current_repo_path(), path)

def run_cmd(cmd):
    return subprocess.getstatusoutput(cmd)

def run_find_cmd(repo):
   cmd = 'cd %s && %s' % (_get_current_repo_path(), find_cmd)
   return run_cmd(cmd)

def run_big_grep_cmd(repo, querystr):
    cmd = '%s %s' % (repos[repo]['big_grep_cmd'], querystr)
    return run_cmd(cmd)

def big_grep():
    repo = _get_current_repo()
    vim.eval('inputsave()');
    querystr = vim.eval('input("biggrep %s query>> ")' % (repo))
    vim.eval('inputrestore()')
    if not querystr:
        return

    out = []
    (retcode, output) = run_big_grep_cmd(repo, querystr)
    outputlines = output.split("\n")
    for line in outputlines:
        parts = line.split(':', 3)
        if (len(parts)) == 4:
            out.extend([{
                'filename': repo_rel_path_to_url(repo, parts[0]),
                'lnum': int(parts[1]),
                'text': parts[3]
            }])
    winnr = vim.bindeval('winnr()')
    vimfunc('setloclist', winnr, out)

    vc('lopen')


def local_state():
    return localstate.local_state()


class QuerySimple:
    def __init__(self, query):
        self.query = query

        query_raw_parts = query.split(' ')
        if len(query_raw_parts) == 1:
            query_word = query_raw_parts[0].lower()
            self.query_test = lambda x: query_word in x.lower()
        else:
            query_pattern = '.*'.join([re.escape(s) for s in query_raw_parts])
            queryre = re.compile(query_pattern, re.I)
            self.query_test = queryre.search

    def score(self, entry):
        val, extra, i, score = entry
        if self.query_test(val):
            return (val, extra, i, len(val))
        return None

class QueryWordSplit:
    def __init__(self, query):
        self.query = query
        self.query_parts = re.split('[/:\-_ ]', query.lower())
        self.val_re = re.compile('[/:\-_]')

    def score(self, entry):
        val, extra, i, score = entry
        val_parts = self.val_re.split(val.lower())
        score = 0
        found = 0
        for qp in self.query_parts:
            for vp in val_parts:
                offset = vp.find(qp)
                if offset != -1:
                    score += offset
                    break
            else:
                # qp doesn't exist in any vp, no match
                return None
        return (val, extra, i, score)


def match_and_sort(data, query, cache, force=False):
    if not query:
        return []

    if not force and len(query) <= 3:
        return []

    if cache.has_key(query):
        return cache[query]

    if query:
        q = QuerySimple(query)
        if cache.has_key(query[:-1]):
            prev = cache[query[:-1]]
            res = [x for x in [q.score(y) for y in prev] if x]
        else:
            res = [x for x in [q.score((data[i][0], data[i][1], i, 0)) for i in xrange(len(data))] if x]

        res.sort(lambda a,b: cmp(a[3], b[3]))

        cache[query] = res
        return res
    else:
        return data



def repo_file_typeahead():
    repo = _get_current_repo()
    cache_key = repo + '_file_list'
    (status, output) = localstate.cache(cache_key, lambda: run_find_cmd(repo))
    file_list = [(os.path.normpath(x), None) for x in output.split('\n')]

    def repo_file_selected(repo, selection):
        relpath, extra, index, score = selection
        url = repo_rel_path_to_url(repo, relpath)
        push_loc_tag_stack()
        vc('edit ' + url)

    typeahead = fbvimtypeahead.Typeahead(
        lambda query, cache, force: match_and_sort(file_list, query, cache, force),
        lambda selection: repo_file_selected(repo, selection),
        'Search ' + repo + ' file name'
    )
    typeahead.run()


# Launch and cache a subprocess reference. If key doesn't exist, or points to a
# process that has exited, call createfunc to launch another one and cache the
# result.
def _get_subprocess(key, createfunc):
    p_cache = local_state().setdefault('proc_cache', {})
    proc = p_cache.get(key)
    if not proc or proc.poll() != None:
        proc = createfunc()
        p_cache[key] = proc
    return proc

def _mural_lambda(tags_path):
    return lambda: subprocess.Popen(
        _get_mural_command() % (tags_path),
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        shell=True,
        stderr=subprocess.PIPE)

def _get_mural_subprocess():
    repo = _get_current_repo()
    tags_remote_path = repos.get(repo, {}).get('mural_tags_path')
    if not tags_remote_path:
        return
    return _get_subprocess('mural', _mural_lambda(tags_remote_path))

# Returns a command template for starting up the mural server, that contains
# one %s where the filename where be substituted.
def _get_mural_command():
    cmd = '/mnt/vol/engshare/admin/scripts/mural_server %s'
    if vim.eval("exists('g:fbvim_mural_cmd_override')") == "1":
        cmd = vim.eval('g:fbvim_mural_cmd_override')
    return cmd

# tag search where we use the mural_server available on dev servers
def tags_mural(use_current_word=False):
    repo = _get_current_repo()
    if repo != 'www':
        print("mural not supported for non www")
        return

    def mural_search(query, cache, force):
        if not query:
            return []
        if not force and len(query) < 2:
            return []

        if cache.has_key(query):
            return cache[query]

        tags_remote_path = repos[repo].get('mural_tags_path')
        if not tags_remote_path:
            return
        mural_remote_process = \
            _get_subprocess('mural', _mural_lambda(tags_remote_path))

        mural_remote_process.stdin.write(query + '\n')
        res = []
        x = mural_remote_process.stdout.readline()
        while x[:4] != 'DONE':
            xparts = x.split('\t')
            res.append((
                xparts[1],
                xparts[2],
                (xparts[2], xparts[3]),
                None
            ))
            x = mural_remote_process.stdout.readline()
        cache[query] = res
        return res

    def mural_selected(selection):
        tagname, extra, context, score = selection
        (relpath, lineno) = context
        url = repo_rel_path_to_url('www', relpath)
        push_loc_tag_stack()
        vc('edit ' + url)
        vc(str(lineno))

    search_word = ''
    if use_current_word:
        search_word = vim.eval('expand("<cword>")')

    typeahead = fbvimtypeahead.Typeahead(
        mural_search,
        mural_selected,
        'mural tags search',
    )
    typeahead.run()


def tags_hack(use_current_word=False):
    repo = _get_current_repo()
    if repo != 'www':
        print("hack search not supported for non www")
        return

    def hack_search(query, cache, force):
        if not query:
            return []

        if cache.has_key(query):
            return cache[query]


        hack_command = 'hh --json --search'

        output_raw = subprocess.getoutput('%s "%s"' % (hack_command, query))
        results = json.loads(output_raw)

        res = []
        for r in results:
          res.append((
            r['name'],
            r['desc'],
            r,
            None
          ))

        cache[query] = res
        return res

    def hack_search_selected(selection):
        tagname, extra, context, score = selection
        url = context['filename']
        lineno = context['line']
        push_loc_tag_stack()
        vc('edit ' + url)
        vc(str(lineno))

    search_word = ''
    if use_current_word:
        search_word = vim.eval('expand("<cword>")')

    typeahead = fbvimtypeahead.Typeahead(
        hack_search,
        hack_search_selected,
        'search hack'
    )
    typeahead.run()

# figure out the scm from the working directory
def _get_current_scm():
    scm = local_state().get('current_scm')
    if not scm:
        scm = _detect_scm()
        if scm:
            local_state()['current_scm'] = scm
    return scm


# figure out the repo from the working directory
def _get_current_repo():
    repo = local_state().get('current_repo')
    if not repo:
        repo = _detect_repo()
        if repo:
            local_state()['current_repo'] = repo
    return repo

def _get_current_repo_path():
    scm = _get_current_scm()
    if scm == 'git':
        (status, output) = run_cmd('git rev-parse --show-toplevel')
        if status == 0:
            return output
    elif scm == 'hg':
        (status, output) = run_cmd('hg root')
        if status == 0:
            return output


def _get_repo_branch():
    repo_path = _get_current_repo_path()
    scm = _get_current_scm()
    if scm == 'git':
        cmd = 'cd "%s" && git branch 2> /dev/null' % (repo_path)
        (status, output) = run_cmd(cmd)
        lines = output.splitlines()
        for li in lines:
            m = re.match('^\* (.*)', li)
            if m:
                branch = m.group(1)
                break
        return branch
    elif scm == 'hg':
        cmd = 'cd "%s" && hg bookmark 2> /dev/null' % (repo_path)
        (status, output) = run_cmd(cmd)
        lines = output.splitlines()
        for li in lines:
            m = re.match('^ \* (.*) .*', li)
            if m:
                return m.group(1).strip()


def init_session_branch():
    session_branch = local_state().get('session_branch')
    repo = _get_current_repo()
    if not session_branch and repo:
        session_branch = _get_repo_branch()
        local_state()['session_branch'] = session_branch

def get_session_branch():
    return local_state().get('session_branch')

def save_session():
    repo = _get_current_repo()
    branch = get_session_branch()
    if not branch:
        print("no branch for repo %s was loaded, pulling filesystem..."
              % (repo))
        branch = _get_repo_branch()

    branch_session_file = os.path.join(vim_sessions_dir, '%s-%s.vim' % (repo, branch))
    session_save_cmd = ':mksession! ' + branch_session_file
    vim.command(session_save_cmd)
    print("Saved session to %s" % branch_session_file)
    vim.command(':qall')

def load_session():
    repo = _get_current_repo()
    session_branch = get_session_branch()
    branch = _get_repo_branch()

    if session_branch != branch:
        print('Session branch (%s) and remote branch (%s) do not match. '
              'You should start with a fresh session'
              % (session_branch, branch))

    branch_session_file = os.path.join(
        vim_sessions_dir, '%s-%s.vim' % (repo, branch))
    cmd = 'source ' + branch_session_file
    vc(cmd)

def xhp_tag_select():
    line = vim.current.line
    (row, col) = vim.current.window.cursor
    front_part = re.match('(?:.*\s)?[</:]+([a-zA-Z\-:]*)$',
                          line[:col]).groups()[0]
    back_part = re.match('^([a-zA-Z\-:]*)(?:\s.*)?', line[col:]).groups()[0]
    tag = front_part + back_part
    print(tag)
    vim.command('tj ' + tag)

tag_stack = []
def push_loc_tag_stack():
    global tag_stack
    bufnum = vim.current.buffer.number
    bufline = vim.bindeval('line(".")')
    tag_stack.append((bufnum, bufline))

def pop_tag_stack():
    global tag_stack
    if len(tag_stack):
        (bufnum, bufline) = tag_stack.pop()
        vc('b %s' % (bufnum))
        vc(str(bufline))

init_session_branch()

# startup the mural subprocess now so that we don't wait later when we need it
_get_mural_subprocess()
