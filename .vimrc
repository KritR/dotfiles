if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()
Plug 'nikitavoloboev/vim-night-blue'
Plug 'vim-ruby/vim-ruby'
Plug 'keith/swift.vim'
Plug 'elixir-editors/vim-elixir'
Plug 'pangloss/vim-javascript'
Plug 'othree/html5.vim'
Plug 'artur-shaik/vim-javacomplete2'
Plug 'Shougo/deoplete.nvim'
Plug 'roxma/nvim-yarp'
Plug 'roxma/vim-hug-neovim-rpc'
Plug 'carlitux/deoplete-ternjs', { 'do': 'yarn global add tern' }
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }

" (Optional) Multi-entry selection UI.
Plug 'junegunn/fzf'
Plug 'tpope/vim-sensible'
call plug#end()

let g:LanguageClient_serverCommands = {
    \ 'css': ['css-languageserver','--stdio'],
    \ 'html': ['html-languageserver','--stdio'],
    \ 'json': ['json-languageserver','--stdio'],
    \ 'python': ['pyls'],
    \ 'ruby': ['solargraph', 'stdio'],
    \ 'docker': ['docker-langserver', '--stdio'],
    \ }
" yarn global add vscode-css-languageserver-bin
set expandtab
let g:deoplete#enable_at_startup = 1

autocmd FileType java setlocal omnifunc=javacomplete#Complete

set hidden

"colorscheme night-blue
"    'java': ['java', '-Declipse.application=org.eclipse.jdt.ls.core.id1', '-Dosgi.bundles.defaultStartLevel=4', '-Declipse.product=org.eclipse.jdt.ls.core.product', '-Dlog.protocol=true', '-Dlog.level=ALL', '-noverify', '-Xmx1G', '-jar /opt/jdt-language-server/plugins/org.eclipse.equinox.launcher_1.5.100.v20180827-1352.jar', '-configuration /opt/jdt-language-server/config_mac', '--add-modules=ALL-SYSTEM', '--add-opens java.base/java.util=ALL-UNNAMED', '--add-opens java.base/java.lang=ALL-UNNAMED'],
