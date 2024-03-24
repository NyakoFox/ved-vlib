
return function()
    love.graphics.setColor(128,128,128)
    love.graphics.rectangle("line", screenoffset-0.5, -0.5, 640+1, 480+1)
    love.graphics.setColor(255,255,255)

    if not (s.pausedrawunfocused and not window_active()) then
        VLIB_DrawGame()
    end
end
