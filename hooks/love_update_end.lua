local dt = ...

if VLIB_READY then
    -- deltaloop

    if not (s.pausedrawunfocused and not window_active()) then
        VLIB_ACCUMULATOR = VLIB_ACCUMULATOR + dt
        while VLIB_ACCUMULATOR >= (VLIB_SETTINGS.game_speed / 1000) do
            VLIB_ACCUMULATOR = VLIB_ACCUMULATOR - (VLIB_SETTINGS.game_speed / 1000)

            VLIB_CHANNEL_IN:push({
                type = "update"
            })
        end
    end

    while VLIB_CHANNEL_OUT:getCount() > 0 do
        local message = VLIB_CHANNEL_OUT:pop()
        if message.type == "state" then
            VLIB_STATE = message.state
            cons("VVVVVV STATE CHANGE: " .. VLIB_STATE)
            if (VLIB_STATE == "IDLEMODE") then
                playtesting_engstate = PT_ENGSTATE.OFF
                playtesting_uistate = PT_UISTATE.OFF
                tostate(1, true)
                love.mouse.setVisible(true)
            end
        elseif message.type == "flag" then
            VLIB_FLAGS[message.flag] = message.value
        elseif message.type == "quit" then
            playtesting_engstate = PT_ENGSTATE.OFF
            playtesting_uistate = PT_UISTATE.OFF
            tostate(1, true)
            love.mouse.setVisible(true)
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
