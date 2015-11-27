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

filetype plugin indent on       "Sets indent mode based on filetype
syntax on                       "Turn on syntax highlighting
let mapleader=","               "Change leader to a comma
let g:mapleader = ","           "Global leader to a comma

" ================ Color Themes ======================
"colorscheme ansi_blows
"set t_ut=
"colorscheme lucario
"colorscheme jellybeans
"colorscheme atom-dark-256
""Lucius setting
"colorscheme lucius
"LuciusBlackHighContrast
"colorscheme monokai
colorscheme vividchalk
highlight Search guibg=#ff5f00 ctermbg=202 gui=none cterm=none

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
set wildmode=list:longest
set wildmenu                    "Enable ctrl-n and ctrl-p to scroll thru matches
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
set completeopt=longest,menuone "Inserts the longest common text, even if one

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

inoremap <tab> <c-r>=InsertTabWrapper ("forward")<CR>
inoremap <s-tab> <c-r>=InsertTabWrapper ("backward")<CR>
inoremap <expr> j ((pumvisible())?("\<C-n>"):("j"))
inoremap <expr> k ((pumvisible())?("\<C-p>"):("k"))

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

" ================ Misc ==============================
" Get off my lawn
nnoremap <Left> :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up> :echoe "Use k"<CR>
nnoremap <Down> :echoe "Use j"<CR>
" Exit insert mode by typing jk
inoremap jk <ESC>

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

" ,D diff off
nnoremap <Leader>D :diffoff<CR><C-w><C-w>:diffoff<CR>
" ,dt diff this
nnoremap <Leader>d :diffthis<CR><C-w><C-w>:diffthis<CR>
" ,ds Diff split
nnoremap <Leader>ds :<C-u>diffsplit<Space>
" ,dd Diff current files in split view
nnoremap <leader>dd :windo diffthis<CR>

" ,o git checkout current file
nnoremap <Leader>o :!git checkout %<CR><CR>

",v brings up my .vimrc
map <leader>v :sp ~/.vimrc<CR><C-W>_
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
map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove
" Opens a new tab with the current buffer's path
map <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/
" Switch CWD to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>:pwd<cr>

" => vimgrep searching and cope displaying
""""""""""""""""""""""""
" When you press gv you vimgrep after the selected text
vnoremap <silent> gv :call VisualSelection('gv')<CR>
" Open vimgrep and put the cursor in the right position
map <leader>g :vimgrep // **/*.<left><left><left><left><left><left><left>
" Vimgreps in the current file
map <leader><space> :vimgrep // <C-R>%<C-A><right><right><right><right><right><right><right><right><right>
" When you press <leader>r you can search and replace the selected text
vnoremap <silent> <leader>r :call VisualSelection('replace')<CR>
" When you search with vimgrep, display your results in cope by doing:
map <leader>cc :botright cope<cr>
map <leader>co ggVGy:tabnew<cr>:set syntax=qf<cr>pgg
" To go to the next search result do:
map <leader>n :cn<cr>
" To go to the previous search results do:
map <leader>p :cp<cr>


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
map <leader>pp :setlocal paste!<cr>



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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
