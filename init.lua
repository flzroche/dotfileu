-- leaderキー設定はkeymaps.luaで行う場合、ここでは除外可能
-- 基本設定
vim.opt.guifont = 'PlemolJP:h12'
vim.opt.encoding = 'utf-8'
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.autoread = true
vim.opt.hidden = true
vim.opt.showcmd = true
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.virtualedit = 'onemore'
vim.opt.smartindent = true
vim.opt.visualbell = true
vim.opt.showmatch = true
vim.opt.laststatus = 2
vim.opt.wildmode = { 'list', 'longest' }
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.wrapscan = true
vim.opt.hlsearch = true
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.inccommand = 'split'
vim.opt.scrolloff = 10
vim.opt.confirm = true
vim.o.mouse = 'a'
vim.o.showmode = false

-- Clipboard
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- オートコマンド (Yank時ハイライト)
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.highlight.on_yank() end,
})

-- Nerd Font フラグ
vim.g.have_nerd_font = true

-- lazy.nvim自動インストール
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  'NMAC427/guess-indent.nvim',
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      delay = 0,
      icons = {
        mappings = vim.g.have_nerd_font,
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ', Down = '<Down> ', Left = '<Left> ', Right = '<Right> ',
          C = '<C-…> ', M = '<M-…> ', D = '<D-…> ', S = '<S-…> ',
          CR = '<CR> ', Esc = '<Esc> ', ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ', NL = '<NL> ', BS = '<BS> ',
          Space = '<Space> ', Tab = '<Tab> ',
          F1 = '<F1>', F2 = '<F2>', F3 = '<F3>', F4 = '<F4>', F5 = '<F5>',
          F6 = '<F6>', F7 = '<F7>', F8 = '<F8>', F9 = '<F9>', F10 = '<F10>',
          F11 = '<F11>', F12 = '<F12>',
        },
      },
      spec = {
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      },
    },
  },
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function() return vim.fn.executable 'make' == 1 end,
      },
      'nvim-telescope/telescope-ui-select.nvim',
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      local actions = require('telescope.actions')
      require('telescope').setup{
        extensions = {
          ['ui-select'] = { require('telescope.themes').get_dropdown() },
          file_browser = {
            theme = 'ivy',
            hijack_netrw = true,
            mappings = {
              ['i'] = {
                ['<C-j>'] = actions.move_selection_next,
                ['<C-k>'] = actions.move_selection_previous,
              },
              ['n'] = {
                ['<C-j>'] = actions.move_selection_next,
                ['<C-k>'] = actions.move_selection_previous,
              },
            },
          },
        },
      }
      require('telescope').load_extension 'file_browser'
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')
    end,
  },
  { 'EdenEast/nightfox.nvim' },
  { 'cocopon/iceberg.vim' },
  { 'w0ng/vim-hybrid' },
  { 'wadackel/vim-dogrun' },
  { 'MattesGroeger/vim-bookmarks' },
  {
    'tom-anders/telescope-vim-bookmarks.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim' },
    config = function()
      require('telescope').load_extension('vim_bookmarks')
    end,
  },
  { 'xiyaowong/transparent.nvim' },
  {
    'nvim-neo-tree/neo-tree.nvim',
    version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    lazy = false,
    keys = {
      { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
    },
  },
  {
    'heilgar/bookmarks.nvim',
    dependencies = {
      'kkharji/sqlite.lua',
      'nvim-telescope/telescope.nvim',
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require('bookmarks').setup{
        default_mappings = true,
        db_path = vim.fn.stdpath 'data' .. '/bookmarks.db',
      }
      require('telescope').load_extension('bookmarks')
    end,
    cmd = { 'BookmarkAdd', 'BookmarkRemove', 'Bookmarks' },
    keys = {
      { '<leader>ba', '<cmd>BookmarkAdd<cr>', desc = 'Add Bookmark' },
      { '<leader>br', '<cmd>BookmarkRemove<cr>', desc = 'Remove Bookmark' },
      { '<leader>bj', desc = 'Jump to Next Bookmark' },
      { '<leader>bk', desc = 'Jump to Previous Bookmark' },
      { '<leader>bl', '<cmd>Bookmarks<cr>', desc = 'List Bookmarks' },
      { '<leader>bs', desc = 'Switch Bookmark List' },
    },
  },
  {
    'folke/snacks.nvim',
    lazy = false,
    priority = 1000,
  },
  {
    'nvim-telescope/telescope-file-browser.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim', 'nvim-lua/plenary.nvim' },
  },
})

-- アイコン等のUI設定
if not vim.g.have_nerd_font then
  require('lazy').setup({
    ui = {
      icons = {
        cmd = '⌘', config = '🛠', event = '📅', ft = '📂', init = '⚙',
        keys = '🗝', plugin = '🔌', runtime = '💻', require = '🌙',
        source = '📄', start = '🚀', task = '📌', lazy = '💤 ',
      }
    }
  })
end

require('keymaps')

