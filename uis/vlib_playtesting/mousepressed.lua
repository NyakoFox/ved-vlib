return function(x, y, button)
    VLIB_CHANNEL_IN:push({
        type = "mouse",
        x = (x - screenoffset) / 2,
        y = y / 2,
        button = button,
        state = "pressed"
    })
end
