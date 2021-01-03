" ==========================- Facebook -=======================================
" source $LOCAL_ADMIN_SCRIPTS/master.vimrc
" =============================- General Config -===============================
set nocompatible                " Sse Vim settings, rather than Vi
set autoread                    " Reload files changed outside vim
set hidden                      " Buffers can exist in the background
set ttyfast                     " Optimize for fast terminal connections
set ttimeout                    " Set timeout on key codes
set timeoutlen=500              " How long it wait for mapped commands
set ttimeoutlen=100             " Faster timeout for escape key and others
set history=8000                " Store lots of :cmdline history
set undolevels=1000             " Use many muchos levels of undo
set tabpagemax=50               " Max 50 tabs
set mouse=a                     " Enable mouse
set ttymouse=sgr                " Enable mouse dragging. default: xterm2/xterm
set sessionoptions-=options     " Session don't remember global options
set splitbelow                  " Open new split panes to right and bottom
set splitright                  " Open new split panes to bottom
set diffopt+=vertical           " Always use vertical diffs
set backspace=indent,eol,start  " Allow backspace in insert mode
set whichwrap+=<,>,h,l,[,]      " Move across lines
set pastetoggle=<F2>            " No indent on paste
set nrformats-=octal            " Set number format for C-A, C-X
set synmaxcol=128               " No syntax color lines that are too long
set noequalalways               " No resize after splitting or closing a window
set cpoptions+=>                " a line break is inserted before the appended text
"================================- Display -===================================
set cursorline                  " Highlight line of cursor
set cursorlineopt=number        " Highlight cursor line number only
set number relativenumber       " Hybrid relative line numbers are good
set ruler                       " Bottom right corner of the status line
set wrap                        " Wrap lines visually
set textwidth=88                " Maximum line text width
set colorcolumn=88              " Highlight column at 80 char
set title                       " Change the terminal's title
set showcmd                     " Show incomplete cmds down the bottom
set showmode                    " Show current mode down the bottom
set visualbell                  " No sounds
set laststatus=2                " Always display the status line
" ==============================- Indentation -=================================
set autoindent                  " Indent for new lines
set smartindent                 " Indent by context
set expandtab                   " Use space instead of tabs
set smarttab                    " Dynamic change what to insert
set shiftwidth=2                " How many columns to indent by <<, >>
set softtabstop=2               " How many columns when hitting a tab
set tabstop=2                   " How many columns a tab counts for display
" =================================- Folds -====================================
set foldmethod=indent           " Fold based on indent
set foldnestmax=3               " Deepest fold is 3 levels
set foldlevelstart=99           " Dont fold by default (in lieu of nofoldenable)
" ===============================- Completion -=================================
set wildmode=list:longest,full  " List all matches including current
set wildmenu                    " Enable ctrl-n and ctrl-p to scroll
set wildchar=<TAB>              " Show possible completions
set wildignore=*.o,*.pyc,*~     " Stuff to ignore when tab completing
set wildignore+=*/.git/**,*/.DS_Store
set wildignore+=*.png,*.jpg,*.gif
set completeopt=longest,menuone " Show menu but insert longest common substring
" ===============================- Scrolling -==================================
set scrolloff=8                 " Start scrolling when 8 lines away vertically
set sidescrolloff=15            " Same as above, for horizontal scrolling
set sidescroll=3                " Scroll sideways 3 characters at a time
" =================================- Search -===================================
set incsearch                   " Find the next match as we type the search
set hlsearch                    " Highlight searches by default
set ignorecase                  " Ignore case when searching...
set smartcase                   " ...unless we type a capital
set showmatch                   " Set show matching parenthesis
set magic                       " For regular expressions turn magic on
" ==================================- Misc -====================================
syntax on                       " Turn on syntax highlighting
let mapleader=","               " Change leader to a comma
let g:mapleader = ","           " Global leader to a comma
let g:osName = substitute(system('uname'), "\n", "", "")
if &encoding ==# 'latin1' && has('gui_running')
  set encoding=utf-8            " Encoding
endif
if has('path_extra')            " Ctags path
  setglobal tags-=./tags tags-=./tags; tags^=./tags;
endif
if !empty(&viminfo)             " Store global vars
  set viminfo^=!
endif
if &t_Co == 8 && $TERM !~# '^linux\|^Eterm'
  set t_Co=16                   " Allow bright colors without forcing bold.
endif
if v:version > 703 || v:version == 703 && has("patch541")
  set formatoptions+=j          " Delete comment char when joining lines
endif
if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
  runtime! macros/matchit.vim   " Load matchit.vim
endif
" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
" Also don't do it when the mark is in the first line, that is the default
" position when opening a file.
augroup JumpLastCursorPosAutoGroup
  autocmd!
  autocmd BufReadPost *
        \ if line("'\"") > 1 && line("'\"") <= line("$") |
        \   exe "normal! g`\"" |
        \ endif
augroup END
" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <c-u> <c-g>u<c-u>
inoremap <c-w> <c-g>u<c-w>
augroup SwitchLineNumberAutoGroup
  autocmd!
  "InsertLeave,
  autocmd BufEnter,FocusGained,WinEnter * if &nu | set rnu   | endif
  "InsertEnter
  autocmd BufLeave,FocusLost,WinLeave   * if &nu | set nornu | endif
augroup END
" set rnu
" augroup SwitchLineNumberAutoGroup
"   autocmd!
"   au WinLeave * set nornu
"   au WinEnter * set rnu
" augroup END
" " Highlight the current line only in current window
" set cul
" hi clear CursorLine
" augroup CursorLineClear
"     autocmd! ColorScheme * hi clear CursorLine
"   augroup END
" augroup CurrentWindowBackgroundHighlight
"     autocmd!
"     autocmd WinEnter * set cul
"     autocmd WinLeave * set nocul
" augroup END

" =============================- Vundle Config -================================
if !empty(glob('~/.vim/bundle/Vundle.vim'))
  source ~/misc/dotfiles/lib/.vimrc.bundles
endif

" ==================================- Tex -=====================================
let g:tex_flavor = "latex"
augroup TexAutoGroup
  autocmd!
  autocmd FileType tex setlocal spell
augroup END
let g:tex_conceal = ""          " no translation math symbols
" ===========================- FileType Specific -==============================
augroup PythonAutoGroup
  autocmd!
  autocmd FileType python setlocal shiftwidth=4 softtabstop=4 tabstop=4
augroup END
augroup ClangAutoGroup
  autocmd!
  autocmd FileType cpp,c setlocal fo+=t
augroup END
augroup VimAutoGroup
  autocmd!
  autocmd FileType vim setlocal fo+=t
augroup END
augroup FbFormatAutoGroup
  autocmd!
  autocmd BufNewFile,BufRead *.cinc set filetype=python | set syntax=python
  autocmd BufNewFile,BufRead *.cconf set filetype=python | set syntax=python
  autocmd BufNewFile,BufRead *.mcconf set filetype=python | set syntax=python
  autocmd BufNewFile,BufRead *.thrift-cvalidator set filetype=python | set syntax=python
  autocmd BufNewFile,BufRead *TARGETS set filetype=TARGETS | set syntax=python
  autocmd FileType TARGETS setlocal commentstring=#\ %s
augroup END

" ==========================- Facebook -=======================================
if !empty(glob('~/fbcode/shellconfigs/rc/vim'))
  source ~/fbcode/shellconfigs/rc/vim/biggrep.vim
  set rtp+=~/fbcode/shellconfigs/rc/vim/
  set rtp+=~/fbcode/shellconfigs/rc/vim/after
endif

if g:osName == 'Linux'
  source ~/misc/scripts/fbvim.vim
  cnoreabbrev <expr> fbvim
        \ (getcmdtype() == ':' && getcmdline() =~ '^fbvim$')?
        \ 'NERDTreeClose \| FBVimSaveSession' : 'fbvim'
endif
" if !empty(glob('/usr/local/share/clang/clang-format.py'))
"   augroup FBClangAutoGroup
"     autocmd!
"     autocmd FileType cpp,c
"           \ nnoremap <buffer> <leader>w
"           \ :exe ":pyf /usr/local/share/clang/clang-format.py" \| :w!<CR>
"   augroup END
" endif

" ==============================- Color Themes -================================
if !empty(globpath(&rtp, 'colors/molokai.vim'))
  colorscheme molokai
endif

" ==========================- Keymap: Save & Close -============================
" Close window with buffer (:clo for window only)
noremap <leader>q :bd<CR>
" Close all the buffers
map <leader>ba :1,1000 bd!<cr>
" Open last edited file
nnoremap <Leader><Leader> <C-^>
" Sudo write
command! SW :w !sudo tee > /dev/null %
command! WW :call mkdir(expand("%:p:h"), "p") | :w
" Switch WD to the directory of the open buffer
noremap <leader>cd :cd %:p:h<cr>:pwd<cr>
" Change pwd to current dir
command! CdPwd cd %:p:h
command! LcdPwd lcd %:p:h
" Automatically change directory
"" autocmd BufEnter * silent! lcd %:p:h
" Write ls to ~/.vim/buffers.list
command! Wls call WriteListedFiles()
" Wipe out inactive buffers
command! Wipeout call Wipeout()
" Wipe out and only keep current window
command! Wipeonly only | Wipeout
" Remove all windows of the same buffer and focus
command! -nargs=1 -bang Fbs :call FocusBuffer(<f-args>, "s", <bang>0)
command! -nargs=1 -bang Fbv :call FocusBuffer(<f-args>, "v", <bang>0)
command! -nargs=1 -bang Fb  :call FocusBuffer(<f-args>, "r", <bang>0)
" Sync with servers
command! UpldFile call SyncUploadFile()
command! UpldAll :! ~/misc/scripts/sync.sh <CR>
command! Uf silent call SyncUploadFile() | redraw!
command! Ua silent exec "! ~/misc/scripts/sync.sh" |
      \ silent exec "!echo " | redraw!

" =============================- Keymap: Vimrc -================================
" Edit .vimrc
noremap <leader>v :if g:NERDTree.GetWinNum() == winnr() \| wincmd w \| endif \|
      \:e ~/.vimrc \| vs ~/misc/dotfiles/lib/.vimrc.bundles<CR>

" Reloads it -- making all changes active (have to save first)
noremap <silent> <leader>V
    \ :source ~/.vimrc<CR>:filetype detect<CR>:exe ":echo 'vimrc reloaded'"<CR>

" ==============================- Keymap: Diff -================================
" ,do: Diff off
nnoremap <Leader>do :diffoff<CR><C-w><C-p>:diffoff<CR>
" ,da: Diff all windows
nnoremap <leader>da :windo diffthis<CR>
" ,dt: Diff two windows
nnoremap <Leader>dt :diffthis<CR><C-w><C-p>:diffthis<CR>
" ,dd: diffthis
nnoremap <Leader>dd :diffthis<CR>
" ,ds: Diff split another file
nnoremap <Leader>ds :<C-u>diffsplit<Space>
" ,du: Diff update
nnoremap <leader>du :diffupdate<CR><CR><C-L>
" Diff with original (before save)
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
        \ | wincmd p | diffthis
endif

" =============================- Keymap: Motion -===============================
" Get off my lawn
nnoremap <Left> :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up> :echoe "Use k"<CR>
nnoremap <Down> :echoe "Use j"<CR>
" Exit insert mode without esc, http://vim.wikia.com/wiki/Avoid_the_escape_key
inoremap jk <Esc><Esc>`^
vnoremap ;; <Esc>gV
cnoremap ;; <C-c>
nnoremap ;; <Esc>
onoremap ;; <Esc>
" ,c: replace until next underscore
nnoremap <Leader>c ct_
" ,a: replace until next capital letter
nnoremap <Leader>a c/[A-Z]<CR>
" ,|: go to 80th column
nnoremap <Leader><Bar> 80<Bar>
vnoremap <Leader><Bar> 80<Bar>

" =====================- Keymap: Windows, buffers & Tabs -======================
" tab
noremap <leader>tt :tabnew %<cr>
noremap <leader>tn :tabnext <cr>
noremap <leader>tp :tabprevious <cr>
noremap <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/
noremap <leader>to :tabonly<cr>
noremap <leader>tc :tabclose<cr>
noremap <leader>tm :tabmove
" Cycle between buffers
noremap <leader>k :bnext<cr>
noremap <leader>j :bprev<cr>
noremap <leader>sk :sp \| bnext <cr>
noremap <leader>sj :sp \| bprev <cr>
noremap <leader>vk :vs \| bnext <cr>
noremap <leader>vj :vs \| bprev <cr>
nmap <silent> <C-K> :wincmd k<CR>
nmap <silent> <C-J> :wincmd j<CR>
nmap <silent> <C-H> :wincmd h<CR>
nmap <silent> <C-L> :wincmd l<CR>

" Cycle between tabs
" noremap <C-w><C-k> :tabn<cr>
" noremap <C-w><C-j> :tabp<cr>
" noremap <C-w><c-l> :tabl<cr>
" Resize window to minimal
noremap <C-w>0 :res 0<CR>
noremap <C-w>) :vertical res 0<CR>
" Resize stepsize 5 horizontally and 10 vertically
noremap <C-w>- :resize -5<CR>
noremap <C-w>+ :resize +5<CR>
noremap <C-w>< :vertical resize -10<CR>
noremap <C-w>> :vertical resize +10<CR>
command! Rw vert res 100
" Open buffer vertically split
command! -nargs=1 Vsb vert sb <args>
" window
noremap <silent> <C-w>w :wincmd p<cr>
noremap <silent> <C-w><C-w> :wincmd p<cr>
noremap <silent> <C-w>p :wincmd w<cr>
noremap <silent> <C-w>q :wincmd p \| :wincmd c<cr>
noremap <silent> <C-w>{ :execute "res"  . &lines / 3 * 2<cr>
noremap <silent> <C-w>[ :execute "res"  . &lines / 2<cr>
noremap <silent> <C-w>] :wincmd _<cr>
noremap <silent> <C-w>} :res 0<cr>
noremap <silent> <C-w>\ :execute "vertical res"  . &columns / 2<cr>

noremap <silent> <C-n> :execute "res"  . &lines / 2<cr>
noremap <silent> <C-t> :wincmd _<cr>
noremap <silent> <C-g> :NERDTreeClose \| :execute "vert res" . (&textwidth + 20)<cr>
" in Vim internally, <C-m> and <CR> are the same; to jump in command-line window, i<CR>
noremap <silent> <C-m> :NERDTreeClose \| :100 wincmd h \|
      \ execute "vert res" . &columns / 3 \|
      \ wincmd l \| execute "vert res" . &columns / 3 \| wincmd h<cr>

noremap <silent> <C-w><C-j> :100 wincmd j<cr>
noremap <silent> <C-w><C-h> :100 wincmd h<cr>
noremap <silent> <C-w><C-k> :100 wincmd k<cr>
noremap <silent> <C-w><C-l> :100 wincmd l<cr>
noremap <silent> <C-w>H :NERDTreeClose \| :wincmd H<cr>
" go to files
noremap <C-w>v :vertical wincmd f<CR>

" ==========================- Keymap: Copy & Paste -============================
" if g:osName == 'Darwin'
"   " Add some Mac specific bindings
"   " so we use external commands instead to avoid recompiling vim
"   " swap vim default register and clipboard
"   nnoremap <silent> <leader>x
"         \ :let @a=@" \|
"         \ let @"=system("pbpaste") \|
"         \ let res=system("pbcopy", @a)<CR>
"   vnoremap <silent> <leader>y
"         \ :<CR>:let @a=@" \|
"         \ execute "normal! vgvy" \|
"         \ let res=system("pbcopy", @") \| let @"=@a<CR>
"   " nnoremap <silent> <leader>y :.w !pbcopy<CR><CR>
"   " noremap <silent> <leader>p :r !pbpaste<CR><CR>
" elseif g:osName == 'Linux'
"   " this works only if vim is compiled with +clipboard or +xterm_clipboard
"   nnoremap <silent> <leader>x :let @a=@" \| let @"=@+ \| let @+=@a<CR>
"   set clipboard=unnamed
"   nnoremap <silent> <leader><leader>y :.w !ssh mac_mini pbcopy<CR>
"   vnoremap <silent> <leader><leader>y
"         \ :<CR>:let @a=@" \|
"         \ execute "normal! vgvy" \|
"         \ let res=system("ssh mac_mini pbcopy", @") \| let @"=@a<CR>
" endif

" nnoremap <silent> <leader>y :.w !tmux load-buffer -<CR><CR>
" vnoremap <silent> <leader>y
"       \ :<CR>:let @a=@" \|
"       \ execute "normal! vgvy" \|
"       \ let res=system("tmux load-buffer -", @") \| let @"=@a<CR>
" nnoremap <silent> <leader>y
"       \ :.w !~/misc/scripts/vim_tmux_load_buffer.sh -<CR><CR>
" vnoremap <silent> <leader>y
"       \ :<CR>:let @a=@" \|
"       \ execute "normal! vgvy" \|
"       \ let res=system("~/misc/scripts/vim_tmux_load_buffer.sh -", @") \|
"       \ let @"=@a<CR>
nnoremap <leader>p "0p
nnoremap <leader>y "0y
vnoremap <leader>p "0p
vnoremap <leader>y "0y
command TmuxPaste :read !tmux saveb - | cat | sed 's/\x1b\[[0-9;]*m//g'
nnoremap <leader>lh @='"Qyiwj'<CR>

" Toggle paste mode on and off
noremap <ESC>p :setlocal paste! \| :echoe "paste =" &paste<cr>
noremap Y y$
" " Yankring remap Y to y$
" function! YRRunAfterMaps()
"   nnoremap Y :<C-U>YRYankCount 'y$'<CR>
" endfunction

" ==============================- Keymap: Misc -================================
" Text wrap: Hard wrap paragraph text (similar to TextMate Ctrl+Q)
nnoremap <leader>ttw gggwG``
nnoremap <leader>tw gwip
vnoremap <leader>tw gw
nnoremap <leader>nw :set nowrap<CR>
" Git checkout current file
nnoremap <Leader>o :!git checkout %<CR><CR>
" Tags
nnoremap <Leader>] <C-]>
nnoremap <Leader>: :<C-u>tab<Space>stj<Space><C-R>=expand('<cword>')<CR><CR>
nnoremap <Leader>[ <C-o>
" Spell checking
noremap <ESC>s :setlocal spell! \| echoe 'spell =' &spell<cr>
noremap <leader>sn ]s
noremap <leader>sp [s
" noremap <leader>Sa zg
" noremap <leader>S? z=
" Remove the Windows ^M - when the encodings gets messed up
noremap <Leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm
" Remap ctrl-A to ctrl-C, which is rarely used anyways
noremap <C-a> :echoe
      \ "Use \<C-C\> to increase digits -- tmux has prefix \<C-A\>"<CR>
noremap <C-C> <C-a>
noremap <leader>zc :%foldc<cr>
noremap <leader>zo :%foldo<cr>
noremap zfm :if &foldmethod == 'manual' \| set foldmethod=indent \|
      \ else \| set foldmethod=manual \| endif \|
      \ :echo "foldmethod =" &foldmethod<CR>
" Get full path of file
command! Fp echo expand('%:p')
command! Tp echo expand('%:t')
command! Fpp put expand('%:p')
command! Fpy :let @" = expand('%:p')
command! Tpy :let @" = expand('%:t')
command! T exec "e " . expand('%:p:h') . '/TARGETS'
command! TS exec "sp " . expand('%:p:h') . '/TARGETS'
command! TV exec "vsp " . expand('%:p:h') . '/TARGETS'
nnoremap <ESC>n :call NumberToggle()<cr>
cnoreabbrev <expr> vsf
      \ (getcmdtype() == ':' && getcmdline() =~ '^vsf$')? 'vert sf' : 'vsf'

" ==================================- tex -=====================================
command! Texmake exe "! ~/misc/scripts/tex_make.sh make" | redraw!
command! Texclean exe "! ~/misc/scripts/tex_make.sh clean" | redraw!


" ==================================- fb  -=====================================
command! -nargs=* Duf call FBRepo(0, 0)
command! -nargs=* Dufburl call FBRepo(0, 1)
command! -nargs=* Blamef call FBRepo(1, 0)
command! -nargs=* Blamefburl call FBRepo(1, 1)
set path=.,/usr/include,,
      \/home/xlwang/,
      \/home/xlwang/fbcode,
      \/home/xlwang/fbcode/caffe2,
      \/home/xlwang/fbcode/sigrid,
      \/home/xlwang/fbcode/fblearner,
      \/home/xlwang/fbcode/caffe2,
      \/home/xlwang/fbcode/experimental/xlwang,
      \/home/xlwang/fbcode/search,
      \/home/xlwang/fbcode/unicorn,
      \/home/xlwang/fbcode/nlp_tools,
      \/home/xlwang/configerator/source,
      \/home/xlwang/fbcode/dataswarm-pipelines,
      \/home/xlwang/www

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! FBRepo(blame, fburl)
  let l:path = resolve(expand('%:p'))
  let l:header = 'https://www.internalfb.com/intern/diffusion/'
  let l:master = 'browse/master/'
  let l:line = line('.')
  if a:blame == 1
    let l:blame = '&blame=1'
  else
    let l:blame = ''
  endif
  if stridx(l:path, 'fbsource/') != -1
    let l:f = substitute(l:path, '.*/fbsource/', '', '')
    let l:url = l:header . 'FBS/' . l:master . l:f . '?lines=' . l:line . l:blame
  elseif stridx(l:path, 'configerator/') != -1
    let l:f = substitute(l:path, '.*/configerator/', '', '')
    let l:url = l:header . 'CF/' . l:master . l:f . '?lines=' . l:line
  elseif stridx(l:path, 'www-hg/') != -1 || stridx(l:path, 'www/') != -1
    let l:f = substitute(l:path, '.*/www/', '', '')
    let l:f = substitute(l:f, '.*/www-hg/', '', '')
    let l:url = l:header . 'WWW/' . l:master . l:f . '?lines=' . l:line . l:blame
  elseif stridx(l:path, 'configerator-dsi/') != -1
    let l:f = substitute(l:path, '.*/configerator-dsi/', '', '')
    let l:url = l:header . 'CFDSI/' . l:master . l:f . '?lines=' . l:line . l:blame
  else
    echohl ErrorMsg | echo 'unknown FB repo' | echohl None
    return
  endif
  if a:fburl == 1
    echo substitute(system('fburl "' . l:url . '" 2> /dev/null'), "\n", "", "")
  else
    echo l:url
  endif
endfunction

function! HasPaste()
  if &paste
    return 'PASTE MODE  '
  en
  return ''
endfunction

" Sync with server: eshion/vim-sync
function! SyncGetExe()
  if '.sync' == expand('%')
    return
  endif
  let l:exe_path = expand('%:p:h')
  let l:exe_file = l:exe_path . '/.sync'
  let l:found_exe = ''
  if filereadable(l:exe_file)
    let l:found_exe = l:exe_file
  else
    while !filereadable(l:exe_file)
      let slashindex = strridx(l:exe_path, '/')
      if slashindex >= 0
        let l:exe_path = l:exe_path[0:slashindex]
        let l:exe_file = l:exe_path . '.sync'
        let l:exe_path = l:exe_path[0:slashindex-1]
        if filereadable(l:exe_file)
          let l:found_exe = l:exe_file
          break
        endif
        if slashindex == 0 && !filereadable(l:exe_file)
          break
        endif
      else
        break
      endif
    endwhile
  endif
  return l:found_exe
endfunction
function! SyncUploadFile()
  let exe = SyncGetExe()
  if !empty(exe)
    let l:current_file_path = expand('%:p')
    let cmd = printf("%s %s", exe, l:current_file_path)
    execute '!' . cmd
  endif
endfunction

function! WriteListedFiles()
  let l:exe_path = getcwd()
  let l:exe_file = l:exe_path . '/buffers.list'
  let l:found_exe = ''
  if filereadable(l:exe_file)
    let l:found_exe = l:exe_file
  else
    while !filereadable(l:exe_file)
      let slashindex = strridx(l:exe_path, '/')
      if slashindex >= 0
        let l:exe_path = l:exe_path[0:slashindex]
        let l:exe_file = l:exe_path . 'buffers.list'
        let l:exe_path = l:exe_path[0:slashindex-1]
        if filereadable(l:exe_file)
          let l:found_exe = l:exe_file
          break
        endif
        if slashindex == 0 && !filereadable(l:exe_file)
          break
        endif
      else
        break
      endif
    endwhile
  endif
  if empty(l:found_exe)
    let l:found_exe = expand('~/.vim/buffers.list')
  endif
  echohl Keyword
  echo l:found_exe
  echohl None
  execute 'redir! >' . l:found_exe
  pwd
  ls
  redir END
endfunction

function! NumberToggle()
  " number -> rnu -> nonumber
  if(&number == 1 && &relativenumber == 0)
    setlocal rnu
    echohl Error
    echo "relative"
    echohl None
  elseif(&number == 1)
    setlocal nornu
    setlocal nonu
    if exists("g:indentLine_loaded")
      IndentLinesDisable
    endif
    echohl Error
    echo "no line number"
    echohl None
  else
    setlocal nu
    if exists("g:indentLine_loaded")
      IndentLinesEnable
    endif
    echohl Error
    echo "line number"
    echohl None
  endif
endfunc

function! Wipeout()
  " list of *all* buffer numbers
  let l:buffers = range(1, bufnr('$'))

  " what tab page are we in?
  let l:currentTab = tabpagenr()
  try
    " go through all tab pages
    let l:tab = 0
    while l:tab < tabpagenr('$')
      let l:tab += 1

      " go through all windows
      let l:win = 0
      while l:win < winnr('$')
        let l:win += 1
        " whatever buffer is in this window in this tab, remove it from
        " l:buffers list
        let l:thisbuf = winbufnr(l:win)
        call remove(l:buffers, index(l:buffers, l:thisbuf))
      endwhile
    endwhile

    " if there are any buffers left, delete them
    if len(l:buffers)
      execute 'bwipeout' join(l:buffers)
    endif
  finally
    " go back to our original tab page
    execute 'tabnext' l:currentTab
  endtry
endfunction

function! FocusBuffer(bn, opt, wipe)
  let l:fp = expand("#" . a:bn . ":p")
  echo l:fp
  if a:wipe
    exec "bw ". a:bn
  else
    exec "bd ". a:bn
  endif
  if a:opt == 'v'
    exec "vs ". l:fp
  elseif a:opt == 's'
    exec "sp ". l:fp
  elseif a:opt == 'r'
    exec "e ". l:fp
  endif
endfunction

function! ReorderBufToEnd(...)
  if a:0 == 0
    let l:bn = bufnr("%")
  else
    let l:bn = a:1
  endif
  let l:fn = expand("#" . l:bn .":p")
  exec "bwipeout" . l:bn
  exec "sp" . l:fn
endfunction

command! PasteFbPyTestPdb call PasteFbcodePyUnittestPdb()
function! PasteFbcodePyUnittestPdb()
  let l:code=readfile(glob('~/misc/scripts/fbcode_py_unittest_pdb.py'))
  call append(line("."), l:code)
endfunction

command! -nargs=? ReorgBuf :call ReorganizeBuffer(<f-args>)
cnoreabbrev <expr> rb
      \ (getcmdtype() == ':' && getcmdline() =~ '^rb$')? 'ReorgBuf' : 'rb'
function! ReorganizeBuffer(...)
  let l:bfs = filter(range(1, bufnr('$')), 'buflisted(v:val)')
  let l:num = len(l:bfs)

  if a:0 == 0
    let l:col = 0
  else
    let l:col = a:1
  endif
  " adaptive adjust
  if l:col == 0
    let l:col = &columns / (&textwidth + 10)
    if l:col > 3
      let l:col = 3
    endif
    if l:col < 1
      let l:col = 1
    endif
  endif
  " adjust if l:col too large
  if l:col > l:num
    let l:col = l:num
  endif

  let l:rem = l:num % l:col
  let l:quo = l:num / l:col

  " n = r + q * col, q > 0
  let l:i = -1
  for c in range(l:col)
    let l:row = l:quo
    if c < l:rem
      let l:row = l:row + 1
    endif
    for r in range(l:row)
      let l:i = l:i + 1
      let l:b = l:bfs[i]
      if c == 0 && r == 0
        exec "sb ". l:b
        only
      elseif r == 0
        exec "vert botright sb ". l:b
        let l:vsz = &columns * (l:col - c) / l:col
        exec "vert res ". l:vsz
      else
        exec "sb ". l:b
        let l:hsz = &lines * (l:row - r) / l:row
        exec "res ". l:hsz
      endif
    endfor
  endfor
endfunction

command! Dedup :call DedupWindows()
cnoreabbrev <expr> dd
      \ (getcmdtype() == ':' && getcmdline() =~ '^dd$')? 'Dedup' : 'dd'
function! DedupWindows()
  let l:i = 1
  while l:i <= winnr('$')
    let l:buf = winbufnr(l:i)
    let l:j = 1
    while l:j < l:i
      if winbufnr(l:j) == l:buf
        exec l:i . 'close'
        let l:i = l:i - 1
        break
      endif
      let l:j = l:j + 1
    endwhile
    let l:i = l:i + 1
  endwhile
endfunction

command! DoublePane :call ResizeVertByScale(2)
cnoreabbrev <expr> dp
      \ (getcmdtype() == ':' && getcmdline() =~ '^dp$')? 'DoublePane' : 'dp'
function! ResizeVertByScale(s)
  exec "vert res". (&textwidth + 10) * a:s
endfunction

function! MakeRoomForLowestPane()
  let l:nr = winnr()
  100 wincmd j
  let l:ln = &lines / 5
  if l:ln < 20
    let l:ln = 20
  endif
  let l:cur = winheight(0)
  if l:cur < l:ln
    exec "res ". l:ln
    exec l:nr . "wincmd w"
  endif
endfunction

if exists("*BigGrep")
  command! FBGW call MakeRoomForLowestPane() | call BigGrep("f", "s", expand("<cword>"))
  command! ZBGW call MakeRoomForLowestPane() | call BigGrep("z", "s", expand("<cword>"))
  command! TBGW call MakeRoomForLowestPane() | call BigGrep("t", "s", expand("<cword>"))
endif
