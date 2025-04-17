VLIB_QUAD_CACHE = {}

function VLIB_Slider(x, y, label, width, current, max, on_change)
    love.graphics.setColor(255, 255, 255)
    font_ui:printf(label, x, y, width, "center")

    love.graphics.setColor(96, 96, 96)
    love.graphics.rectangle("fill", x, y + 16 + 2, width, 4)

    local percentage = current / max

    love.graphics.setColor(192, 192, 192)
    love.graphics.rectangle("fill", x + (percentage * (width - 4)), y + 16, 4, 8)

    if (love.mouse.isDown("l")) then
        local mx, my = love.mouse.getPosition()
        if (mx > (x - 8) and mx < (x + width + 8) and my > (y + 16) and my < (y + 24)) then
            local new = round(VLIB_Clamp(mx - x, 0, width) / width * max)
            on_change(new)
        end
    end

    love.graphics.setColor(255, 255, 255)

    return width, 32
end

function VLIB_GetQuad(x, y, w, h, sw, sh)
    local key = x .. "_" .. y .. "_" .. w .. "_" .. h .. "_" .. sw .. "_" .. sh
    if not VLIB_QUAD_CACHE[key] then
        VLIB_QUAD_CACHE[key] = love.graphics.newQuad(x, y, w, h, sw, sh)
    end
    return VLIB_QUAD_CACHE[key]
end
