local wezterm = require 'wezterm';
local act = wezterm.action

return {
  debug_key_events = true,
  use_ime = true,
  font = wezterm.font('HackGen35 Console NF', { weight = 'Bold' }),
  font_size = 13.0,
  color_scheme = "Builtin Solarized Dark",
  keys = {
    { key = '¥', mods = 'OPT', action = act.SendString('\\') },
  },
}
