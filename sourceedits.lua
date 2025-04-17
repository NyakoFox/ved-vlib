sourceedits =
{
	["callback_threaderror"] =
	{
		{
			find = [[function love.threaderror(thread, errorstr)]],
			replace = [[function love.threaderror(thread, errorstr)
				if thread == VLIB_THREAD then
					-- Uh oh... the VLIB thread errored.
					VLIB_OnThreadError(errorstr)
					return
				end
			]],
			ignore_error = false,
			luapattern = false,
			allowmultiple = false
		}
	},
	["uis/maineditor/draw"] =
	{
		{
			find = [[if playtesting_available then]],
			replace = [[
				if VLIB_Enabled() then
					if not VLIB_IsAvailable() then
						usethisbtn = image.playgraybtn_hq
					else
						if playtesting_uistate == PT_UISTATE.ASKING then
							usethisbtn = VLIB_IMAGE_PLAYSTOP
						else
							usethisbtn = VLIB_IMAGE_PLAY
						end
					end
				elseif playtesting_available then
			]],
			ignore_error = false,
			luapattern = false,
			allowmultiple = false
		},
	},
	["uis/vvvvvvsetupoptions/elements"] =
	{
		{
			find = [[WrappedText(L.CUSTOMVVVVVVDIRECTORY),]],
			replace = [[
				WrappedText(
					function()
						if VLIB_SESSION_DISABLED then
							return "Ved Playtesting (VLIB) is installed, but is disabled in this session."
						end

						return "Ved Playtesting (VLIB) is installed."
					end
				),
				Spacer(),
				DrawingFunction(
					function(x, y, maxw, maxh)
                        checkbox(VLIB_SETTINGS.enabled, x, y, nil, "VLIB Enabled", function()
                            VLIB_Set("enabled", not VLIB_SETTINGS.enabled)
                        end)
					end
				),
				Spacer(),
				Spacer(),
				WrappedText("Non-VLIB options (from base Ved) are below:"),
				Spacer(),
				WrappedText(L.CUSTOMVVVVVVDIRECTORY),
			]],
			ignore_error = false,
			luapattern = false,
			allowmultiple = false
		},
	},
	["playtesting"] =
	{
		{
			find = [[playtestthread_inchannel:push(PT_CMD.DATA_POS)]],
			replace = [[
				if VLIB_Enabled() then
					VLIB_StartLevel(thisroomx, thisroomy, posx, posy, gravitycontrol, music)
					return
				end

				playtestthread_inchannel:push(PT_CMD.DATA_POS)
			]],
			ignore_error = false,
			luapattern = false,
			allowmultiple = false
		},
		{
			find = [[playtesting_engstate = PT_ENGSTATE.CANCELING]],
			replace = [[
				if VLIB_Enabled() then
					-- just turn it off, nothing needs to be canceled in VLIB
					playtesting_engstate = PT_ENGSTATE.OFF
					playtesting_uistate = PT_UISTATE.OFF
					return
				end
				playtesting_engstate = PT_ENGSTATE.CANCELING
			]],
			ignore_error = false,
			luapattern = false,
			allowmultiple = false
		},
		{
			find = [[function playtesting_start(force_ask_path)]],
			replace = [[
				function playtesting_start(force_ask_path)
					if VLIB_StartPlaytesting() then
						return
					end
			]],
			ignore_error = false,
			luapattern = false,
			allowmultiple = false
		}
	}
}