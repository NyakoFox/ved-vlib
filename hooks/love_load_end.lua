JSON = ved_require(VLIB_PLUGIN_PATH .. "json")

VLIB_STATE = nil

VLIB_ACCUMULATOR = 0

VLIB_READY = false

VLIB_FLAGS = {}
for i = 1, 100 do
    VLIB_FLAGS[i] = false
end

VLIB_InitializeSettings()

VLIB_LaunchNetworkingThread()

-- check if VLIB_PLUGIN_PATH starts with plugins-zip
if string.find(VLIB_PLUGIN_PATH, "plugins%-zip") then
    dialog.create("Using VLIB as a .zip file is currently not supported. Please extract the contents of the .zip file to a folder and try again.", DBS.OK)
    return
end

if VLIB_SETTINGS.path ~= nil then
    VLIB_LaunchGameInThread()
else
    VLIB_CheckOrDownload(function()
        VLIB_LaunchGameInThread()
    end)
end
