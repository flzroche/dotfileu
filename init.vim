" ========== 基本設定 ==========
set guifont=Juisee\ NF:h10
set fenc=utf-8
set nobackup
set noswapfile
set autoread
set hidden
set showcmd
set number
set cursorline
set virtualedit=onemore
set smartindent
set visualbell
set showmatch
set laststatus=2
set wildmode=list:longest
let mapleader=" " " <space>がリーダー
nmap <Esc><Esc> :nohlsearch<CR><Esc>
nnoremap j gj
nnoremap k gk
set list listchars=tab:\▸\-
set expandtab
set tabstop=2
set shiftwidth=2
set ignorecase
set smartcase
set incsearch
set wrapscan
set hlsearch

" ========== プラグイン ==========
call plug#begin('~/.config/nvim/plugged')
  " ファイラー/エディタ補助
  Plug 'preservim/nerdtree'
  Plug 'MunifTanjim/nui.nvim'
  Plug 'nvim-lua/plenary.nvim'
  Plug 'stevearc/dressing.nvim'
  " 構文解析
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  " テーマ系
  Plug 'sainnhe/sonokai'
call plug#end()

" --- nvim-treesitter の設定 (Luaで記述) ---
lua << EOF
require('nvim-treesitter.configs').setup {
  -- 解析したい言語のパーサを指定
  ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "javascript", "typescript", "rust", "go", "python", "html", "css" },

  -- trueにすると、ファイルを開いたときに対応するパーサがなければ自動でインストールする
  auto_install = true,

  -- モジュールの設定
  highlight = {
    enable = true, -- シンタックスハイライトを有効にする
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true, -- インデントを有効にする
  },
}
EOF


" ========== ファイラー/その他キーマップ ==========
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <leader>t :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>
" 例: 任意ブックマーク起動
nnoremap <leader>b :OpenBookmark<CR>
nnoremap <leader>i :e ~/dotfilem/init.vim<CR>

" ========== ToggleTermキーマップ ==========
autocmd TermEnter term://*toggleterm#* tnoremap <silent><C-t> <Cmd>exe v:count1 . "ToggleTerm"<CR>
nnoremap <silent><C-t> <Cmd>exe v:count1 . "ToggleTerm"<CR>
inoremap <silent><C-t> <Esc><Cmd>exe v:count1 . "ToggleTerm"<CR>

" ========== Markdown Preview設定 ==========
nmap <C-s> <Plug>MarkdownPreview
nmap <M-s> <Plug>MarkdownPreviewStop
nmap <C-p> <Plug>MarkdownPreviewToggle

" ========== テーマ/カラー設定 ==========
set background=dark
colorscheme sonokai

" ========== ファイルタイプ関連 ==========
autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescriptreact

" ALE, prettier等はLSP＆null-ls/null-ls.nvim等へ移行推奨
" Coc.nvim専用関数/マッピングは全削除（nvim-cmp方式に一本化）


