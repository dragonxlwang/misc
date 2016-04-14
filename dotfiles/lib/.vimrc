" =============================- General Config -===============================
set nocompatible                " Sse Vim settings, rather than Vi
set autoread                    " Reload files changed outside vim
set hidden                      " Buffers can exist in the background
set ttyfast                     " Optimize for fast terminal connections
set ttimeout                    " Set timeout on key codes
set timeoutlen=500              " How long it wait for mapped commands
set ttimeoutlen=100             " Faster timeout for escape key and others
set history=1000                " Store lots of :cmdline history
set undolevels=1000             " Use many muchos levels of undo
set tabpagemax=50               " Max 50 tabs
set mouse=a                     " Enable mouse
set sessionoptions-=options     " Session don't remember global options
set splitbelow                  " Open new split panes to right and bottom
set splitright                  " Open new split panes to bottom
set diffopt+=vertical           " Always use vertical diffs
set backspace=indent,eol,start  " Allow backspace in insert mode
set whichwrap+=<,>,h,l,[,]      " Move across lines
set pastetoggle=<F2>            " No indent on paste
set nrformats-=octal            " Set number format for C-A, C-X
" ================================- Display -===================================
set number                      " Line numbers are good
set ruler                       " Bottom right corner of the status line
set wrap                        " Wrap lines visually
set textwidth=80                " Maximum line text width
set colorcolumn=80              " Highlight column at 80 char
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
if substitute(system('hostname -s'), "\n", "", "") =~ 'timan'
  let g:osName = 'Timan'       " Platform
else
  let g:osName = substitute(system('uname'), "\n", "", "")
end
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
autocmd BufReadPost *
      \ if line("'\"") > 1 && line("'\"") <= line("$") |
      \   exe "normal! g`\"" |
      \ endif
" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <c-u> <c-g>u<c-u>
inoremap <c-w> <c-g>u<c-w>

" =============================- Vundle Config -================================
if !empty(glob('~/.vim/bundle/Vundle.vim'))
  source ~/misc/dotfiles/lib/.vimrc.bundles
endif

" ==============================- Color Themes -================================
if !empty(globpath(&rtp, 'colors/molokai.vim'))
  colorscheme molokai
endif

" ==========================- Keymap: Save & Close -============================
" Fast saves
noremap <leader>w :w!<cr>
" Close window with buffer (:clo for window only)
noremap <leader>q :bd<CR>
" Close all the buffers
map <leader>ba :1,1000 bd!<cr>
" Open last edited file
nnoremap <Leader><Leader> <C-^>
" Sudo write
cmap w!! w !sudo tee > /dev/null %
" Switch WD to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>:pwd<cr>
" Change pwd to current dir
command! CdPwd :cd %:p:h
" Automatically change directory
"" autocmd BufEnter * silent! lcd %:p:h
" Sync with servers
command! SyncUploadFile call SyncUploadFile()

" =============================- Keymap: Vimrc -================================
" Edit .vimrc
map <leader>v :e ~/.vimrc<CR>
" Reloads it -- making all changes active (have to save first)
map <silent> <leader>V
    \ :source ~/.vimrc<CR>:filetype detect<CR>:exe ":echo 'vimrc reloaded'"<CR>

" ==============================- Keymap: Diff -================================
" ,do: Diff off
nnoremap <Leader>do :diffoff<CR><C-w><C-w>:diffoff<CR>
" ,dd: Diff windows
nnoremap <leader>dd :windo diffthis<CR>
" ,dt: Diff two windows
nnoremap <Leader>dt :diffthis<CR><C-w><C-w>:diffthis<CR>
" ,ds: Diff split another file
nnoremap <Leader>ds :<C-u>diffsplit<Space>
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

" =========================- Keymap: Windows & Tabs -===========================
map <leader>tt :tabnew<cr>
map <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove
" Cycle between buffers
map <leader>k :bnext<cr>
map <leader>j :bprev<cr>
" Cycle between tabs
map <C-w><C-k> :tabn<cr>
map <C-w><C-j> :tabp<cr>
map <C-w><c-l> :tabl<cr>

" ==========================- Keymap: Copy & Paste -============================
if g:osName == 'Darwin' || g:osName == 'Timan'
  " Add some Mac specific bindings
  " so we use external commands instead to avoid recompiling vim
  " swap vim default register and clipboard
  nnoremap <silent> <leader>x
        \ :let @a=@" \|
        \ let @"=system("pbpaste") \|
        \ let res=system("pbcopy", @a)<CR>
  vnoremap <silent> <leader>y
        \ :<CR>:let @a=@" \|
        \ execute "normal! vgvy" \|
        \ let res=system("pbcopy", @") \| let @"=@a<CR>
  nnoremap <silent> <leader>y :.w !pbcopy<CR><CR>
  noremap <silent> <leader>p :r !pbpaste<CR><CR>
else
  " this works only if vim is compiled with +clipboard or +xterm_clipboard
  nnoremap <silent> <leader>x :let @a=@" \| let @"=@+ \| let @+=@a<CR>
  set clipboard=unnamed
  nnoremap <silent> <leader>y :.w !ssh mac_mini pbcopy<CR>
  vnoremap <silent> <leader>y
        \ :<CR>:let @a=@" \|
        \ execute "normal! vgvy" \|
        \ let res=system("ssh mac_mini pbcopy", @") \| let @"=@a<CR>
endif
" Toggle paste mode on and off
map <leader>pp :setlocal paste!<cr>:echoe HasPaste()<cr>
" Y: from the cursor to the end of line
nnoremap Y y$

" ==============================- Keymap: Misc -================================
" Text wrap: Hard wrap paragraph text (similar to TextMate Ctrl+Q)
nnoremap <leader>tw gqip
nnoremap <leader>nw :set nowrap<CR>
" Git checkout current file
nnoremap <Leader>o :!git checkout %<CR><CR>
" Tags
nnoremap <Leader>] <C-]>
nnoremap <Leader>: :<C-u>tab<Space>stj<Space><C-R>=expand('<cword>')<CR><CR>
nnoremap <Leader>[ <C-o>
" Spell checking
map <leader>ss :setlocal spell!<cr>
map <leader>sn ]s
map <leader>sp [s
map <leader>sa zg
map <leader>s? z=
" Remove the Windows ^M - when the encodings gets messed up
noremap <Leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

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
