return function(key)
    VLIB_CHANNEL_IN:push({
        type = "key",
        key = key,
        state = "pressed",
        repeating = false
    })
end
