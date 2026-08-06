local wezterm = require 'wezterm'
local act = wezterm.action

return {
  keys = {
    -- pane 移動
    { key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
    { key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
    { key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
    { key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },

    -- pane 分割
    { key = '-', mods = 'LEADER', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
    { key = '|', mods = 'LEADER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },

    -- copy / paste
    { key = '[', mods = 'LEADER', action = act.ActivateCopyMode },
    { key = ']', mods = 'LEADER', action = act.PasteFrom 'Clipboard' },

    -- ▼ ここからタブ関連 ▼

    -- 新しいタブを開く
    { key = 'c', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' },

    -- タブを閉じる
    { key = 'x', mods = 'LEADER', action = act.CloseCurrentTab { confirm = true } },

    -- 前後のタブへ移動
    { key = 'n', mods = 'LEADER', action = act.ActivateTabRelative(1) },
    { key = 'p', mods = 'LEADER', action = act.ActivateTabRelative(-1) },

    -- 番号指定でタブに移動 (0〜8)
    { key = '1', mods = 'LEADER', action = act.ActivateTab(0) },
    { key = '2', mods = 'LEADER', action = act.ActivateTab(1) },
    { key = '3', mods = 'LEADER', action = act.ActivateTab(2) },
    { key = '4', mods = 'LEADER', action = act.ActivateTab(3) },
    { key = '5', mods = 'LEADER', action = act.ActivateTab(4) },
    { key = '6', mods = 'LEADER', action = act.ActivateTab(5) },
    { key = '7', mods = 'LEADER', action = act.ActivateTab(6) },
    { key = '8', mods = 'LEADER', action = act.ActivateTab(7) },
    { key = '9', mods = 'LEADER', action = act.ActivateTab(8) },
  },

  key_tables = {
    copy_mode = {
      {
        key = 'Enter',
        mods = 'NONE',
        action = act.Multiple{
          { CopyTo = 'ClipboardAndPrimarySelection' },
          { CopyMode = 'Close' },
        },
      },
    },

    search_mode = {
      -- ここは空でも OK
    },
  },
}

