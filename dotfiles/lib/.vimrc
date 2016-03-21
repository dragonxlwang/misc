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
set timeoutlen=500              "How long it wait for mapped commands
set ttimeoutlen=100             "Faster timeout for escape key and others
set colorcolumn=80              "Highlight column at 80 char
set mouse=a                     "Enable mouse

let g:osName = substitute(system('uname'), "\n", "", "")
let mapleader=","               "Change leader to a comma
let g:mapleader = ","           "Global leader to a comma

" ================ Vundle Config =====================
"" https://github.com/VundleVim/Vundle.vim
" git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
" vim +PluginInstall +qall
" turn filetype detection off and, even if it's not strictly
" necessary, disable loading of indent scripts and filetype plugins
filetype off
filetype plugin indent off
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'scrooloose/nerdtree'
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree
      \ | exe "normal! \<C-w>\<C-w>" | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree")
      \ && b:NERDTree.isTabTree()) | q | endif
let g:NERDTreeShowHidden = 1
nnoremap <leader>nn :NERDTreeToggle<CR>
nnoremap <leader>n. :NERDTreeFind<cr>
nnoremap <leader>no :NERDTree<space>
Plugin 'Xuyuanp/nerdtree-git-plugin'

Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#tab_nr_type = 2 " splits and tab number
let g:airline#extensions#tabline#show_splits = 0
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline_theme = 'term'
" https://gist.github.com/kevinis/c788f85a654b2d7581d8
" https://gist.github.com/baopham/1838072
if g:osName == 'Darwin'
  set guifont=Monaco\ for\ Powerline:h12
  let g:airline_powerline_fonts = 1
else
  let g:airline_powerline_fonts = 1
  " let g:airline#extensions#tabline#left_sep = ' '
  " let g:airline#extensions#tabline#left_alt_sep = '|'
  " let g:airline_left_sep=''
  " let g:airline_right_sep=''
  " let g:airline_left_alt_sep=''
  " let g:airline_right_alt_sep=''
endif

Plugin 'ntpeters/vim-better-whitespace'
" add following to turn on when start
let g:better_whitespace_enabled = 0
autocmd VimEnter * EnableWhitespace
" turn on by default for all filetypes
autocmd BufWritePre * StripWhitespace

if g:osName == 'Darwin'
  Plugin 'Yggdroot/indentLine'
  let g:indentLine_char = '┊'       " | ¦ ┆ │ ┊
else
  Plugin 'nathanaelkane/vim-indent-guides'
  let g:indent_guides_enable_on_vim_startup = 1
  let g:indent_guides_guide_size = 1
endif

Plugin 'ctrlpvim/ctrlp.vim'
let g:ctrlp_show_hidden = 1

Plugin 'majutsushi/tagbar'
nmap <leader>gg
      \ <Esc>"zyiw:TagbarOpenAutoClose<CR>:exe "/".@z.""<CR><CR>:nohlsearch<CR>

Plugin 'flazz/vim-colorschemes'
Plugin 'ConradIrwin/vim-bracketed-paste'
Plugin 'nvie/vim-flake8'
Plugin 'kchmck/vim-coffee-script'
Plugin 'mattn/gist-vim'
Plugin 'mattn/webapi-vim'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-commentary'
Plugin 'airblade/vim-gitgutter'
Plugin 'jiangmiao/auto-pairs'
Plugin 'godlygeek/tabular' " cuke tables: https://gist.github.com/tpope/287147
" Plugin 'dhruvasagar/vim-table-mode'


if g:osName == 'Darwin'
  " export LC_ALL=en_US.UTF-8
  " export LANG=en_US.UTF-8
  " cd ~/.vim/bundle/YouCompleteMe
  " ./install.py --clang-completer
  " cd ~/.vim/bundle/color_coded
  " mkdir build && cd build
  " cmake ..
  " make && make install # Compiling with GCC is preferred, ironically
  " # Clang works on OS X, but has mixed success on Linux and the BSDs
  " # Cleanup afterward; frees several hundred megabytes
  " make clean && make clean_clang
  Plugin 'Valloric/YouCompleteMe' " <leader>d: diagnostic msg on current line
  Plugin 'Valloric/ListToggle'
  " Plugin 'jeaye/color_coded'        " not working right now
  Plugin 'rdnetto/YCM-Generator'
  " Track the engine.
  Plugin 'SirVer/ultisnips'
  " Snippets are separated from the engine. Add this if you want them:
  Plugin 'honza/vim-snippets'
  let g:ycm_extra_conf_globlist = ['~/workspace/*','~/Dropbox/workspace/*']
  let g:ycm_path_to_python_interpreter='/usr/local/bin/python'
  let g:ycm_always_populate_location_list = 1
  let g:ycm_complete_in_comments = 1
  let g:lt_location_list_toggle_map = '<leader>ll' " toggle location list
  let g:lt_quickfix_list_toggle_map = '<leader>qf' " toggle quickfix list
  noremap <Leader>jd :YcmCompleter GoTo<CR>
  noremap <leader>jt :YcmCompleter GetType<CR>
  noremap <leader>jm :YcmCompleter GetDoc<CR>
  noremap <leader>jj :YcmForceCompileAndDiagnostics<CR> :YcmDiags<CR>
        \ :wincmd w<CR>
  let g:ycm_filetype_blacklist = {
        \ 'tagbar' : 1,
        \ 'qf' : 1,
        \ 'notes' : 1,
        \ 'unite' : 1,
        \ 'text' : 1,
        \ 'vimwiki' : 1,
        \ 'pandoc' : 1,
        \ 'infolog' : 1,
        \ 'mail' : 1
        \} " \ 'markdown' : 1,
  " Trigger configuration. Do not use <tab> if you use Valloric/YouCompleteMe.
  let g:UltiSnipsExpandTrigger="<c-j>"
  let g:UltiSnipsJumpForwardTrigger="<c-j>"
  let g:UltiSnipsJumpBackwardTrigger="<c-k>"
  " If you want :UltiSnipsEdit to split your window.
  let g:UltiSnipsEditSplit="vertical"
  " =============================================
  " Plugin 'scrooloose/syntastic'
  " set statusline+=%#warningmsg#
  " set statusline+=%{SyntasticStatuslineFlag()}
  " set statusline+=%*
  " let g:syntastic_always_populate_loc_list = 1
  " let g:syntastic_auto_loc_list = 1
  " let g:syntastic_check_on_open = 1
  " let g:syntastic_check_on_wq = 0
endif

Plugin 'justinmk/vim-syntax-extra'  " temporal solution

Plugin 'Chiel92/vim-autoformat'
let auto_format_type_list = ['c', 'cpp', 'py']
autocmd BufWritePre * if index(auto_format_type_list, &ft) >= 0 | :Autoformat
" au BufWrite * :Autoformat

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - removal of unused plugins; `!` to auto-approve removal
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
" ================ Vundle Finish =====================
filetype plugin indent on       "Sets indent mode based on filetype
syntax on                       "Turn on syntax highlighting

" ================ Color Themes ======================
" "set t_ut=
" "colorscheme lucario jellybeans atom-dark-256 ansi_blows lucius monokai
" "LuciusBlackHighContrast
colorscheme vividchalk
highlight Search guibg=#ff5f00 gui=none ctermbg=226 ctermfg=016 cterm=none
highlight ColorColumn ctermbg=235 guibg=#2c2d27
highlight LineNr ctermfg=033 ctermbg=234 guifg=#0087ff guibg=#1c1c1c
highlight Pmenu ctermfg=051 ctermbg=235 guifg=#00ffff guibg=#2c2d27
highlight PmenuSel ctermfg=015 ctermbg=008 guifg=#ffffff guibg=#808080

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
vnoremap <silent> * :call VisualSelection('f')<CR>
vnoremap <silent> # :call VisualSelection('b')<CR>
" Clearr search history
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
" Close the current buffer
map <leader>bd :Bclose<cr>
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

  if a:direction == 'b'
    execute "normal ?" . l:pattern . "^M"
  elseif a:direction == 'gv'
    call CmdLine("vimgrep " . '/'. l:pattern . '/' . ' **/*.')
  elseif a:direction == 'replace'
    call CmdLine("%s" . '/'. l:pattern . '/')
  elseif a:direction == 'f'
    execute "normal /" . l:pattern . "^M"
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

" Don't close window, when deleting a buffer
command! Bclose call <SID>BufcloseCloseIt()
function! <SID>BufcloseCloseIt()
  let l:currentBufNum = bufnr("%")
  let l:alternateBufNum = bufnr("#")

  if buflisted(l:alternateBufNum)
    buffer #
  else
    bnext
  endif

  if bufnr("%") == l:currentBufNum
    new
  endif

  if buflisted(l:currentBufNum)
    execute("bdelete! ".l:currentBufNum)
  endif
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
