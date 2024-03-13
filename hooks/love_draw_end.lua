if VLIB_DOWNLOADING then
    local str = "Downloading " .. VLIB_DOWNLOAD_TYPE .. "..."
    love.graphics.setColor(0, 0, 0)
    font_ui:printf(str, -1,  0, love.graphics.getWidth(), "center")
    font_ui:printf(str,  1,  0, love.graphics.getWidth(), "center")
    font_ui:printf(str,  0, -1, love.graphics.getWidth(), "center")
    font_ui:printf(str,  0,  1, love.graphics.getWidth(), "center")
    love.graphics.setColor(255, 255, 255)
    font_ui:printf(str, 0, 0, love.graphics.getWidth(), "center")
end
