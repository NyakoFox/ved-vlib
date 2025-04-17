JSON = ved_require(VLIB_PLUGIN_PATH .. "json")

-- MUST MATCH THE VERSION IN VLIB!
VLIB_VERSION = 1

VLIB_STATE = nil

VLIB_ACCUMULATOR = 0

VLIB_READY = false
VLIB_READY_TO_LISTEN = false
VLIB_UNAVAILABLE = false
VLIB_SESSION_DISABLED = false

VLIB_DOWNLOADING = false
VLIB_DOWNLOAD_TYPE = "file"

VLIB_TAKE_SCREENSHOT = false
VLIB_SCREENSHOT_SUCCESS = false
VLIB_SCREENSHOT_TIMER = 0
VLIB_SCREENSHOT_TIMER_MAX = 0.4

VLIB_GHOSTS = {}

VLIB_FLAGS = {}
for i = 1, 100 do
    VLIB_FLAGS[i] = false
end

VLIB_GHOST_CANVAS = love.graphics.newCanvas(320, 240)

VLIB_IMAGE_PLAY = love.graphics.newImage(VLIB_PLUGIN_PATH .. "images/vlib_play_hq.png")
VLIB_IMAGE_PLAY:setFilter("nearest", "nearest")

VLIB_IMAGE_PLAYSTOP = love.graphics.newImage(VLIB_PLUGIN_PATH .. "images/vlib_playstop_hq.png")
VLIB_IMAGE_PLAYSTOP:setFilter("nearest", "nearest")

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
