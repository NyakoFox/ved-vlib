ved_require(VLIB_PLUGIN_PATH .. "utils")
ved_require(VLIB_PLUGIN_PATH .. "callbacks")
ved_require(VLIB_PLUGIN_PATH .. "draw")

function VLIB_GetTexture(texture)
    if (texture == "main") then
        return VLIB_canvas_main
    end

    local canvas = VLIB_canvases[texture]
    if canvas == nil then
        -- if it starts with font_main_
        if string.sub(texture, 1, 10) == "font_main_" then
            local font = string.sub(texture, 11)
            local font_canvas = VLIB_canvases[texture]
            if font_canvas == nil then
                if fonts_main[font] == nil then
                    if fonts_main["main"] == nil then
                        error("Font " .. font .. " not found, nor was the main font.")
                    end
                    cons("Font " .. font .. " not found, using main font instead.")
                    font_canvas = fonts_main["main"].image
                else
                    font_canvas = fonts_main[font].image
                end
                VLIB_canvases[texture] = font_canvas
            end
            return font_canvas
        end
        -- if it starts with font_custom_
        if string.sub(texture, 1, 12) == "font_custom_" then
            local font = string.sub(texture, 13)
            local font_canvas = VLIB_canvases[texture]
            if font_canvas == nil then
                if fonts_custom[font] == nil then
                    if fonts_custom["main"] == nil then
                        error("Font " .. font .. " not found, nor was the main font.")
                    end
                    cons("Font " .. font .. " not found, using main font instead.")
                    font_canvas = fonts_custom["main"].image
                else
                    font_canvas = fonts_custom[font].image
                end
                VLIB_canvases[texture] = font_canvas
            end
            return font_canvas
        end
        error("Canvas not found: " .. texture)
    end
    return canvas
end

function VLIB_SetupCanvases()
    VLIB_canvas_main = love.graphics.newCanvas(320, 240)

    VLIB_canvases = {
        gameTexture = love.graphics.newCanvas(320, 240),
        gameplayTexture = love.graphics.newCanvas(320, 240),
        menuTexture = love.graphics.newCanvas(320, 240),
        ghostTexture = love.graphics.newCanvas(320, 240),
        tempShakeTexture = love.graphics.newCanvas(320, 240),
        foregroundTexture = love.graphics.newCanvas(320, 240),
        backgroundTexture = love.graphics.newCanvas(320 + 16, 240 + 16),
        tempScrollingTexture = love.graphics.newCanvas(320 + 16, 240 + 16),
        towerbgTexture = love.graphics.newCanvas(320 + 16, 240 + 16),
        titlebgTexture = love.graphics.newCanvas(320 + 16, 240 + 16),
        generatedMinimapTexture = love.graphics.newCanvas(240, 180),
        spritesTexture = tilesets["sprites.png"].white_img,
        tilesTexture = tilesets["tiles.png"].img,
        tilesWhiteTexture = tilesets["tiles.png"].white_img,
        tiles2Texture = tilesets["tiles2.png"].img,
        tiles3Texture = tilesets["tiles3.png"].img,
        teleporterTexture = tilesets["teleporter.png"].white_img,
        entcoloursTexture = tilesets["entcolours.png"].img,
        image0Texture = tilesets["levelcomplete.png"].img,
        image1Texture = tilesets["minimap.png"].img,
        image2Texture = tilesets["covered.png"].img,
        image3Texture = tilesets["elephant.png"].white_img,
        image4Texture = tilesets["gamecomplete.png"].img,
        image5Texture = VLIB_LoadFile("fliplevelcomplete"),
        image6Texture = VLIB_LoadFile("flipgamecomplete"),
        image7Texture = VLIB_LoadFile("site", true),
        image8Texture = VLIB_LoadFile("site2", true),
        image9Texture = VLIB_LoadFile("site3", true),
        image10Texture = VLIB_LoadFile("ending"),
        image11Texture = VLIB_LoadFile("site4", true)
    }

    -- Oh, let's loop through fonts as well.
    for name, font in pairs(fonts_main) do
        VLIB_canvases["font_main_" .. name] = font.image
    end

    for name, font in pairs(fonts_custom) do
        VLIB_canvases["font_custom_" .. name] = font.image
    end

    VLIB_texture_colors = {}
    for name, _ in pairs(VLIB_canvases) do
        VLIB_texture_colors[name] = {255, 255, 255, 255}
    end
end

function VLIB_LoadFile(name, make_white)
    -- TODO: level specific assets!!!!!!!!!!!!!!!!
    local img = love.image.newImageData(VLIB_PLUGIN_PATH .. "graphics/" .. name .. ".png")
    if make_white then
        img:mapPixel(function(x, y, r, g, b, a)
            return 255, 255, 255, a
        end)
    end
    return love.graphics.newImage(img)
end

local DRAW_NONE = -1
local DRAW_RECT = 0
local DRAW_LINE = 1
local DRAW_CIRCLE = 2
local DRAW_TEXT = 3
local DRAW_SET_COLOR = 4
local DRAW_FILL_RECT = 5
local DRAW_CLEAR = 6
local DRAW_SET_TARGET = 7
local DRAW_TEXTURE = 8
local DRAW_TEXTURE_EXT = 9
local DRAW_SET_TINT_COLOR = 10
local DRAW_SET_TINT_ALPHA = 11

function VLIB_DrawGame()
    VLIB_CHANNEL_IN:push({
        type = "delta",
        delta = VLIB_SETTINGS.over30 and (VLIB_ACCUMULATOR / (VLIB_SETTINGS.game_speed / 1000)) or 1
    })

    -- wait until vvvvvv_channel_out_signal has a message saying its fine to render
    while true do
        local message = VLIB_CHANNEL_OUT_SIGNAL:demand()
        if (message.type == "render") then
            break
        end
    end

    love.graphics.push()
    love.graphics.reset()
    love.graphics.setDefaultFilter("nearest", "nearest", 1)
    love.graphics.setCanvas(VLIB_canvas_main)

    local messages = {}
    while VLIB_CHANNEL_OUT_DRAW:getCount() > 0 do
        local message = VLIB_CHANNEL_OUT_DRAW:pop()
        -- insert to front
        table.insert(messages, 1, message)
    end

    for _, message in ipairs(messages) do
        if message.type == DRAW_SET_COLOR then
            love.graphics.setColor(message.color_r, message.color_g, message.color_b, message.color_a)
        elseif message.type == DRAW_SET_TINT_COLOR then
            local color = VLIB_texture_colors[message.texture]
            if color ~= nil then
                color[1] = message.color_r
                color[2] = message.color_g
                color[3] = message.color_b
            else
                VLIB_texture_colors[message.texture] = {message.color_r, message.color_g, message.color_b, 255}
            end
        elseif message.type == DRAW_SET_TINT_ALPHA then
            local color = VLIB_texture_colors[message.texture]
            if color ~= nil then
                color[4] = message.color_a
            else
                VLIB_texture_colors[message.texture] = {255, 255, 255, message.color_a}
            end
        elseif message.type == DRAW_LINE then
            love.graphics.setLineWidth(1)
            love.graphics.line(message.p1_x + 0.5, message.p1_y + 0.5, message.p2_x + 0.5, message.p2_y + 0.5)
        elseif message.type == DRAW_RECT then
            love.graphics.setLineWidth(1)
            -- do the same for dest
            local dest = {}
            if (message.dest_whole) then
                dest.x = 0
                dest.y = 0
                dest.w = love.graphics.getCanvas():getWidth()
                dest.h = love.graphics.getCanvas():getHeight()
            else
                dest.x = message.dest_x
                dest.y = message.dest_y
                dest.w = message.dest_w
                dest.h = message.dest_h
            end

            love.graphics.rectangle("line", dest.x + 0.5, dest.y + 0.5, dest.w - 1, dest.h - 1)
        elseif message.type == DRAW_FILL_RECT then
            -- do the same for dest
            local dest = {}
            if (message.dest_whole) then
                dest.x = 0
                dest.y = 0
                dest.w = love.graphics.getCanvas():getWidth()
                dest.h = love.graphics.getCanvas():getHeight()
            else
                dest.x = message.dest_x
                dest.y = message.dest_y
                dest.w = message.dest_w
                dest.h = message.dest_h
            end

            love.graphics.rectangle("fill", dest.x, dest.y, dest.w, dest.h)
        elseif message.type == DRAW_CLEAR then
            love.graphics.clear(love.graphics.getColor())
        elseif message.type == DRAW_SET_TARGET then
            love.graphics.setCanvas(VLIB_GetTexture(message.texture))
        elseif message.type == DRAW_TEXTURE then
            -- uses src and dest. src is the rectangle of the texture to draw, dest is the rectangle to draw it to
            local texture = VLIB_GetTexture(message.texture)

            local texture_width = texture:getWidth()
            local texture_height = texture:getHeight()

            local src = {}
            local quad
            if (message.src_whole) then
                quad = love.graphics.newQuad(0, 0, texture_width, texture_height, texture_width, texture_height)
                src = {x = 0, y = 0, w = texture_width, h = texture_height}
            else
                quad = love.graphics.newQuad(message.src_x, message.src_y, message.src_w, message.src_h, texture_width, texture_height)
                src.x = message.src_x
                src.y = message.src_y
                src.w = message.src_w
                src.h = message.src_h
            end

            -- do the same for dest
            local dest = {}
            if (message.dest_whole) then
                dest.x = 0
                dest.y = 0
                dest.w = love.graphics.getCanvas():getWidth()
                dest.h = love.graphics.getCanvas():getHeight()
            else
                dest.x = message.dest_x
                dest.y = message.dest_y
                dest.w = message.dest_w
                dest.h = message.dest_h
            end

            local scale_x = dest.w / src.w
            local scale_y = dest.h / src.h

            local old_r, old_g, old_b, old_a = love.graphics.getColor()
            love.graphics.setColor(VLIB_texture_colors[message.texture] or {255, 255, 255, 255})
            love.graphics.draw(texture, quad, dest.x, dest.y, 0, scale_x, scale_y)
            love.graphics.setColor(old_r, old_g, old_b, old_a)
        elseif message.type == DRAW_TEXTURE_EXT then
            -- optional angle, center point and flip parameters
            local texture = VLIB_GetTexture(message.texture)

            local texture_width = texture:getWidth()
            local texture_height = texture:getHeight()

            local src = {}
            local quad
            if (message.src_whole) then
                quad = love.graphics.newQuad(0, 0, texture_width, texture_height, texture_width, texture_height)
                src = {x = 0, y = 0, w = texture_width, h = texture_height}
            else
                quad = love.graphics.newQuad(message.src_x, message.src_y, message.src_w, message.src_h, texture_width, texture_height)
                src.x = message.src_x
                src.y = message.src_y
                src.w = message.src_w
                src.h = message.src_h
            end

            -- do the same for dest
            local dest = {}
            if (message.dest_whole) then
                dest.x = 0
                dest.y = 0
                dest.w = love.graphics.getCanvas():getWidth()
                dest.h = love.graphics.getCanvas():getHeight()
            else
                dest.x = message.dest_x
                dest.y = message.dest_y
                dest.w = message.dest_w
                dest.h = message.dest_h
            end

            local scale_x = dest.w / src.w
            local scale_y = dest.h / src.h

            local angle = message.angle or 0
            local center = message.center or {x = 0, y = 0}
            local flip_x = message.flip_x and -1 or 1
            local flip_y = message.flip_y and -1 or 1

            local old_r, old_g, old_b, old_a = love.graphics.getColor()
            love.graphics.setColor(VLIB_texture_colors[message.texture] or {255, 255, 255, 255})
            love.graphics.draw(texture, quad, dest.x, dest.y, angle, scale_x * flip_x, scale_y * flip_y, center.x, center.y)
            love.graphics.setColor(old_r, old_g, old_b, old_a)
        end
    end

    love.graphics.setCanvas()
    love.graphics.pop()

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(VLIB_canvas_main, screenoffset, 0, 0, 2)
end

function VLIB_Set(option, value)
    VLIB_SETTINGS[option] = value
    VLIB_SaveSettings()
end

function VLIB_SaveSettings()
    local success, message = pcall(love.filesystem.write, VLIB_PLUGIN_PATH .. "settings.json", JSON.encode(VLIB_SETTINGS))
    if not success then
        cons("Error saving settings: " .. message)
    end
    if VLIB_READY then
        VLIB_SETTINGS.type = "settings"
        VLIB_SETTINGS.ved_translucent_bg = not s.opaqueroomnamebackground
        VLIB_CHANNEL_IN:push(VLIB_SETTINGS)
        VLIB_SETTINGS.type = nil
        VLIB_SETTINGS.ved_translucent_bg = nil
    end
end

function VLIB_InitializeSettings()

    VLIB_SETTINGS = {
        download = true,
        path = nil,
        invincibility = false,
        over30 = true,
        game_speed = 34,
        music_volume = 256,
        sfx_volume = 256,
        translucent_bg = nil,
        last_version = nil,
        base_vlib_url = "https://api.github.com/repos/NyakoFox/VVVVVV/actions/",
        vlib_action = "CI",
        show_ghosts = false
    }

    local settings_path = VLIB_PLUGIN_PATH .. "settings.json"
    if love.filesystem.exists(settings_path) then
        VLIB_SETTINGS = VLIB_Merge(VLIB_SETTINGS, JSON.decode(love.filesystem.read(settings_path)))
    end

    VLIB_SaveSettings()
end

function VLIB_LaunchNetworkingThread()

    VLIB_HTTPS = {
        in_channel = nil,
        out_channel = nil,
        thread = nil,

        next_key = 0,
        waiting = 0,
        end_funcs = {}
    }

    VLIB_HTTPS.in_channel = love.thread.getChannel("vlib_https_in")
    VLIB_HTTPS.out_channel = love.thread.getChannel("vlib_https_out")
    VLIB_HTTPS.thread = love.thread.newThread(VLIB_PLUGIN_PATH .. "networkingthread.lua")
    VLIB_HTTPS.thread:start(love.filesystem.getSaveDirectory(), VLIB_PLUGIN_PATH)
end

function VLIB_LaunchGameInThread()
    VLIB_THREAD = love.thread.newThread(VLIB_PLUGIN_PATH .. "playtestthread.lua")
    VLIB_THREAD:start(love.filesystem.getSaveDirectory(), VLIB_PLUGIN_PATH, VLIB_SETTINGS)

    VLIB_CHANNEL_IN = love.thread.getChannel("vlib_in")
    VLIB_CHANNEL_OUT = love.thread.getChannel("vlib_out")
    VLIB_CHANNEL_OUT_SIGNAL = love.thread.getChannel("vlib_out_signal")
    VLIB_CHANNEL_OUT_DRAW = love.thread.getChannel("vlib_out_draw")

    VLIB_SETTINGS.type = "settings"
    VLIB_CHANNEL_IN:push(VLIB_SETTINGS)
    VLIB_SETTINGS.type = nil

    VLIB_CHANNEL_IN:push({
        type = "set_base_path",
        path = love.filesystem.getSaveDirectory() .. "/env/"
    })


    VLIB_CHANNEL_IN:push({
        type = "start"
    })

    VLIB_READY = true
end

function VLIB_StartLevel(thisroomx, thisroomy, posx, posy, gravitycontrol, music)
    VLIB_SetupCanvases()

    for name, texture in pairs(VLIB_canvases) do
        if type(texture) == "userdata" then
            local w, h = texture:getDimensions()
            VLIB_CHANNEL_IN:push({
                type = "set_texture_size",
                name = name,
                w = w,
                h = h
            })
        end
    end
    VLIB_CHANNEL_IN:push({
        type = "set_texture_size",
        name = "main",
        w = VLIB_canvas_main:getWidth(),
        h = VLIB_canvas_main:getHeight()
    })

    VLIB_CHANNEL_IN:push(
        {
            type = "data_pos",
            x = posx,
            y = posy,
            rx = thisroomx,
            ry = thisroomy,
            gc = gravitycontrol,
            music = music
        }
    )
    VLIB_CHANNEL_IN:push({ type = "start_level", editingmap = editingmap, translucent_bg = not s.opaqueroomnamebackground })
    to_astate("vlib_playtesting")
end

function VLIB_fetch(url, callback)
    VLIB_HTTPS.waiting = VLIB_HTTPS.waiting + 1

    if callback then
        VLIB_HTTPS.next_key = VLIB_HTTPS.next_key + 1
        VLIB_HTTPS.end_funcs[VLIB_HTTPS.next_key] = callback
    end

    VLIB_HTTPS.in_channel:push({
        url = url,
        key = VLIB_HTTPS.next_key,
    })

    VLIB_HTTPS.next_key = VLIB_HTTPS.next_key + 1
end

function VLIB_DownloadData(callback)
    if love.filesystem.exists("env/data.zip") then
        callback()
    else
        love.filesystem.createDirectory("env")
        dialog.create(
            "Download data.zip? This is required for VVVVVV to run.",
            DBS.OKCANCEL,
            function(button)
                if button == DB.OK then
                    VLIB_DOWNLOADING = true
                    VLIB_DOWNLOAD_TYPE = "data.zip"
                    VLIB_fetch("https://thelettervsixtim.es/makeandplay/data.zip", function(response)
                        local success, message = love.filesystem.write("env/data.zip", response)
                        VLIB_DOWNLOADING = false
                        if not success then
                            dialog.create("Failed to download data.zip -- " .. message, DBS.OK)
                            return
                        end
                        dialog.create("data.zip has been downloaded.", DBS.OK,
                            function()
                                callback()
                            end
                        )
                    end)
                else
                    dialog.create("Playtesting will not be available for this session.", DBS.OK)
                end
            end
        )
    end
end

function VLIB_CheckOrDownload(callback)
    local filename = VLIB_GetWantedLibraryName()
    -- Alright, is this in libs?
    if love.filesystem.exists("libs/" .. filename) then
        -- It is, we're good to continue
        VLIB_GetAction(function(action)
            if action.id ~= VLIB_SETTINGS.last_version then
                dialog.create(
                    "A new version of VVVVVV is available. Would you like to download it?",
                    DBS.YESNO,
                    function(button)
                        if button == DB.YES then
                            VLIB_Download(callback)
                        else
                            if callback then
                                callback()
                            end
                        end
                    end
                )
            else
                if callback then
                    callback()
                end
            end
        end)
    else
        -- Nope, downloading time

        dialog.create(
            "Ved will now download a copy of VVVVVV.",
            DBS.OKCANCEL,
            function(button)
                if button == DB.OK then
                    VLIB_Download(callback)
                elseif button == DB.CANCEL then
                    dialog.create("VVVVVV will not be available for this session.", DBS.OK)
                end
            end
        )
    end
end

function VLIB_GetAction(callback)
    VLIB_fetch(VLIB_SETTINGS.base_vlib_url .. "runs?branch=vlib&status=success&per_page=20", function(response)
        local decoded = JSON.decode(response)
        local list = decoded.workflow_runs
        local vlib_action = nil
        local vlib_loc_action = nil
        for i = 1, #list do
            if (not vlib_action) and list[i].name == VLIB_SETTINGS.vlib_action then
                vlib_action = list[i]
            end
            if (not vlib_loc_action) and list[i].name == "CI-loc" then
                vlib_loc_action = list[i]
            end
        end
        callback(vlib_action, vlib_loc_action)
    end)
end

function VLIB_Download(callback)
    VLIB_GetAction(function (action, loc_action)
        if not action then
            love.window.showMessageBox("Error", "Failed to download VVVVVV", "error")
            return
        end

        VLIB_DownloadLocalizationFiles(loc_action, function()
            VLIB_DownloadLibrary(action, callback)
        end)
    end)
end

function VLIB_DownloadLocalizationFiles(loc_action, callback)
    local count = 0
    local max_count = 2

    VLIB_DOWNLOADING = true
    VLIB_DOWNLOAD_TYPE = "localization files"

    VLIB_fetch(VLIB_SETTINGS.base_vlib_url .. "runs/" .. loc_action.id .. "/artifacts", function(response)
        -- Grabbing artifact information
        local decoded = JSON.decode(response)
        local list = decoded.artifacts
        max_count = #list
        local failed = false
        for i = 1, #list do
            if failed then
                VLIB_DOWNLOADING = false
                break
            end
            -- download both artifacts
            local current_artifact = list[i]
            local base_download_url = current_artifact.archive_download_url
            local download_url = string.gsub(base_download_url, "api.github.com/repos", "nightly.link")
            download_url = string.gsub(download_url, "/zip", ".zip")

            VLIB_DOWNLOAD_TYPE = current_artifact.name .. " folder"
            cons("Downloading " .. current_artifact.name .. " folder from " .. download_url)

            -- make the temp dir
            if not love.filesystem.exists(love.filesystem.getSaveDirectory() .. "/temp") then
                love.filesystem.createDirectory("temp")
            end

            local download_path = "/temp/" .. current_artifact.name .. ".zip"

            VLIB_fetch(download_url, function(response)
                -- response should be a file!
                local success, message = love.filesystem.write(download_path, response)

                if not success then
                    failed = true
                    love.window.showMessageBox("Error", "Failed to download " .. current_artifact.name .. " folder -- " .. message, "error")
                    return
                end

                -- Mount the file we just downloaded
                local success, message = love.filesystem.mount(download_path, "/temp/" .. current_artifact.name .. ".zip")
                if not success then
                    failed = true
                    love.window.showMessageBox("Error", "Failed to mount downloaded library -- " .. message, "error")
                    return
                end

                -- Copy the files from the mounted directory to Ved's save directory under "env/name"
                love.filesystem.createDirectory("env")
                love.filesystem.createDirectory("env/" .. current_artifact.name)

                local files = love.filesystem.getDirectoryItems("/temp/" .. current_artifact.name)
                for i = 1, #files do
                    local file = files[i]
                    local success, message = love.filesystem.write("env/" .. current_artifact.name .. "/" .. file, love.filesystem.read("/temp/" .. current_artifact.name .. "/" .. file))
                    if not success then
                        love.window.showMessageBox("Error", "Failed to copy downloaded library -- " .. message, "error")
                        love.filesystem.unmount("/temp/" .. current_artifact.name .. ".zip")
                        failed = true
                        return
                    end
                end

                -- Unmount the file
                love.filesystem.unmount("/temp/" .. current_artifact.name .. ".zip")

                count = count + 1
                if count >= max_count then
                    if callback then
                        callback()
                    end
                end
            end)
        end
    end)
end

function VLIB_DownloadLibrary(action, callback)
    VLIB_DOWNLOADING = true
    VLIB_DOWNLOAD_TYPE = "VVVVVV"
    VLIB_fetch(VLIB_SETTINGS.base_vlib_url .. "runs/" .. action.id .. "/artifacts", function(response)
        -- Grabbing artifact information
        local decoded = JSON.decode(response)
        local list = decoded.artifacts

        local artifact = nil
        local wanted_name = VLIB_GetWantedArtifactName()
        for i = 1, #list do
            local current_artifact = list[i]
            if current_artifact.name == wanted_name then
                artifact = current_artifact
                break
            end
        end
        if not artifact then
            love.window.showMessageBox("Error", "Failed to download VVVVVV -- No artifact found for OS!", "error")
            VLIB_DOWNLOADING = false
            return
        end

        -- ASSEMBLE A DOWNLOAD LINK!

        local base_download_url = artifact.archive_download_url
        -- Turn our returned download link into a nightly.link download link
        local download_url = string.gsub(base_download_url, "api.github.com/repos", "nightly.link")
        download_url = string.gsub(download_url, "/zip", ".zip")

        -- Download the file
        -- if temp doesn't exist, let's make it lol
        if not love.filesystem.exists(love.filesystem.getSaveDirectory() .. "/temp") then
            love.filesystem.createDirectory("temp")
        end

        local download_path = "/temp/" .. wanted_name .. ".zip"

        cons("Downloading VVVVVV from " .. download_url)

        VLIB_fetch(download_url, function(response)
            -- response should be a file!
            local success, message = love.filesystem.write(download_path, response)

            if not success then
                love.window.showMessageBox("Error", "Failed to download VVVVVV -- " .. message, "error")
                VLIB_DOWNLOADING = false
                return
            end

            -- Mount the file we just downloaded
            local success, message = love.filesystem.mount(download_path, "/temp/" .. wanted_name)
            if not success then
                love.window.showMessageBox("Error", "Failed to mount downloaded library -- " .. message, "error")
                VLIB_DOWNLOADING = false
                return
            end

            -- Copy the files from the mounted directory to Ved's save directory under "libs"
            love.filesystem.createDirectory("libs")

            local files = love.filesystem.getDirectoryItems("/temp/" .. wanted_name)
            if #files ~= 1 then
                love.window.showMessageBox("Error", "Failed to copy downloaded library -- " .. "Expected 1 file, got " .. #files, "error")
                love.filesystem.unmount("/temp/" .. wanted_name)
                VLIB_DOWNLOADING = false
                return
            end

            local file = files[1]
            local success, message = love.filesystem.write("libs/" .. VLIB_GetWantedLibraryName(), love.filesystem.read("/temp/" .. wanted_name .. "/" .. file))

            if not success then
                love.window.showMessageBox("Error", "Failed to copy downloaded library -- " .. message, "error")
                love.filesystem.unmount("/temp/" .. wanted_name)
                VLIB_DOWNLOADING = false
                return
            end

            -- Unmount the file
            love.filesystem.unmount("/temp/" .. wanted_name)

            -- Save the settings
            VLIB_Set("last_version", action.id)

            VLIB_DOWNLOADING = false

            dialog.create(
                "VVVVVV has been downloaded.",
                DBS.OK,
                function()
                    if callback then
                        callback()
                    end
                end
            )
        end)
    end)
end