if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

set et ts=2 sw=2


let g:plug_url_format="git@github.com:%s.git"

call plug#begin()
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" (Optional) Multi-entry selection UI.
Plug 'junegunn/fzf'
Plug 'tpope/vim-sensible'
" HTML fancy editing
Plug 'mattn/emmet-vim'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-commentary'
Plug 'lifepillar/vim-mucomplete'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-airline/vim-airline'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
Plug 'logico/typewriter-vim'
Plug 'godlygeek/tabular'
Plug 'gosukiwi/vim-atom-dark'
Plug 'cocopon/iceberg.vim'
Plug 'dense-analysis/ale'
Plug 'jonathanfilip/vim-dbext'
Plug 'sheerun/vim-polyglot'
Plug 'kritr/vim-keysound'
Plug 'skywind3000/asyncrun.vim'
Plug 'pedsm/sprint'

call plug#end()
set expandtab
set smarttab

augroup typescript_types
  au BufNewFile,BufRead *.ts set filetype=typescript
  au BufNewFile,BufRead *.tsx set filetype=typescript.tsx
augroup END


let g:mucomplete#user_mappings = { 'sqla' : "\<c-c>a" }
let g:mucomplete#chains = { 'sql' : ['file', 'sqla', 'keyn'] }

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
let g:netrw_winsize = 30
let g:netrw_list_hide='.*\.swp$'
"let g:netrw_fastbrowse=0
"let g:netrw_chgwin=0

"nnoremap <silent> <S-CR> :rightbelow 20vs<CR>:e .<CR>

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

function! s:goyo_enter()
  if executable('tmux') && strlen($TMUX)
    silent !tmux set status off
    silent !tmux list-panes -F '\#F' | grep -q Z || tmux resize-pane -Z
  endif
  setlocal spell
  set noshowmode
  set noshowcmd
  set scrolloff=999
  set wrap
  set linebreak
  colorscheme typewriter
  let &t_SI = "\e[5 q"
  let &t_EI = "\e[1 q"
  Limelight
  MUcompleteAutoToggle
  let b:coc_suggest_disable=1
endfunction

function! s:goyo_leave()
  if executable('tmux') && strlen($TMUX)
    silent !tmux set status on
    silent !tmux list-panes -F '\#F' | grep -q Z && tmux resize-pane -Z
  endif

  setlocal nospell
  set nowrap
  set showmode
  set showcmd
  set scrolloff=5
  Limelight!
  MUcompleteAutoToggle
  let b:coc_suggest_disable=0

  colorscheme iceberg
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()
noremap <F12> :Goyo <cr>

let g:vim_markdown_folding_disabled = 1

let &t_ut=''
set t_Co=256
set background=dark

colorscheme iceberg
set termguicolors
let g:airline_theme='serene'

set scrolloff=10

" augroup SyntaxSettings
"     autocmd!
"     autocmd BufNewFile,BufRead *.tsx set filetype=typescript
" augroup END

let g:ctrlp_map = '<leader>p'
let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']


nnoremap <leader>b :ls<CR>:b<space>
nnoremap <leader>t :CtrlPBuffer<CR>

" set clipboard=unnamed
set re=2
