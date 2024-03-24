JSON = ved_require(VLIB_PLUGIN_PATH .. "json")

VLIB_STATE = nil

VLIB_ACCUMULATOR = 0

VLIB_READY = false

VLIB_DOWNLOADING = false
VLIB_DOWNLOAD_TYPE = "file"

VLIB_GHOSTS = {}

VLIB_FLAGS = {}
for i = 1, 100 do
    VLIB_FLAGS[i] = false
end

VLIB_GHOST_CANVAS = love.graphics.newCanvas(320, 240)

VLIB_InitializeSettings()

VLIB_LaunchNetworkingThread()

VLIB_DownloadData(function()
    if VLIB_SETTINGS.path ~= nil then
        VLIB_LaunchGameInThread()
    else
        VLIB_CheckOrDownload(function()
            VLIB_DOWNLOADING = false
            VLIB_LaunchGameInThread()
        end)
    end
end)
