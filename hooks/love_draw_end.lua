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

if state == 1 and VLIB_SETTINGS.show_ghosts then
    -- use VLIB_canvases.ghostTexture
    if VLIB_GHOST_CANVAS == nil then
        VLIB_GHOST_CANVAS = love.graphics.newCanvas(320, 240)
    end

    love.graphics.push()
    love.graphics.origin()
    love.graphics.setCanvas(VLIB_GHOST_CANVAS)
    love.graphics.clear()
    for i = 1, #VLIB_GHOSTS do
        if VLIB_GHOSTS[i].rx == roomx and VLIB_GHOSTS[i].ry == roomy then
            love.graphics.setColor(
                VLIB_GHOSTS[i].realcol.r,
                VLIB_GHOSTS[i].realcol.g,
                VLIB_GHOSTS[i].realcol.b,
                3 * VLIB_GHOSTS[i].realcol.a / 4
            )
            drawentitysprite(VLIB_GHOSTS[i].frame, VLIB_GHOSTS[i].x, VLIB_GHOSTS[i].y, true)
        end
    end
    love.graphics.setCanvas()
    love.graphics.pop()

    love.graphics.setColor(255, 255, 255, 128)
    love.graphics.draw(VLIB_GHOST_CANVAS, screenoffset, 0, 0, 2)
    love.graphics.setColor(255, 255, 255, 255)
end
