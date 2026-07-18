" Avoid issues with vi
set nocompatible

" Show number lines
set number

" Show syntax highlighting
syntax on

" Enable file type detection
filetype on
" Enable plugins
filetype plugin on
" Load an indent file for the detected file type
filetype indent on

" Cursor highlighting
set cursorline
" set cursorcolumn

" Search highlighting
set hlsearch

" STATUS LINE ------------------------------------------------------------ {{{

" Clear status line when vimrc is reloaded.
set statusline=

" Status line left side.
set statusline+=\ %F\ %M\ %Y\ %R

" Use a divider to separate the left side from the right side.
set statusline+=%=

" Status line right side.
set statusline+=\ ascii:\ %b\ hex:\ 0x%B\ row:\ %l\ col:\ %c\ percent:\ %p%%

" Show the status on the second to last line.
set laststatus=2

" }}}
