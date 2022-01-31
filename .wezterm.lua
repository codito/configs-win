-- Wezterm configuration
-- Created: 11/12/2021, 21:09:35 +0530
-- Last updated: 31/01/2022, 21:29:38 +0530
local wezterm = require("wezterm")

local config = {
    check_for_updates = false,
    color_scheme = "Gruvbox Dark",

    tab_bar_at_bottom = true,
    inactive_pane_hsb = {
        hue = 1.0,
        saturation = 1.0,
        brightness = 1.0,
    },

    font = wezterm.font("Delugia"),
    font_size = 12.0,

    default_prog = { 'powershell.exe', '-NoLogo' },
    launch_menu = {},
    leader = { key="b", mods="CTRL" },

    -- Allow using ^ with single key press.
    use_dead_keys = false,
    keys = {
        -- New/close pane
        { key = "c", mods = "LEADER",       action=wezterm.action{SpawnTab="CurrentPaneDomain"}},
        { key = "q", mods = "LEADER",       action=wezterm.action{CloseCurrentPane={confirm=true}}},
        { key = "Q", mods = "LEADER",       action=wezterm.action{CloseCurrentTab={confirm=true}}},
        { key = "x", mods = "LEADER",       action=wezterm.action{CloseCurrentPane={confirm=false}}},
        { key = "X", mods = "LEADER",       action=wezterm.action{CloseCurrentTab={confirm=false}}},
        --SUPER	m	Hide
        --SUPER	n	SpawnWindow
        --CTRL+SHIFT	n	SpawnWindow
        --ALT	Enter	ToggleFullScreen

        -- Pane navigation
        { key = "h", mods = "LEADER",       action=wezterm.action{ActivatePaneDirection="Left"}},
        { key = "j", mods = "LEADER",       action=wezterm.action{ActivatePaneDirection="Down"}},
        { key = "k", mods = "LEADER",       action=wezterm.action{ActivatePaneDirection="Up"}},
        { key = "l", mods = "LEADER",       action=wezterm.action{ActivatePaneDirection="Right"}},
        { key = "LeftArrow", mods = "CTRL", action=wezterm.action{ActivatePaneDirection="Left"}},
        { key = "DownArrow", mods = "CTRL", action=wezterm.action{ActivatePaneDirection="Down"}},
        { key = "UpArrow", mods = "CTRL",   action=wezterm.action{ActivatePaneDirection="Up"}},
        { key = "RightArrow", mods = "CTRL",action=wezterm.action{ActivatePaneDirection="Right"}},

        -- Tab navigation
        { key = "z", mods = "LEADER",       action="TogglePaneZoomState" },
        { key = "0", mods = "LEADER",       action=wezterm.action{ActivateTab=0}},
        { key = "1", mods = "LEADER",       action=wezterm.action{ActivateTab=1}},
        { key = "2", mods = "LEADER",       action=wezterm.action{ActivateTab=2}},
        { key = "3", mods = "LEADER",       action=wezterm.action{ActivateTab=3}},
        { key = "4", mods = "LEADER",       action=wezterm.action{ActivateTab=4}},
        { key = "5", mods = "LEADER",       action=wezterm.action{ActivateTab=5}},
        { key = "6", mods = "LEADER",       action=wezterm.action{ActivateTab=6}},
        { key = "7", mods = "LEADER",       action=wezterm.action{ActivateTab=7}},
        { key = "8", mods = "LEADER",       action=wezterm.action{ActivateTab=8}},
        { key = "9", mods = "LEADER",       action="ShowTabNavigator"},
        { key = "b", mods = "LEADER|CTRL",  action="ActivateLastTab"},
        { key = "LeftArrow", mods = "SHIFT",    action=wezterm.action{ActivateTabRelative=-1}},
        { key = "RightArrow", mods = "SHIFT",   action=wezterm.action{ActivateTabRelative=1}},
        { key = "LeftArrow", mods = "CTRL|SHIFT",    action=wezterm.action{MoveTabRelative=-1}},
        { key = "RightArrow", mods = "CTRL|SHIFT",   action=wezterm.action{MoveTabRelative=1}},

        -- Resize
        { key = "H", mods = "LEADER|SHIFT", action=wezterm.action{AdjustPaneSize={"Left", 5}}},
        { key = "J", mods = "LEADER|SHIFT", action=wezterm.action{AdjustPaneSize={"Down", 5}}},
        { key = "K", mods = "LEADER|SHIFT", action=wezterm.action{AdjustPaneSize={"Up", 5}}},
        { key = "L", mods = "LEADER|SHIFT", action=wezterm.action{AdjustPaneSize={"Right", 5}}},

        -- Split
        { key = "-", mods = "LEADER",       action=wezterm.action{SplitVertical={domain="CurrentPaneDomain"}}},
        { key = "_", mods = "LEADER",       action=wezterm.action{SplitVertical={domain="CurrentPaneDomain"}}},
        { key = "\\",mods = "LEADER",       action=wezterm.action{SplitHorizontal={domain="CurrentPaneDomain"}}},
        { key = "|",mods = "LEADER|SHIFT",  action=wezterm.action{SplitHorizontal={domain="CurrentPaneDomain"}}},

        -- Scroll/search buffer
        --SHIFT	PageUp	ScrollByPage=-1
        --SHIFT	PageDown	ScrollByPage=1
        --SUPER	k	ClearScrollback="ScrollbackOnly"
        --CTRL+SHIFT	K	ClearScrollback="ScrollbackOnly"
        --SUPER	f	Search={CaseSensitiveString=""}
        --CTRL+SHIFT	F	Search={CaseSensitiveString=""}

        -- Copy/paste buffer
        { key = "[",mods = "LEADER",  action="ActivateCopyMode"},
        { key = " ",mods = "LEADER",  action="QuickSelect"},
        --SUPER	c	CopyTo="Clipboard"
        --SUPER	v	PasteFrom="Clipboard"
        --CTRL+SHIFT	c	CopyTo="Clipboard"
        --CTRL+SHIFT	v	PasteFrom="Clipboard"
        --CTRL	Insert	CopyTo="PrimarySelection" ()
        --SHIFT	Insert	PasteFrom="PrimarySelection"
        --CTRL+SHIFT	X	ActivateCopyMode
        --CTRL+SHIFT	(Space)	QuickSelect (since: 20210502-130208-bff6815d)

        -- Fonts
        --SUPER	-	DecreaseFontSize
        --CTRL	-	DecreaseFontSize
        --SUPER	=	IncreaseFontSize
        --CTRL	=	IncreaseFontSize
        --SUPER	0	ResetFontSize
        --CTRL	0	ResetFontSize
        --CTRL	Z	TogglePaneZoomState

        -- Misc
        --SUPER	r	ReloadConfiguration
        --CTRL+SHIFT	R	ReloadConfiguration
        --CTRL+SHIFT	L	ShowDebugOverlay (Since: 20210814-124438-54e29167)
    },
    set_environment_variables = {},

    -- Tab bar appearance
    colors = {
        tab_bar = {

            -- The color of the strip that goes along the top of the window
            background = "#282828",

            -- The active tab is the one that has focus in the window
            active_tab = {
                -- The color of the background area for the tab
                bg_color = "#282828",
                -- The color of the text for the tab
                fg_color = "#fe8019",
                intensity = "Normal",
                underline = "None",
                italic = false,
                strikethrough = false,
            },

            -- Inactive tabs are the tabs that do not have focus
            inactive_tab = {
                bg_color = "#282828",
                fg_color = "#a89984",
            },
            inactive_tab_hover = {
                bg_color = "#282828",
                fg_color = "#a89984",
            },

            new_tab = {
                bg_color = "#282828",
                fg_color = "#458588",
            },
            new_tab_hover = {
                bg_color = "#282828",
                fg_color = "#808080",
            },
        },
    },
}

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
    config.term = "" -- Set to empty so FZF works on windows
    table.insert(config.launch_menu, { label = "PowerShell 5", args = {"powershell.exe", "-NoLogo"} })
    --table.insert(config.launch_menu, { label = "PowerShell", args = {"pwsh.exe", "-NoLogo"} })
    table.insert(config.launch_menu, { label = "VS PowerShell 2022", args = {"powershell.exe", "-NoLogo", "-NoExit", "-Command", "devps 17.0"} })
    table.insert(config.launch_menu, { label = "VS PowerShell 2019", args = {"powershell.exe", "-NoLogo", "-NoExit", "-Command", "devps 16.0"} })
    table.insert(config.launch_menu, { label = "Command Prompt", args = {"cmd.exe"} })
    table.insert(config.launch_menu, { label = "VS Command Prompt 2022", args = {"powershell.exe", "-NoLogo", "-NoExit", "-Command", "devcmd 17.0"} })
    table.insert(config.launch_menu, { label = "VS Command Prompt 2019", args = {"powershell.exe", "-NoLogo", "-NoExit", "-Command", "devcmd 16.0"} })
else
    table.insert(config.launch_menu, { label = "zsh", args = {"zsh", "-l"} })
end

-- Equivalent to POSIX basename(3)
-- Given "/foo/bar" returns "bar"
-- Given "c:\\foo\\bar" returns "bar"
function basename(s)
  return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local pane = tab.active_pane
  local title = basename(pane.foreground_process_name)
  return {
    {Text=" " .. title .. " "},
  }
end)

return config
