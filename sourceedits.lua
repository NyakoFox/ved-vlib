sourceedits =
{
	["playtesting"] =
	{
		{
			find = [[playtestthread_inchannel:push(PT_CMD.DATA_POS)]],
			replace = [[
				VLIB_StartLevel(thisroomx, thisroomy, posx, posy, gravitycontrol, music)
				--[[
			]],
			ignore_error = false,
			luapattern = false,
			allowmultiple = false
		},
		{
			find = [[playtestthread_inchannel:push(PT_CMD.GO)]],
			replace = "]]",
			ignore_error = false,
			luapattern = false,
			allowmultiple = false
		},
		{
			find = [[playtestthread:start(path, editingmap, L)]],
			replace = [[]],
			ignore_error = false,
			luapattern = false,
			allowmultiple = false
		},
		{
			find = [[playtestthread_inchannel:push(PT_CMD.DATA_LEVEL)]],
            replace = [[
                VLIB_CHANNEL_IN:push(
                    {
                        type = "level_data",
                        level_data = thissavederror
                    }
                )
            ]],
            ignore_error = false,
            luapattern = false,
            allowmultiple = false
		},
		{
			find = [[playtestthread_inchannel:push(thissavederror)]],
            replace = [[]],
            ignore_error = false,
            luapattern = false,
            allowmultiple = false
		},
		{
			find = [[playtesting_engstate = PT_ENGSTATE.CANCELING]],
			replace = [[]],
			ignore_error = false,
			luapattern = false,
			allowmultiple = false
		},
		{
			find = [[path = playtesting_locate_path()]],
			replace = [[]],
			ignore_error = false,
			luapattern = false,
			allowmultiple = false
		},
		{
			find = [[if path == nil or path == "" then]],
			replace = [[if false then]],
			ignore_error = false,
			luapattern = false,
			allowmultiple = false
		},
		{
			find = [[cons("RUNNING VVVVVV AT THIS PATH:\n" .. path)]],
			replace = [[]],
			ignore_error = false,
			luapattern = false,
			allowmultiple = false
		},
		{
			find = [[function playtesting_start(force_ask_path)]],
			replace = [[
				function playtesting_start(force_ask_path)
					if not VLIB_READY then
						dialog.create("VVVVVV is not yet ready to launch.", DBS.OK)
						return
					end
			]],
			ignore_error = false,
			luapattern = false,
			allowmultiple = false
		}
	}
}