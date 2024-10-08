-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local cmus_widget = require('awesome-wm-widgets.cmus-widget.cmus')
local volume_widget = require("awesome-wm-widgets.volume-widget.volume")
local logout_menu_widget = require("awesome-wm-widgets.logout-menu-widget.logout-menu")
local net_speed_widget = require("awesome-wm-widgets.net-speed-widget.net-speed")
local battery_widget = require("battery-widget")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
  naughty.notify({
    preset = naughty.config.presets.critical,
    title = "Oops, there were errors during startup!",
    text = awesome.startup_errors,
  })
end

-- Handle runtime errors after startup
do
  local in_error = false
  awesome.connect_signal("debug::error", function(err)
    -- Make sure we don't go into an endless error loop
    if in_error then
      return
    end
    in_error = true

    naughty.notify({
      preset = naughty.config.presets.critical,
      title = "Oops, an error happened!",
      text = tostring(err),
    })
    in_error = false
  end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_configuration_dir() .. "theme.lua")

-- Use correct status icon size
awesome.set_preferred_icon_size(32)

-- Enable gaps
beautiful.useless_gap = 2
beautiful.gap_single_client = true

-- Fix window snapping
awful.mouse.snap.edge_enabled = false

-- This is used later as the default terminal and editor to run.
terminal = "st"
editor = os.getenv("EDITOR") or "nvim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
  awful.layout.suit.corner.nw,
  awful.layout.suit.corner.ne,
  awful.layout.suit.tile,
  awful.layout.suit.fair,
  awful.layout.suit.fair.horizontal,
  awful.layout.suit.tile.left,
  awful.layout.suit.tile.bottom,
  awful.layout.suit.tile.top,
  -- awful.layout.suit.max,
  awful.layout.suit.spiral,
  -- awful.layout.suit.floating,
}
-- }}}

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
  awful.button({}, 1, function(t)
    t:view_only()
  end),
  awful.button({ modkey }, 1, function(t)
    if client.focus then
      client.focus:move_to_tag(t)
    end
  end),
  awful.button({}, 3, awful.tag.viewtoggle),
  awful.button({ modkey }, 3, function(t)
    if client.focus then
      client.focus:toggle_tag(t)
    end
  end),
  awful.button({}, 4, function(t)
    awful.tag.viewnext(t.screen)
  end),
  awful.button({}, 5, function(t)
    awful.tag.viewprev(t.screen)
  end)
)

local tasklist_buttons = gears.table.join(
  awful.button({}, 1, function(c)
    if c == client.focus then
      c.minimized = true
    else
      c:emit_signal("request::activate", "tasklist", { raise = true })
    end
  end),
  awful.button({}, 3, function()
    awful.menu.client_list({ theme = { width = 250 } })
  end),
  awful.button({}, 4, function()
    awful.client.focus.byidx(1)
  end),
  awful.button({}, 5, function()
    awful.client.focus.byidx(-1)
  end)
)

local function set_wallpaper(s)
  -- Wallpaper
  if beautiful.wallpaper then
    local wallpaper = beautiful.wallpaper
    -- If wallpaper is a function, call it with the screen
    if type(wallpaper) == "function" then
      wallpaper = wallpaper(s)
    end
    gears.wallpaper.maximized(wallpaper, s, true)
  end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)
awful.screen.connect_for_each_screen(function(s)
  -- Wallpaper
  set_wallpaper(s)

  -- Each screen has its own tag table.
  awful.tag({ "1", "2", "3", "4", "5" }, s, awful.layout.layouts[1])

  -- Create a promptbox for each screen
  s.mypromptbox = awful.widget.prompt()
  -- Create an imagebox widget which will contain an icon indicating which layout we're using.
  -- We need one layoutbox per screen.
  s.mylayoutbox = awful.widget.layoutbox(s)
  s.mylayoutbox:buttons(gears.table.join(
    awful.button({}, 1, function()
      awful.layout.inc(1)
    end),
    awful.button({}, 3, function()
      awful.layout.inc(-1)
    end),
    awful.button({}, 4, function()
      awful.layout.inc(1)
    end),
    awful.button({}, 5, function()
      awful.layout.inc(-1)
    end)
  ))
  -- Create a taglist widget
  s.mytaglist = awful.widget.taglist({
    screen = s,
    filter = awful.widget.taglist.filter.all,
    buttons = taglist_buttons,
  })

  -- Create a tasklist widget
  s.mytasklist = awful.widget.tasklist({
    screen = s,
    filter = awful.widget.tasklist.filter.currenttags,
    buttons = tasklist_buttons,
  })

  -- Create the wibox
  s.mywibox = awful.wibar({ position = "top", screen = s })

  -- Create systray
  s.systray = wibox.widget.systray()

  -- Add widgets to the wibox
  s.mywibox:setup({
    layout = wibox.layout.align.horizontal,
    { -- Left widgets
      layout = wibox.layout.fixed.horizontal,
      mylauncher,
      s.mytaglist,
      s.mypromptbox,
    },
    s.mytasklist, -- Middle widget
    {           -- Right widgets
      layout = wibox.layout.fixed.horizontal,
      spacing = 6,

      s.systray,
      net_speed_widget(),
      volume_widget({
        widget_type = "arc",
      }),

			cmus_widget(),

      battery_widget({
        ac = "AC",
        adapter = "BAT0",
        ac_prefix = "AC: ",
        battery_prefix = "",
        percent_colors = {
          { 25,  "red" },
          { 50,  "orange" },
          { 999, "green" },
        },
        listen = true,
        timeout = 10,
        widget_text = "${AC_BAT}${color_on}${percent}%${color_off}",
        widget_font = "Deja Vu Sans Mono 13",
        tooltip_text = "Battery ${state}${time_est}\nCapacity: ${capacity_percent}%",
        alert_threshold = 5,
        alert_timeout = 0,
        alert_title = "Low battery !",
        alert_text = "${AC_BAT}${time_est}",
        alert_icon = "~/Downloads/low_battery_icon.png",
        warn_full_battery = true,
        full_battery_icon = "~/Downloads/full_battery_icon.png",
      }),
      logout_menu_widget(),
      mytextclock,
      s.mylayoutbox,
    },
  })
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(awful.button({}, 4, awful.tag.viewnext), awful.button({}, 5, awful.tag.viewprev)))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
-- Focus on tags
-- Send a test notification
-- info at https://awesomewm.org/doc/api/libraries/naughty.html#notify
  awful.key({ modkey, "Shift" }, "t", function()
    --[[ local notif_icon = gears.surface.load_uncached(
                       gears.filesystem.get_configuration_dir() .. "path/to/icon") ]]
    naughty.notify({
      -- screen = 1,
      -- timeout = 0,-- in seconds
      -- ignore_suspend = true,-- if true notif shows even if notifs are suspended via naughty.suspend
      fg = "#ff0",
      -- bg = "#ff0000",
      title = "Test Title",
      text = "Test Notification",
      -- icon = gears.color.recolor_image(notif_icon, "#ff0"),
      -- icon_size = 24,-- in px
      border_width = 2,
    })
  end, { description = "send test notification", group = "awesome" }),
  awful.key({ modkey }, "z", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),
  awful.key({ modkey }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" }),
  awful.key({ modkey }, "Left", awful.tag.viewprev, { description = "view previous", group = "tag" }),

  -- Master and column manipulation
  awful.key({ modkey }, "m", function()
    awful.tag.incnmaster(1, nil, true)
  end, { description = "increase the number of master clients", group = "layout" }),
  awful.key({ modkey, "Shift" }, "m", function()
    awful.tag.incnmaster(-1, nil, true)
  end, { description = "decrease the number of master clients", group = "layout" }),
  awful.key({ modkey }, "n", function()
    awful.tag.incncol(1, nil, true)
  end, { description = "increase the number of columns", group = "layout" }),
  awful.key({ modkey, "Shift" }, "n", function()
    awful.tag.incncol(-1, nil, true)
  end, { description = "decrease the number of columns", group = "layout" }),

  -- Swap layout
  awful.key({ modkey }, "space", function()
    awful.layout.inc(1)
  end, { description = "select next", group = "layout" }),
  awful.key({ modkey, "Shift" }, "space", function()
    awful.layout.inc(-1)
  end, { description = "select previous", group = "layout" }),

  -- Focus screen
  awful.key({ modkey }, "Tab", function()
    awful.screen.focus_relative(1)
  end, { description = "focus the next screen", group = "screen" }),
  awful.key({ modkey, "Shift" }, "Tab", function()
    awful.screen.focus_relative(-1)
  end, { description = "focus the previous screen", group = "screen" }),

  -- Standard program

  awful.key({ modkey }, "d", function()
    awful.util.spawn("rofi -show run")
  end, { description = "list all programs in bin", group = "launcher" }),

  awful.key({ modkey }, "w", function()
    awful.util.spawn("rofi -show window")
  end, { description = "switch between window", group = "launcher" }),

  awful.key({ modkey }, "p", function()
    awful.util.spawn("rofi -show drun")
  end, { description = "list all programs installed", group = "launcher" }),

  awful.key({ modkey }, "c", function()
    awful.spawn.with_shell("sioyek") -- REMOVE MESA WHEN YOU GET A NEW PC ;))) GOT a new one bro
  end, { description = "Open sioyek pdf viewer", group = "launcher" }),

  awful.key({ modkey }, "space", function()
    awful.util.spawn("mpv /home/bro_grammer/Downloads/challenge.mp3")
  end, { description = "Open motivation", group = "launcher" }),

  awful.key({ modkey }, "n", function()
    awful.util.spawn("goneovim")
  end, { description = "Open neovim", group = "launcher" }),

  awful.key({ modkey }, "return", function()
    awful.spawn(terminal)
  end, { description = "open a terminal", group = "launcher" }),
  awful.key({ modkey }, "Return", function()
    awful.spawn(terminal)
  end),
  awful.key({ modkey, "Shift" }, "w", awesome.restart, { description = "reload awesome", group = "awesome" }),
  awful.key({ modkey, "Shift" }, "Escape", awesome.quit, { description = "quit awesome", group = "awesome" }),
  awful.key({ modkey, "Shift" }, "9", function()
    awful.prompt.run({
      prompt = "Run Lua code: ",
      textbox = awful.screen.focused().mypromptbox.widget,
      exe_callback = awful.util.eval,
      history_path = awful.util.get_cache_dir() .. "/history_eval",
    })
  end, { description = "lua execute prompt", group = "awesome" })
)

clientkeys = gears.table.join(
-- Handling window states
				awful.key({}, "XF86AudioPlay",  function () cmus_widget:play_pause()       end, {description = "play track",     group = "cmus"}),
				awful.key({}, "XF86AudioNext",  function () cmus_widget:next_track() end, {description = "next track",     group = "cmus"}),
				awful.key({}, "XF86AudioPrev",  function () cmus_widget:prev_track() end, {description = "next track",     group = "cmus"}),
				awful.key({modkey}, "-",  function () cmus_widget:seek_plus() end, {description = "previous track", group = "cmus"}),
				awful.key({modkey}, "0",  function () cmus_widget:seek_minus() end, {description = "previous track", group = "cmus"}),
--   awful.key({}, "XF86AudioPlay", function()
--     awful.util.spawn("playerctl play-pause", false)
--   end),
--   awful.key({}, "XF86AudioNext", function()
--     awful.util.spawn("playerctl next", false)
--   end),
--   awful.key({}, "XF86AudioPrev", function()
--     awful.util.spawn("playerctl previous", false)
--   end),
  awful.key({}, "XF86AudioRaiseVolume", function()
    volume_widget.inc()
  end),
  awful.key({}, "XF86AudioLowerVolume", function()
    volume_widget.dec()
  end),
  awful.key({}, "XF86AudioMute", function()
    volume_widget.toggle()
  end),
  awful.key({ modkey }, "f", function(c)
    c.fullscreen = not c.fullscreen
    c:raise()
  end, { description = "toggle fullscreen", group = "client" }),
  awful.key({ modkey }, "q", function(c)
    c:kill()
  end, { description = "close", group = "client" }),
  awful.key({ modkey }, "o", awful.client.floating.toggle, { description = "toggle floating", group = "client" }),

  -- Layout control
  awful.key({ modkey, "Shift" }, "Return", function(c)
    c:swap(awful.client.getmaster())
  end, { description = "move to master", group = "client" }),
  awful.key({ modkey }, "s", function(c)
    c:move_to_screen()
  end, { description = "move to screen", group = "client" }),

  -- Resize windows
  awful.key({ modkey, "Control" }, "Up", function(c)
    if c.floating then
      c:relative_move(0, 0, 0, -20)
    else
      awful.client.incwfact(0.125)
    end
  end, { description = "Floating Resize Vertical -", group = "client" }),
  awful.key({ modkey, "Control" }, "Down", function(c)
    if c.floating then
      c:relative_move(0, 0, 0, 20)
    else
      awful.client.incwfact(-0.125)
    end
  end, { description = "Floating Resize Vertical +", group = "client" }),
  awful.key({ modkey, "Control" }, "Left", function(c)
    if c.floating then
      c:relative_move(0, 0, -20, 0)
    else
      awful.tag.incmwfact(-0.015)
    end
  end, { description = "Floating Resize Horizontal -", group = "client" }),
  awful.key({ modkey, "Control" }, "Right", function(c)
    if c.floating then
      c:relative_move(0, 0, 20, 0)
    else
      awful.tag.incmwfact(0.015)
    end
  end, { description = "Floating Resize Horizontal +", group = "client" }),

  -- Moving floating windows
  awful.key({ modkey, "Shift" }, "Down", function(c)
    c:relative_move(0, 8, 0, 0)
  end, { description = "Floating Move Down", group = "client" }),
  awful.key({ modkey, "Shift" }, "Up", function(c)
    c:relative_move(0, -8, 0, 0)
  end, { description = "Floating Move Up", group = "client" }),
  awful.key({ modkey, "Shift" }, "Left", function(c)
    c:relative_move(-8, 0, 0, 0)
  end, { description = "Floating Move Left", group = "client" }),
  awful.key({ modkey, "Shift" }, "Right", function(c)
    c:relative_move(8, 0, 0, 0)
  end, { description = "Floating Move Right", group = "client" }),

  -- Maximize unmaximize
  awful.key({ modkey }, "r", function(c)
    c.maximized = not c.maximized
    c:raise()
  end, { description = "(un)maximize", group = "client" }),
  awful.key({ modkey, "Control" }, "k", function(c)
    c.maximized_vertical = not c.maximized_vertical
    c:raise()
  end, { description = "(un)maximize vertically", group = "client" }),
  awful.key({ modkey, "Control" }, "j", function(c)
    c.maximized_vertical = not c.maximized_vertical
    c:raise()
  end, { description = "(un)maximize vertically", group = "client" }),
  awful.key({ modkey, "Control" }, "l", function(c)
    c.maximized_horizontal = not c.maximized_horizontal
    c:raise()
  end, { description = "(un)maximize horizontally", group = "client" }),
  awful.key({ modkey, "Control" }, "h", function(c)
    c.maximized_horizontal = not c.maximized_horizontal
    c:raise()
  end, { description = "(un)maximize horizontally", group = "client" }),

  -- Moving window focus works between desktops
  awful.key({ modkey }, "j", function(c)
    awful.client.focus.global_bydirection("down")
    c:lower()
  end, { description = "focus next window up", group = "client" }),
  awful.key({ modkey }, "k", function(c)
    awful.client.focus.global_bydirection("up")
    c:lower()
  end, { description = "focus next window down", group = "client" }),
  awful.key({ modkey }, "l", function(c)
    awful.client.focus.global_bydirection("right")
    c:lower()
  end, { description = "focus next window right", group = "client" }),
  awful.key({ modkey }, "h", function(c)
    awful.client.focus.global_bydirection("left")
    c:lower()
  end, { description = "focus next window left", group = "client" }),

  -- Moving windows between positions works between desktops
  awful.key({ modkey, "Shift" }, "h", function(c)
    awful.client.swap.global_bydirection("left")
    c:raise()
  end, { description = "swap with left client", group = "client" }),
  awful.key({ modkey, "Shift" }, "l", function(c)
    awful.client.swap.global_bydirection("right")
    c:raise()
  end, { description = "swap with right client", group = "client" }),
  awful.key({ modkey, "Shift" }, "j", function(c)
    awful.client.swap.global_bydirection("down")
    c:raise()
  end, { description = "swap with down client", group = "client" }),
  awful.key({ modkey, "Shift" }, "k", function(c)
    awful.client.swap.global_bydirection("up")
    c:raise()
  end, { description = "swap with up client", group = "client" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
  globalkeys = gears.table.join(
    globalkeys,
    -- View tag only.
    awful.key({ modkey }, "#" .. i + 9, function()
      local screen = awful.screen.focused()
      local tag = screen.tags[i]
      if tag then
        tag:view_only()
      end
    end, { description = "view tag #" .. i, group = "tag" }),
    -- Toggle tag display.
    awful.key({ modkey, "Control" }, "#" .. i + 9, function()
      local screen = awful.screen.focused()
      local tag = screen.tags[i]
      if tag then
        awful.tag.viewtoggle(tag)
      end
    end, { description = "toggle tag #" .. i, group = "tag" }),
    -- Move client to tag.
    awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
      if client.focus then
        local tag = client.focus.screen.tags[i]
        if tag then
          client.focus:move_to_tag(tag)
        end
      end
    end, { description = "move focused client to tag #" .. i, group = "tag" }),
    -- Toggle tag on focused client.
    awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function()
      if client.focus then
        local tag = client.focus.screen.tags[i]
        if tag then
          client.focus:toggle_tag(tag)
        end
      end
    end, { description = "toggle focused client on tag #" .. i, group = "tag" })
  )
end

-- Control floating windows with mouse
clientbuttons = gears.table.join(
  awful.button({}, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", { raise = true })
  end),
  awful.button({ modkey }, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", { raise = true })
    awful.mouse.client.move(c)
  end),
  awful.button({ modkey }, 3, function(c)
    c:emit_signal("request::activate", "mouse_click", { raise = true })
    awful.mouse.client.resize(c)
  end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
  -- All clients will match this rule.
  {
    rule = {},
    properties = {
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = awful.client.focus.filter,
      raise = true,
      keys = clientkeys,
      buttons = clientbuttons,
      screen = awful.screen.preferred,
    },
  },

  -- Floating clients.
  {
    rule_any = {
      -- Note that the name property shown in xprop might be set slightly after creation of the client
      -- and the name shown there might not match defined rules here.
      name = {
        "Event Tester", -- xev.
      },
      role = {
        "AlarmWindow", -- Thunderbird's calendar.
        "ConfigManager", -- Thunderbird's about:config.
        "pop-up",    -- e.g. Google Chrome's (detached) Developer Tools.
      },
    },
    properties = { floating = true },
  },

  -- Remove titlebars to normal clients and dialogs
  { rule_any = { type = { "normal", "dialog" } }, properties = { titlebars_enabled = false } },

  -- { rule = { class = "Thunderbird" }, properties = { screen = 1, tag = "8" } },
  -- { rule = { class = "discord" }, properties = { screen = 0, tag = "9" } },
  -- { rule = { class = "mpv" }, properties = { screen = 1, fullscreen = true } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
  -- Set the windows at the slave,
  -- i.e. put it at the end of others instead of setting it master.
  -- if not awesome.startup then awful.client.setslave(c) end

  if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
    -- Prevent clients from being unreachable after screen count changes.
    awful.placement.no_offscreen(c)
  end
end)

-- Functions

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
  -- buttons for the titlebar
  local buttons = gears.table.join(
    awful.button({}, 1, function()
      c:emit_signal("request::activate", "titlebar", { raise = true })
      awful.mouse.client.move(c)
    end),
    awful.button({}, 3, function()
      c:emit_signal("request::activate", "titlebar", { raise = true })
      awful.mouse.client.resize(c)
    end)
  )

  awful.titlebar(c):setup({
    { -- Left
      awful.titlebar.widget.iconwidget(c),
      buttons = buttons,
      layout = wibox.layout.fixed.horizontal,
    },
    { -- Middle
      { -- Title
        align = "center",
        widget = awful.titlebar.widget.titlewidget(c),
      },
      buttons = buttons,
      layout = wibox.layout.flex.horizontal,
    },
    layout = wibox.layout.align.horizontal,
  })
end)

-- -- Enable sloppy focus, so that focus follows mouse.
-- client.connect_signal("mouse::enter", function(c)
--     c:emit_signal("request::activate", "mouse_enter", {raise = false})
-- end)

client.connect_signal("focus", function(c)
  c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
  c.border_color = beautiful.border_normal
end)
-- }}}
local arg = ""
awful.spawn.with_shell("picom")
awful.spawn.with_shell("xrandr --rate 60")
awful.spawn.with_shell("mouseless")
awful.spawn.with_shell("nitrogen --set-zoom-fill --restore")
awful.spawn.with_shell('xinput set-prop "ELAN0788:00 04F3:321A Touchpad" "libinput Tapping Enabled" 1') -- run xinput list --name-only | grep -i touch to get devince name
