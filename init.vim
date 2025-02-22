let g:coc_disable_startup_warning = 1
let g:vim_markdown_folding_disabled = 1

call plug#begin()

Plug 'preservim/nerdtree'
Plug 'preservim/vim-markdown'
Plug 'tpope/vim-fugitive'
Plug 'wesQ3/vim-windowswap'
Plug 'sudar/vim-arduino-syntax'

call plug#end()

let g:rustfmt_autosave = 1

function FormatCPPBuffer()
  if &modified && !empty(findfile('.clang-format', expand('%:p:h') . ';'))
    let cursor_pos = getpos('.')
    :%!clang-format
    call setpos('.', cursor_pos)
  endif
endfunction

autocmd BufNewfile,BufRead *.ino set filetype=cpp
autocmd FileType *.h,*.hpp,*.c,*.cpp,*.vert,*.frag,*.proto setlocal cindent
autocmd BufWritePre *.h,*.hpp,*.c,*.cpp,*.vert,*.frag,*.proto,*.ino :call FormatCPPBuffer()
autocmd FileType *.py set local formatprg=yapf equalprg=yapf textwidth=80
autocmd FileType *.rs set tabstop=4 shiftwidth=4 expandtab

" Some servers have issues with backup files, see #649
set nobackup
set nowritebackup

" Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
" delays and poor user experience
set updatetime=300

set laststatus=2
set statusline=%r\ %-m\ %-f\ %=%p\%%\ 

lua require('init')
