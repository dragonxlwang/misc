let s:fbvim_py_path = glob('~/misc/scripts/fbvim.py')
if exists('g:fbvim_py_path_override')
  let s:fbvim_py_path = g:fbvim_py_path_override
endif

python3 << ENDPYTHON
# import imp
from importlib.machinery import SourceFileLoader
import vim
import sys
import os

__fbvim_path = vim.eval('s:fbvim_py_path')
sys.path.append(os.path.dirname(__fbvim_path))

# fbvim = imp.load_source('fbvim', __fbvim_path)

fbvim = SourceFileLoader('fbvim', __fbvim_path).load_module()

ENDPYTHON

" take the current vim state and save it to a session file named by the current
" repo (e.g. www) and the current branch
command! -nargs=? FBVimSaveSession call <SID>FBVimSaveSession(<f-args>)

" look at the current repo (.e.g www) and current branch, and restore the last
" saved session if it exists.
command! -nargs=? FBVimLoadSession call <SID>FBVimLoadSession(<f-args>)

" run a query against the mural_server for tags (only works in www)
command! FBVimMuralSearch python3 fbvim.tags_mural()
" same as above, but use the current word under the cursor
command! FBVimMuralSearchCurrentWord python3 fbvim.tags_mural(True)
" go "back" when navigating tags (same as built-in Ctrl-T)
command! FBVimPopTagStack python3 fbvim.pop_tag_stack()

" run a big grep query on the current repo (automatically maps www -> tbgs
" etc.)
command! FBVimBigGrep python3 fbvim.big_grep()

" search for file in the current repo
command! FBVimFilenameSearch python3 fbvim.repo_file_typeahead()

" search against hack server
command! FBVimHackSearch python3 fbvim.tags_hack()

" search against hack server using current word
command! FBVimHackSearchCurrentWord python3 fbvim.tags_hack(True)


function! <SID>FBVimSaveSession(...)
  if a:0 > 0
    let g:fbvim_session_name=a:1
  endif
  set winminheight=1 winminwidth=1
  python3 fbvim.save_session()
endfunction


function! <SID>FBVimLoadSession(...)
  if a:0 > 0
    let g:fbvim_session_name=a:1
    echo g:fbvim_session_name
  endif
  python3 fbvim.load_session()
endfunction
