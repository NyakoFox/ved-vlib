if VLIB_DOWNLOADING then
    local str = "Downloading " .. VLIB_DOWNLOAD_TYPE .. "..."
    love.graphics.setColor(0, 0, 0)
    font_ui:printf(str, -1,  0, love.graphics.getWidth(), "center")
    font_ui:printf(str,  1,  0, love.graphics.getWidth(), "center")
    font_ui:printf(str,  0, -1, love.graphics.getWidth(), "center")
    font_ui:printf(str,  0,  1, love.graphics.getWidth(), "center")
    love.graphics.setColor(255, 255, 255)
    font_ui:printf(str, 0, 0, love.graphics.getWidth(), "center")

    if VLIB_PROGRESS_NOW ~= 0 and VLIB_PROGRESS_TOTAL ~= 0 then
        local progress = VLIB_PROGRESS_NOW / VLIB_PROGRESS_TOTAL
        local bar_width = 400
        local bar_height = 4
        local bar_x = (love.graphics.getWidth() - bar_width) / 2
        local bar_y = font_ui:getHeight() + 4

        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", bar_x, bar_y, bar_width, bar_height)
        love.graphics.setColor(255, 255, 255)
        love.graphics.rectangle("fill", bar_x, bar_y, bar_width * progress, bar_height)
    end
end
