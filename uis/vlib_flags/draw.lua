
return function()
    love.graphics.setColor(128,128,128)
    love.graphics.rectangle("line", screenoffset-0.5, -0.5, 640+1, 480+1)
    love.graphics.setColor(255,255,255)

    VLIB_DrawGame()

    love.graphics.setColor(0,0,0,192)
    love.graphics.rectangle("fill", screenoffset, 0, 640, 480)
    love.graphics.setColor(255,255,255)

    if vedmetadata then
        local longest_label = 0
        local x = 10
        local y = 10
        for i = 1, 100 do
            local label = "[" .. i .. "] " .. vedmetadata.flaglabel[i - 1]
            local width = font_ui:getWidth(label)
            if width > longest_label then
                longest_label = width
            end

            if y > 464 then
                x = x + longest_label + 10
                y = 10
            end

            local hover = love.mouse.getX() > x and love.mouse.getX() < x + longest_label and love.mouse.getY() > y and love.mouse.getY() < y + 12

            love.graphics.setColor(0, 0, 0)
            font_ui:printf(label, x-1, y, 620, "left")
            font_ui:printf(label, x+1, y, 620, "left")
            font_ui:printf(label, x, y+1, 620, "left")
            font_ui:printf(label, x, y-1, 620, "left")
            love.graphics.setColor(VLIB_FLAGS[i] and {255, 255, 255, hover and 255 or 204} or {128, 128, 128, hover and 255 or 204})
            font_ui:printf(label, x, y, 620, "left")
            y = y + 12

            if hover and love.mouse.isDown("l") and not mousepressed then
                VLIB_CHANNEL_IN:push({
                    type = "setflag",
                    flag = i - 1,
                    value = not VLIB_FLAGS[i]
                })
                mousepressed = true
            end
        end
    end
end
