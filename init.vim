--------------------------------------------------
-- Leader / 基本設定
--------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"

--------------------------------------------------
-- lazy.nvim bootstrap
--------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

--------------------------------------------------
-- プラグイン定義 (lazy.nvim)
--------------------------------------------------
require("lazy").setup({
  spec = {
    { "nvim-lua/plenary.nvim", lazy = true },
    { "nvim-tree/nvim-web-devicons", lazy = true },

    {
      "folke/which-key.nvim",
      event = "VeryLazy",
      opts = {},
    },

    {
      "williamboman/mason.nvim",
      cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonUninstall" },
      opts = {},
    },

    {
      "neovim/nvim-lspconfig",
      event = { "BufReadPre", "BufNewFile" },
    },

    {
      "williamboman/mason-lspconfig.nvim",
      event = { "BufReadPre", "BufNewFile" },
      dependencies = {
        "williamboman/mason.nvim",
        "neovim/nvim-lspconfig",
      },
      opts = {
        -- typescript-language-server から ts_ls に修正
        ensure_installed = { "ruby_lsp", "ts_ls", "pyright" },
      },
    },

    {
      "xiyaowong/transparent.nvim",
      config = function()
        require("transparent").setup({
          extra_groups = {
            "NormalFloat",
            "NvimTreeNormal",
          },
        })
      end,
    },

    -- Ruby用
    {
      "vim-ruby/vim-ruby",
      ft = "ruby",
    },
    {
      "tpope/vim-rails",
      ft = "ruby",
    },
    {
      "tpope/vim-endwise",
      ft = { "ruby", "eruby" },
    },

    -- Treesitter
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      event = { "BufReadPost", "BufNewFile" },
      opts = {
        ensure_installed = {
          "ruby", "lua", "vim", "vimdoc", "query",
          "javascript", "typescript", "tsx", "json", "html", "css",
        },
        highlight = { 
          enable = true,
          additional_vim_regex_highlighting = false, 
        },
        indent = { enable = true },
      },
    },

    -- Neo-tree
    {
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v3.x",
      cmd = "Neotree",
      keys = {
        { "<leader>n", "<cmd>Neotree toggle<CR>", desc = "Neo-tree toggle" },
      },
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
      },
      opts = {},
    },

    -- Telescope
    {
      "nvim-telescope/telescope.nvim",
      version = "0.1.8",
      cmd = "Telescope",
      keys = {
        { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
        { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Live grep" },
        { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Buffers" },
        { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Help tags" },
      },
      dependencies = {
        "nvim-lua/plenary.nvim",
      },
      opts = {
        defaults = {
          layout_strategy = "horizontal",
          layout_config = {
            prompt_position = "top",
          },
          sorting_strategy = "ascending",
          path_display = { "smart" },
        },
      },
    },

    {
      "hrsh7th/nvim-cmp",
      event = "InsertEnter",
      dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
      },
      config = function()
        local cmp = require("cmp")

        cmp.setup({
          snippet = {
            expand = function(args)
              require("luasnip").lsp_expand(args.body)
            end,
          },
          mapping = cmp.mapping.preset.insert({
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
            ["<C-n>"] = cmp.mapping.select_next_item(),
            ["<C-p>"] = cmp.mapping.select_prev_item(),
          }),
          sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "buffer" },
            { name = "path" },
            { name = "luasnip" },
          }),
        })
      end,
    }
  },

  install = { colorscheme = { "habamax" } },
  checker = { enabled = false },
})

--------------------------------------------------
-- LSP設定 (Neovim 0.11+)
--------------------------------------------------
local on_attach = function(_, bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()

vim.lsp.config("ruby_lsp", {
  on_attach = on_attach,
  capabilities = capabilities,
})

-- tsserver から ts_ls に修正
vim.lsp.config("ts_ls", {
  on_attach = on_attach,
  capabilities = capabilities,
})

vim.lsp.config("pyright", {
  on_attach = on_attach,
  capabilities = capabilities,
})

vim.lsp.enable("ruby_lsp")
vim.lsp.enable("pyright")
vim.lsp.enable("ts_ls") -- ts_ls を有効化

--------------------------------------------------
-- キーマップ
--------------------------------------------------
vim.keymap.set("n", "<leader>b", "<C-o>", { desc = "Jump back" })
vim.keymap.set("n", "<leader>tt", "<cmd>TransparentToggle<CR>", { silent = true })
