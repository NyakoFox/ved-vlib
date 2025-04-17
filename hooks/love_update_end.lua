local dt = ...

VLIB_SCREENSHOT_TIMER = math.max(VLIB_SCREENSHOT_TIMER - dt, 0)

if VLIB_TAKE_SCREENSHOT then
    VLIB_TAKE_SCREENSHOT = false

    local image_data = VLIB_canvas_main:newImageData()

    if not image_data then
        return VLIB_DisplayScreenshot(false)
    end

    -- FIRST: create "screenshots" if it doesn't exist
    if not love.filesystem.exists("screenshots") then
        love.filesystem.createDirectory("screenshots")
    end

    local name = "screenshot_".. os.date("%Y-%m-%d_%H-%M-%S")
    local i = 1
    while love.filesystem.exists("screenshots/" .. name .. ".png") do
        i = i + 1
        name = "screenshot_".. os.date("%Y-%m-%d_%H-%M-%S") .. "_" .. i
    end

    local filedata = image_data:encode("png", "screenshots/" .. name .. ".png")

    if not filedata then
        return VLIB_DisplayScreenshot(false)
    end

    -- Not as important, but... save the 2x screenshot

    -- (draw code in update... scary)

    local image_data_2x = love.graphics.newCanvas(640, 480)

    love.graphics.push()
    love.graphics.reset()
    love.graphics.origin()
    love.graphics.setCanvas(image_data_2x)
    love.graphics.clear()
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(VLIB_canvas_main, 0, 0, 0, 2, 2)
    love.graphics.setCanvas()

    name = name .. "_2x"

    image_data_2x:newImageData():encode("png", "screenshots/" .. name .. ".png")
    love.graphics.pop()

    VLIB_DisplayScreenshot(true)
end

if VLIB_READY and not (s.pausedrawunfocused and not window_active()) then
    VLIB_ACCUMULATOR = VLIB_ACCUMULATOR + dt
    while VLIB_ACCUMULATOR >= (VLIB_SETTINGS.game_speed / 1000) do
        VLIB_ACCUMULATOR = VLIB_ACCUMULATOR - (VLIB_SETTINGS.game_speed / 1000)

        VLIB_CHANNEL_IN:push({
            type = "update"
        })
    end
end

if VLIB_READY_TO_LISTEN then
    while VLIB_CHANNEL_OUT:getCount() > 0 do
        local message = VLIB_CHANNEL_OUT:pop()
        if message.type == "start" then
            -- Ok, VVVVVV is ready... but let's check the version
            if message.version ~= VLIB_VERSION then
                dialog.create("VLIB version mismatch! Expected " .. VLIB_VERSION .. ", got " .. message.version, DBS.OK)
                VLIB_READY = false
                VLIB_UNAVAILABLE = true
                return
            end
            VLIB_READY = true
        elseif message.type == "state" then
            VLIB_STATE = message.state
            cons("VVVVVV STATE CHANGE: " .. VLIB_STATE)
            if (VLIB_STATE == "IDLEMODE") then
                VLIB_ExitPlaytesting()
            end
        elseif message.type == "flag" then
            VLIB_FLAGS[message.flag] = message.value
        elseif message.type == "quit" then
            VLIB_ExitPlaytesting()
        elseif message.type == "ghostinfo" then
            VLIB_GHOSTS[message.index] = {
                rx = message.rx,
                ry = message.ry,
                x = message.x,
                y = message.y,
                col = message.col,
                realcol = {
                    r = message.realcol.r,
                    g = message.realcol.g,
                    b = message.realcol.b,
                    a = message.realcol.a
                },
                frame = message.frame
            }
        end
    end
end

if VLIB_HTTPS.waiting > 0 then
    while VLIB_HTTPS.out_channel:getCount() > 0 do
        local msg = VLIB_HTTPS.out_channel:pop()
        if msg then
            VLIB_HTTPS.waiting = VLIB_HTTPS.waiting - 1
            if VLIB_HTTPS.end_funcs[msg.key] then
                VLIB_HTTPS.end_funcs[msg.key](msg.response)
                VLIB_HTTPS.end_funcs[msg.key] = nil
            end
        end
    end
end
