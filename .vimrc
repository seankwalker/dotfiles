" .vimrc

autocmd!

" Load filetype plugins & indent files
if has("autocmd")
  filetype indent plugin on
endif

" Meta
set ai              " Autoindent
set encoding=utf-8  " Ensure encoding compatability
set nocompatible    " Turn off `vi` compatability mode
set tabstop=4       " Set tabs -> 4 spaces
set shiftwidth=4    " Set indent -> 4 spaces
set softtabstop=4   " Backspace deletes 4 spaces where tab is instead of 1
set expandtab       " Tabs -> spaces

let mapleader=" "   " Set spacebar as leader
let maplocalleader=" "

" Enable backspace
" set backspace=indent,eol,start

" Aesthetic
syntax on               " Turn on syntax highlighting
colorscheme elflord     " Set theme
set background=dark

" Visual delineation of 80, 120 lines
highlight ColorColumn ctermbg=24
let &colorcolumn="80,".join(range(120,999),",")

" Line numbers
set number
set number relativenumber
augroup numbertoggle
    autocmd!
    autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
    autocmd BufLeave,FocusLost,InsertEnter * set norelativenumber
augroup END

" Airline
let g:airline_powerline_fonts=1                 " turn on powerline symbols
let g:airline_theme="bubblegum"                 " theme
" let g:airline#extensions#tabline#enabled=1    " enable tabline
let g:airline#extensions#tabline#formatter="default"

" Tsuquyomi
let g:tsuquyomi_disable_quickfix = 1 " Disable compile on save
nnoremap <leader>d :TsuDefinition<cr>
nnoremap <leader>D :TsuTypeDefinition<cr>
nnoremap <leader>t :echo tsuquyomi#hint()<cr>
nnoremap <leader>r :TsuquyomiReloadProject<cr>

" vim-rescript
autocmd FileType rescript nnoremap <silent> <buffer> <localleader>p :RescriptFormat<cr>

" CtrlP
let g:ctrlp_cache_dir=$HOME . "/.cache/ctrlp"
" use `hg` for faster indexing h/t
" https://stackoverflow.com/a/32520039/12691951
let g:ctrlp_user_command="ag %s -i --hidden --nocolor --nogroup
    \ --ignore .git
    \ --ignore .DS_Store
    \ --ignore .jekyll-cache
    \ --ignore _site
    \ --ignore android
    \ --ignore build
    \ --ignore dist
    \ --ignore ios
    \ -g ''"

" QoL
" h/t Gary Bernhardt
" https://www.destroyallsoftware.com/screencasts/catalog/file-navigation-in-vim
cnoremap %% <C-R>=expand("%:h")."/"<cr>
map <leader>e :edit %%
map <leader>v :view %%
map <leader>f :\|:CtrlP<cr>
map <leader>gf :\|:CtrlP %%<cr>
nnoremap <leader><leader> <c-^>

function! InsertTabWrapper()
    let col=col(".") - 1
    if !col || getline(".")[col - 1] !~ "\k"
        return "\<tab>"
    else
        return "\<c-p>"
    endif
endfunction
inoremap <expr> <tab> InsertTabWrapper()
inoremap <s-tab> <c-n>


set winwidth=84
" We have to have a winheight bigger than we want to set winminheight. But if
" we set winheight to be huge before winminheight, the winminheight set will
" fail.
set winheight=5
set winminheight=5
set winheight=999

:command Vrc vsp ~/.vimrc
