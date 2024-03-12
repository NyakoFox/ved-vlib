return function(key)
    VLIB_CHANNEL_IN:push({
        type = "key",
        key = key,
        state = "released"
    })
end
