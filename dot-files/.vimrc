" Basic {{{1

" Initialize {{{2
augroup MyAutoCmd
    autocmd!
augroup END

" Encoding {{{2
set encoding=utf8
" set fileencodings=ucs-bom,iso-2022-jp,utf-8,cp932,euc-jp,default,latin1
set fileformats=unix,dos,mac
set ambiwidth=double

" Optioins {{{2
set backupdir=~/tmp,.
set directory=~/tmp,.
set viminfo& viminfo+=n~/.viminfo

" view
set modeline
set modelines=5
set visualbell
set t_vb=
set antialias
set number
set ruler
"set cursorline
set foldmethod=marker
set laststatus=2 
set cmdheight=1
set showcmd
set showmode
set statusline=%<%f\ %m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=%l,%c%V%8P
set splitbelow
set splitright

" search
set nohlsearch
set incsearch
set ignorecase
set smartcase
set nowrapscan

" edit
set hidden
set autoindent
set smartindent
set backspace=indent,eol,start
set showmatch
set wildmenu
set formatoptions& formatoptions+=mM
set iminsert=0
set imsearch=-1
"set tags& tags+=./tags;,./**/tags
set clipboard=unnamed

" tab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set smarttab

" mouse support (disable)
set mouse=

" Color {{{2
if (1 < &t_Co || has('gui')) && has('syntax')
    syntax on
    set background=dark
    if (256 <= &t_Co)
        autocmd MyAutoCmd ColorScheme *
        \   if !has('gui_running')
        \ |     highlight Normal ctermbg=none
        \ |     highlight NonText ctermbg=none
        \ |     highlight LineNr ctermbg=none
        \ | endif
        colorscheme desert
    endif
endif

" Utilities {{{1
" CD {{{2
command! -nargs=? -complete=dir -bang CD  call s:change_current_dir('<args>', '<bang>')

" CTagsR {{{2
command! -nargs=? CtagsR !ctags -R --C++-kinds=+p --fields=+iaS --extra=+q . <args>

" Enc {{{2
command! -bang -bar -complete=file -nargs=? Utf8 edit<bang> ++enc=utf-8 <args>
command! -bang -bar -complete=file -nargs=? EucJp edit<bang> ++enc=euc-jp <args>
command! -bang -bar -complete=file -nargs=? Cp932 edit<bang> ++enc=cp932 <args>
command! -bang -bar -complete=file -nargs=? Iso2022jp edit<bang> ++enc=iso-2022-jp <args>

function! s:change_current_dir(directory, bang) " {{{2
    if a:directory == ''
        lcd %:p:h
    else
        execute 'lcd' . a:directory
    endif
    if a:bang == ''
        pwd
    endif
endfunction

function! s:toggle_option(option_name) " {{{2
    execute 'setlocal' a:option_name.'!'
    execute 'setlocal' a:option_name.'?'
endfunction

" Mappings {{{1
" leader
let mapleader = ','

" edit/reload .vimrc
nnoremap <silent> <Space>ev :<C-u>edit ~/.vimrc<CR>
nnoremap <silent> <Space>eg :<C-u>edit ~/.gvimrc<CR>
nnoremap <silent> <Space>rv :<C-u>source ~/.vimrc \| if has('gui_running') \| source ~/.gvimrc \| endif<CR>
nnoremap <silent> <Space>rg :<C-u>source ~/.gvimrc<CR>

" save, quit
nnoremap <silent> <Space>w :<C-u>update<CR>
nnoremap <silent> <Space>q :<C-u>quit<CR>

" escape
noremap <Nul> <C-@>
noremap! <Nul> <C-@>
noremap <C-@> <Esc>
noremap! <C-@> <Esc>
inoremap <silent> <C-j> <Esc>

" emacs like
noremap <C-a> <Home>
noremap! <C-a> <Home>
noremap <C-e> <End>
noremap! <C-e> <End>
noremap! <C-f> <Right>
noremap! <C-b> <Left>
noremap! <C-p> <Up>
noremap! <C-n> <Down>
noremap <C-k> D
inoremap <C-k> <C-o>D
cnoremap <C-k> <C-\>e getcmdpos() == 1 ? '' : getcmdline()[:getcmdpos()-2]<CR> 

" adding and subtracting
nnoremap + <C-a>
nnoremap - <C-x>

" add new line
"nnoremap <Space>O :<C-u>call append(expand('.'), '')<Cr>j

" toggle option
nnoremap <Space>o <Nop>
nnoremap <Space>ow :<C-u>call <SID>toggle_option('wrap')<CR>
nnoremap <Space>on :<C-u>call <SID>toggle_option('number')<CR>
nnoremap <Space>ol :<C-u>call <SID>toggle_option('list')<CR>
nnoremap <Space>op :<C-u>call <SID>toggle_option('paste')<CR>

" fold
"nnoremap <expr> h col('.') == 1 && foldlevel(line('.')) > 0 ? 'zc' : 'h'
"nnoremap <expr> l foldclosed(line('.')) != -1 ? 'zo0' : 'l'
"vnoremap <expr> h col('.') == 1 && foldlevel(line('.')) > 0 ? 'zcgv' : 'h'
"vnoremap <expr> l foldclosed(line('.')) != -1 ? 'zogv0' : 'l'
nnoremap <Space>h zc
nnoremap <Space>l zo
nnoremap <Space>zo zO
nnoremap <Space>zc zC
nnoremap <Space>zO zR
nnoremap <Space>zC zM

" change current directury
nnoremap <silent> <Space>cd :<C-u>CD<CR>

" auto ime off (gvim only)
autocmd MyAutoCmd InsertLeave * set iminsert=0 imsearch=0

" vim -b : edit binary using xxd-format!
augroup Binary
    autocmd!
    autocmd BufReadPre *.bin let &binary = 1 
    autocmd BufReadPost * call BinReadPost()
    autocmd BufWritePre * call BinWritePre()
    autocmd BufWritePost * call BinWritePost()
    function! BinReadPost()
        if &binary
            silent %!xxd -g1 
            set ft=xxd
        endif
    endfunction
    function! BinWritePre()
        if &binary
            let s:saved_pos = getpos( '.' )
            silent %!xxd -r
        endif
    endfunction
    function! BinWritePost()
        if &binary
            silent %!xxd -g1 
            call setpos( '.', s:saved_pos )
            set nomod
        endif
    endfunction
augroup END 

" End {{{1
filetype plugin indent on

if filereadable(expand('~/.vimrc.local'))
    source ~/.vimrc.local
endif

" vim: expandtab softtabstop=4 shiftwidth=4
" vim: foldmethod=marker
