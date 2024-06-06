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

" YAML -- 2-space indentation
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

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
let g:tsuquyomi_tsserver_max_old_space_size = 12288 " Increase memory limit
nnoremap <leader>d :TsuDefinition<cr>
nnoremap <leader>D :TsuTypeDefinition<cr>
nnoremap <leader>t :echo tsuquyomi#hint()<cr>
nnoremap <leader>[ :TsuReferences<cr>
nnoremap <leader>] :TsuImplementation<cr>
nnoremap <leader>c :TsuGeterr<cr>
nnoremap <leader>C :Copilot<cr>

" LeaderF
let g:Lf_ShowDevIcons = 0

" QoL
" h/t Gary Bernhardt
" https://www.destroyallsoftware.com/screencasts/catalog/file-navigation-in-vim
cnoremap %% <C-R>=expand("%:h")."/"<cr>
map <leader>e :edit %%
map <leader>v :view %%
nnoremap <leader><leader> <c-^>

" Bind C-w z to maximize vertically (this is to match tmux C-b z maximize) 
map <C-w>z <C-w>\|

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

" Remap Omni-Complete (original bind is inconvenient)
" inoremap <leader><tab> <C-x><C-o>

set winwidth=84
" We have to have a winheight bigger than we want to set winminheight. But if
" we set winheight to be huge before winminheight, the winminheight set will
" fail.
set winheight=5
set winminheight=5
set winheight=999

:command Vrc vsp ~/.vimrc
