if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

set ts=2 sw=2


let g:plug_url_format="git@github.com:%s.git"

call plug#begin()
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'lambdalisue/fern.vim'

" (Optional) Multi-entry selection UI.
Plug 'junegunn/fzf'
Plug 'tpope/vim-sensible'
" HTML fancy editing
Plug 'mattn/emmet-vim'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-commentary'
Plug 'lifepillar/vim-mucomplete'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'vim-syntastic/syntastic'

call plug#end()


"let g:LanguageClient_serverCommands = {
"    \ 'css': ['css-languageserver','--stdio'],
"    \ 'html': ['html-languageserver','--stdio'],
"    \ 'json': ['json-languageserver','--stdio'],
"    \ 'python': ['pyls'],
"    \ 'ruby': ['solargraph', 'stdio'],
"    \ 'docker': ['docker-langserver', '--stdio'],
"    \ 'rust' : ['~/.cargo/bin/rustup', 'run', 'stable', 'rls'],
"    \ 'javascript' : ['javascript-typescript-stdio'],
"    \ 'typescript' : ['javascript-typescript-stdio'],
"    \ 'elixir'     : ['elixir-ls'],
"    \ }
" yarn global add vscode-css-languageserver-bin
set expandtab
set smarttab

autocmd FileType javascript setlocal sw=2 ts=2 sts=2

autocmd BufWritePre * if count(['tex'],&filetype)
    \ | silent! execute "!tectonic % ; open %:r.pdf >/dev/null 2>&1" | redraw!
    \ | endif

set hidden

" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %

set completeopt+=menuone
set shortmess+=c   " Shut off completion messages
set belloff+=ctrlg " If Vim beeps during completion
let g:mucomplete#enable_auto_at_startup = 1
set completeopt+=noselect

let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 0
let g:netrw_altv = 1
let g:netrw_winsize = 20
let g:netrw_list_hide='.*\.swp$'
"let g:netrw_fastbrowse=0
"let g:netrw_chgwin=0

"nnoremap <silent> <S-CR> :rightbelow 20vs<CR>:e .<CR>
nnoremap <silent> <C-M> :Lex <CR>

" open file vertically to the right

augroup netrw_mappings
    "autocmd FileType netrw setl bufhidden=wipe
    autocmd!
    autocmd FileType netrw call Netrw_mappings()
augroup END
function! OpenToRight()
  :set winfixwidth
  :normal v
  :wincmd L
  :wincmd p
  :close
  :wincmd p
endfunction
function! Netrw_mappings()
    noremap V :call OpenToRight()<cr>
endfunction

" coc.vim example items "

" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=yes

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

command! -nargs=0 Prettier :CocCommand prettier.formatFile


" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current line.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Introduce function text object
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)


" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')





