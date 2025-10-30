t = ...  -- Required for this info file to work.

t.shortname = "VLIB"  -- The name that will be displayed on the button in the plugins list. Should be no longer than 21 characters, or it will be wider than the button.
t.longname = "VLIB"  -- This can be about twice as long
t.author = "NyakoFox"  -- Your name
t.version = "1.4.1"  -- The current version of this plugin, can be anything you want
t.minimumved = "1.11.1"  -- The minimum version of Ved this plugin is designed to work with. If unsure, just use the latest version.
t.description = [[
VVVVVV playtesting inside of Ved.
]]  -- The description that will be displayed in the plugins list. This uses the help/notepad system, so you can use text formatting here, and even images!
VLIB_PLUGIN_PATH = t.internal_pluginpath .. "/"
