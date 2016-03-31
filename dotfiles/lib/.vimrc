" ================ General Config ====================
set nocompatible                "Sse Vim settings, rather than Vi
set number                      "Line numbers are good
set backspace=indent,eol,start  "Allow backspace in insert mode
set history=1000                "Store lots of :cmdline history
set undolevels=1000             "Use many muchos levels of undo
set title                       "Change the terminal's title
set ruler                       "Bottom right corner of the status line
set showcmd                     "Show incomplete cmds down the bottom
set showmode                    "Show current mode down the bottom
set visualbell                  "No sounds
set autoread                    "Reload files changed outside vim
set laststatus=2                "Always display the status line
set hidden                      "Buffers can exist in the background
set nowrap                      "Do not wrap lines visually
set textwidth=80                "Maximum line text width
set ttyfast                     "Optimize for fast terminal connections
set wildchar=<TAB>              "Show possible completions
set pastetoggle=<F2>            "No indent on paste
set whichwrap+=<,>,h,l,[,]      "Automatically wrap left and right
set splitbelow                  "Open new split panes to right and bottom
set splitright                  "Open new split panes to bottom
set diffopt+=vertical           "Always use vertical diffs
set ttimeout                    "Set timeout on key codes
set timeoutlen=500              "How long it wait for mapped commands
set ttimeoutlen=100             "Faster timeout for escape key and others
set colorcolumn=80              "Highlight column at 80 char
set mouse=a                     "Enable mouse
set nrformats-=octal            "Set number format for C-A, C-X
set tabpagemax=50               "Max 50 tabs
set sessionoptions-=options     "Session don't remember global options
syntax on                       "Turn on syntax highlighting

let g:osName = substitute(system('uname'), "\n", "", "")
" overwrite settings for timan linux to be the same as mac
if substitute(system('hostname -s'), "\n", "", "") =~ 'timan'
  let g:osName = 'Darwin'
end
let mapleader=","               "Change leader to a comma
let g:mapleader = ","           "Global leader to a comma

if &encoding ==# 'latin1' && has('gui_running')         " encoding
  set encoding=utf-8
endif
if has('path_extra')                                    " ctags path
  setglobal tags-=./tags tags-=./tags; tags^=./tags;
endif
if !empty(&viminfo)                                     " store global vars
  set viminfo^=!
endif
" Allow color schemes to do bright colors without forcing bold.
if &t_Co == 8 && $TERM !~# '^linux\|^Eterm'
  set t_Co=16
endif
" Delete comment character when joining commented lines
if v:version > 703 || v:version == 703 && has("patch541")
  set formatoptions+=j
endif
" Load matchit.vim, but only if the user hasn't installed a newer version.
if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
  runtime! macros/matchit.vim
endif

" =========== Vim Sensible (not used) ================
" set complete-=i
" set display+=lastline
" if &listchars ==# 'eol:$'
"   set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
" endif
" if &shell =~# 'fish$'
"   set shell=/bin/bash
" endif

" ================ Vundle Config =====================
source ~/misc/dotfiles/lib/.vimrc.bundles

" ================ Color Themes ======================
" "set t_ut=
" "colorscheme lucario jellybeans atom-dark-256 ansi_blows lucius monokai
" "LuciusBlackHighContrast
colorscheme vividchalk
highlight Search guibg=#ffff00 guifg=#000000 gui=none
      \ ctermbg=226 ctermfg=016 cterm=none
highlight ColorColumn ctermbg=235 guibg=#2c2d27
highlight LineNr ctermfg=033 ctermbg=234 guifg=#0087ff guibg=#1c1c1c
highlight Pmenu ctermfg=051 ctermbg=235 guifg=#00ffff guibg=#2c2d27
highlight PmenuSel ctermfg=015 ctermbg=008 guifg=#ffffff guibg=#808080
highlight Folded term=standout ctermfg=202 ctermbg=017
      \ guifg=#ff5f00 guibg=#00005f

" ================ Indentation =======================
set autoindent
set smartindent
set smarttab
set shiftwidth=2
set softtabstop=2
set tabstop=2
set expandtab

" ================ Folds =============================
set foldmethod=indent   "Fold based on indent
set foldnestmax=3       "Deepest fold is 3 levels
set nofoldenable        "Dont fold by default

" ================ Completion ========================
set wildmode=list:longest,full
set wildmenu                    "Enable ctrl-n and ctrl-p to scroll thru matche
set wildignore=*.o,*.obj,*~     "Stuff to ignore when tab completing
set wildignore+=*vim/backups*
set wildignore+=*sass-cache*
set wildignore+=*DS_Store*
set wildignore+=vendor/rails/**
set wildignore+=vendor/cache/**
set wildignore+=*.gem
set wildignore+=log/**
set wildignore+=tmp/**
set wildignore+=*.pyc
set wildignore+=*.png,*.jpg,*.gif
set completeopt=longest,menuone
" inoremap <tab> <c-r>=InsertTabWrapper ("forward")<CR>
" inoremap <s-tab> <c-r>=InsertTabWrapper ("backward")<CR>
" inoremap <expr> j ((pumvisible())?("\<C-n>"):("j"))
" inoremap <expr> k ((pumvisible())?("\<C-p>"):("k"))

" ================ Scrolling =========================
set scrolloff=8         "Start scrolling when we're 8 lines away from margins
set sidescrolloff=15    "Same as above, for horizontal scrolling
set sidescroll=3        "Scroll sideways 3 characters at a time

" ================ Search ============================
set incsearch           "Find the next match as we type the search
set hlsearch            "Highlight searches by default
set ignorecase          "Ignore case when searching...
set smartcase           "...unless we type a capital
set showmatch           "Set show matching parenthesis
set magic               "For regular expressions turn magic on
" Visual mode pressing * or # searches for the current selection
vnoremap <silent> * :<C-u>call VisualSelection('')<CR>/<C-R>=@/<CR><CR>
vnoremap <silent> # :<C-u>call VisualSelection('')<CR>?<C-R>=@/<CR><CR>
" Use <C-L> to clear the highlighting of :set hlsearch.
if maparg('<C-L>', 'n') ==# ''
  nnoremap <silent> <C-L>
        \ :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>
endif
" Clear search history
nnoremap <space> :noh<CR><ESC>

" ================ Misc ==============================
" Get off my lawn
nnoremap <Left> :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up> :echoe "Use k"<CR>
nnoremap <Down> :echoe "Use j"<CR>
" Exit insert mode by typing jk
" http://vim.wikia.com/wiki/Avoid_the_escape_key
inoremap jk <ESC>`^
vnoremap ;; <Esc>gV
cnoremap ;; <C-c>
nnoremap ;; <Esc>
onoremap ;; <Esc>
" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <c-u> <c-g>u<c-u>
inoremap <c-w> <c-g>u<c-w>
" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
" Also don't do it when the mark is in the first line, that is the default
" position when opening a file.
autocmd BufReadPost *
      \ if line("'\"") > 1 && line("'\"") <= line("$") |
      \   exe "normal! g`\"" |
      \ endif
" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
        \ | wincmd p | diffthis
endif
" sudo write: w!! to write a file as sudo
cmap w!! w !sudo tee > /dev/null %

" ================ Leader  ===========================
" ,w Fast saves
noremap <leader>w :w!<cr>
" ,q Close window
noremap <leader>q :clo<CR>
" ,, open previously edited file
nnoremap <Leader><Leader> <C-^>

" ,c replace until next underscore
nnoremap <Leader>c ct_
" ,a replace until next capital letter
nnoremap <Leader>a c/[A-Z]<CR>

" ,| go to 80th column
nnoremap <Leader><Bar> 80<Bar>
vnoremap <Leader><Bar> 80<Bar>

" text wrap: Hard wrap paragraph text (similar to TextMate Ctrl+Q)
nnoremap <leader>tw gqip
nnoremap <leader>nw :set nowrap<CR>

" Open current buffer in a new split
noremap <leader>s :vsplit<cr>
noremap <leader>i :split<cr>

" ,do diff off
nnoremap <Leader>do :diffoff<CR><C-w><C-w>:diffoff<CR>
" ,dt diff this
nnoremap <Leader>dt :diffthis<CR><C-w><C-w>:diffthis<CR>
" ,ds Diff split
nnoremap <Leader>ds :<C-u>diffsplit<Space>
" ,dd Diff current files in split view
nnoremap <leader>dd :windo diffthis<CR>

" ,o git checkout current file
nnoremap <Leader>o :!git checkout %<CR><CR>

",v brings up my .vimrc
" map <leader>v :sp ~/.vimrc<CR><C-W>_
map <leader>v :e ~/.vimrc<CR>
",V reloads it -- making all changes active (have to save first)
map <silent> <leader>V
    \ :source ~/.vimrc<CR>:filetype detect<CR>:exe ":echo 'vimrc reloaded'"<CR>

"  Tags
nnoremap <Leader>] <C-]>
nnoremap <Leader>: :<C-u>tab<Space>stj<Space><C-R>=expand('<cword>')<CR><CR>
nnoremap <Leader>[ <C-o>

" =>  tabs, buffers and path
""""""""""""""""""""""""
" Close all the buffers
map <leader>ba :1,1000 bd!<cr>
" Useful mappings for managing tabs
map <leader>tt :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove
" Opens a new tab with the current buffer's path
map <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/
" Switch CWD to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>:pwd<cr>

" Cycle between buffers
map <leader>k :bnext<cr>
map <leader>j :bprev<cr>
" Cycle between tabs
map <C-w><C-k> :tabn<cr>
map <C-w><C-j> :tabp<cr>
map <C-w><c-l> :tabl<cr>

" => vimgrep searching and cope displaying
""""""""""""""""""""""""
" When you press gv you vimgrep after the selected text
vnoremap <silent> gv :call VisualSelection('gv')<CR>
" Open vimgrep and put the cursor in the right position
map <leader>g :vimgrep // **/*.<left><left><left><left><left><left><left>
" Vimgreps in the current file
map <leader><space>
      \ :vimgrep // <C-R>%<C-A><Home><right><right><right><right>
      \<right><right><right><right><right>
" When you press <leader>r you can search and replace the selected text
vnoremap <silent> <leader>r :call VisualSelection('replace')<CR>
" When you search with vimgrep, display your results in cope by doing:
map <leader>cc :botright cope<cr>
map <leader>co ggVGy:tabnew<cr>:set syntax=qf<cr>pgg
" To go to the next search result do:
map <leader>n :cn<cr>
" To go to the previous search results do:
map <leader>N :cp<cr>

" copy and paste
if g:osName == 'Darwin'
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

" => Spell checking
""""""""""""""""""""""""
" Pressing ,ss will toggle and untoggle spell checking
map <leader>ss :setlocal spell!<cr>
" Shortcuts using <leader>
map <leader>sn ]s
map <leader>sp [s
map <leader>sa zg
map <leader>s? z=

" => Misc
""""""""""""""""""""""""
" Remove the Windows ^M - when the encodings gets messed up
noremap <Leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm
"" Quickly open a buffer for scripbble
"map <leader>q :e ~/buffer<cr>
" Toggle paste mode on and off
map <leader>pp :setlocal paste!<cr>:echoe HasPaste()<cr>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Remap TAB to keyword completion
function! InsertTabWrapper(direction)
  let col = col('.') - 1
  if !col || getline('.')[col - 1] !~ '\k'
    return "\<tab>"
  elseif "backward" == a:direction
    return "\<c-p>"
  elseif "forward" == a:direction
    return "\<c-n>"
  endif
endfunction

function! CmdLine(str)
  exe "menu Foo.Bar :" . a:str
  emenu Foo.Bar
  unmenu Foo
endfunction

function! VisualSelection(direction) range
  let l:saved_reg = @"
  execute "normal! vgvy"
  let l:pattern = escape(@", '\\/.*$^~[]')
  let l:pattern = substitute(l:pattern, "\n$", "", "")

  if a:direction == 'gv'
    call CmdLine("vimgrep " . '/'. l:pattern . '/' . ' **/*.')
  elseif a:direction == 'replace'
    call CmdLine("%s" . '/'. l:pattern . '/')
  endif

  let @/ = l:pattern
  let @" = l:saved_reg
endfunction

" Returns true if paste mode is enabled
function! HasPaste()
  if &paste
    return 'PASTE MODE  '
  en
  return ''
endfunction

" Highlight all instances of word under cursor, when idle.
" Useful when studying strange source code.
" Type z/ to toggle highlighting on/off.
nnoremap z/ :if AutoHighlightToggle()<Bar>set hls<Bar>endif<CR>
function! AutoHighlightToggle()
  let @/ = ''
  if exists('#auto_highlight')
    au! auto_highlight
    augroup! auto_highlight
    setl updatetime=4000
    echo 'Highlight current word: off'
    return 0
  else
    augroup auto_highlight
      au!
      au CursorHold * let @/ = '\V\<'.escape(expand('<cword>'), '\').'\>'
    augroup end
    setl updatetime=500
    echo 'Highlight current word: ON'
    return 1
  endif
endfunction

"eshion/vim-sync
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
command! SyncUploadFile call SyncUploadFile()
