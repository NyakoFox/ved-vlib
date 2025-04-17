
return function()
    love.graphics.setColor(128,128,128)
    love.graphics.rectangle("line", screenoffset-0.5, -0.5, 640+1, 480+1)
    love.graphics.setColor(255,255,255)

    if not (s.pausedrawunfocused and not window_active()) then
        VLIB_DrawGame()
    end

    if VLIB_SCREENSHOT_TIMER > 0 then
        local progress = (VLIB_SCREENSHOT_TIMER / VLIB_SCREENSHOT_TIMER_MAX)
        local eased_progress = (progress * progress * progress * progress)

        if VLIB_SCREENSHOT_SUCCESS then
            love.graphics.setColor(255, 255, 255, 255)
        else
            love.graphics.setColor(255, 0, 0, 255)
        end

        local size = 32 * eased_progress

        love.graphics.rectangle("fill", screenoffset, 0, 640, size)
        love.graphics.rectangle("fill", screenoffset, 480 - size, 640, size)
        love.graphics.rectangle("fill", screenoffset, 0, size, 480)
        love.graphics.rectangle("fill", screenoffset + 640 - size, 0, size, 480)

        love.graphics.setColor(255, 255, 255)
    end
end
