-- Nothing in Ved for this yet, so let's just hook it ourselves

local old_mousemoved = love.mousemoved
function love.mousemoved(x, y, dx, dy, istouch)
    if old_mousemoved then
        old_mousemoved(x, y, dx, dy, istouch)
    end

    if (in_astate("vlib_playtesting")) then
        VLIB_CHANNEL_IN:push({
            type = "mouse",
            x = (x - screenoffset) / 2,
            y = y / 2,
            state = "moved"
        })
    end
end
