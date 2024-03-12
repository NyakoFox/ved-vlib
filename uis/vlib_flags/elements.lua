return {
    AlignContainer(
        elListContainer:new{
            cw = 128, ch = nil,
            start = 8,
            spacing = 8,
            start_bot = 8,
            spacing_bot = 8,
            els_top = {},
            els_bot = {}
        },
        ALIGN.LEFT
    ),
    RightBar(
        {
        },
        {
            LabelButtonSpacer(),
            LabelButton(L.RETURN, function()
                to_astate("vlib_playtesting")
            end, "b", hotkey("escape")),
        }
    ),
}
