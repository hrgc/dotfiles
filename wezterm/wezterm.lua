local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

if wezterm.target_triple:find("windows") then
  config.default_prog = { "nu" }
else
  config.default_prog = { "/snap/bin/nu" }
end

config.automatically_reload_config = true
config.color_scheme = "tokyonight_day"
config.use_ime = true
config.font = wezterm.font("Cica", { weight = "Regular" })
config.font_size = 15.5

config.leader = {
  key = "b",
  mods = "CTRL",
  timeout_milliseconds = 2000
}

config.keys = {
  { key = "b", mods = "LEADER|CTRL", action = act.SendKey { key = "b", mods = "CTRL" } },

  { key = "s", mods = "LEADER", action = act.ShowLauncherArgs { flags = "WORKSPACES", title = "Select workspace" } },

  { key = '"', mods = "LEADER|SHIFT", action = act.SplitVertical   { domain = "CurrentPaneDomain" } },
  { key = "%", mods = "LEADER|SHIFT", action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },

  -- パネル移動
  { key = "h", mods = "LEADER", action = act.ActivatePaneDirection "Left"  },
  { key = "j", mods = "LEADER", action = act.ActivatePaneDirection "Down"  },
  { key = "k", mods = "LEADER", action = act.ActivatePaneDirection "Up"    },
  { key = "l", mods = "LEADER", action = act.ActivatePaneDirection "Right" },

  -- パネルサイズ調整
  { key = "H", mods = "LEADER", action = act.AdjustPaneSize { "Left",  5 } },
  { key = "J", mods = "LEADER", action = act.AdjustPaneSize { "Down",  5 } },
  { key = "K", mods = "LEADER", action = act.AdjustPaneSize { "Up",    5 } },
  { key = "L", mods = "LEADER", action = act.AdjustPaneSize { "Right", 5 } },

  { key = "x", mods = "LEADER", action = act.CloseCurrentPane { confirm = true } },

  { key = "c", mods = "LEADER", action = act.SpawnTab "CurrentPaneDomain" },

  { key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },
  { key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },

  { key = "[", mods = "LEADER", action = act.ActivateCopyMode },

  -- フォントサイズ調整
  { key = "+", mods = "LEADER|SHIFT", action = act.IncreaseFontSize },
  { key = "-", mods = "LEADER",       action = act.DecreaseFontSize },
  { key = "0", mods = "LEADER",       action = act.ResetFontSize    },
}

local bar = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")
bar.apply_to_config(config)

return config
