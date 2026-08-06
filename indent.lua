--------------------------------------------------
-- FileTypeごとのインデント設定
--------------------------------------------------
local set_indent = function(ts, sw, expand)
  vim.opt_local.tabstop = ts
  vim.opt_local.shiftwidth = sw
  vim.opt_local.softtabstop = sw
  vim.opt_local.expandtab = expand
end

-- Ruby / Rails は 2 スペース
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "ruby", "eruby", "rb" },
  callback = function()
    set_indent(2, 2, true)
  end,
})

-- JS / TS も 2 スペース
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "typescript", "typescriptreact", "tsx" },
  callback = function()
    set_indent(2, 2, true)
  end,
})

-- KDL レイアウトなどで 2 スペースに揃えたい場合
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "kdl" },
  callback = function()
    set_indent(2, 2, true)
  end,
})

-- YAML などで 2 スペース固定にしたい場合
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "yaml" },
  callback = function()
    set_indent(2, 2, true)
  end,
})

