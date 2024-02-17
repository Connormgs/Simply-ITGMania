-- Each time a judgment occurs during gameplay, the engine broadcasts some relevant data
-- as a key/value table that themeside Lua can listen for via JudgmentMessageCommand()
--
-- The details of *what* gets broadcast is complicated and not documented anywhere I've found,
-- but you can grep the src for "Judgment" (quotes included) to get a sense of what gets sent
-- to Lua in different circumstances.
--
-- This file, PerColumnJudgmentTracking.lua exists so that ScreenEvaluation can have a pane
-- that displays a per-column judgment breakdown.
--
-- We have a local table, judgments, that has as many sub-tables as the current game has panels
-- per player (4 for dance-single, 8 for dance-double, 5 for pump-single, etc.)
-- and each of those sub-tables stores the number of judgments that occur during gameplay on
-- that particular panel.
--
-- This doesn't override or recreate the engine's judgment system in any way. It just allows
-- transient judgment data to persist beyond ScreenGameplay.
------------------------------------------------------------

-- don't bother tracking per-column judgment data in Casual gamemode
if SL.Global.GameMode == "Casual" then return end

local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers

local judgments = {}
for i=1,GAMESTATE:GetCurrentStyle():ColumnsPerPlayer() do
	-- W4 and W5 are the early decent/way offs itself.
	-- W0-W3 are for indicating what the early hits were rescored to.
	judgments[#judgments+1] = { W0=0, W1=0, W2=0, W3=0, W4=0, W5=0, Miss=0, MissBecauseHeld=0, Early={ W0=0, W1=0, W2=0, W3=0, W4=0, W5=0 } }
end

return Def.Actor{
	OffCommand=function(self)
		local storage = SL[ToEnumShortString(player)].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1]
		storage.column_judgments = judgments
	end,
	JudgmentMessageCommand=function(self, params)
		local health_state = GAMESTATE:GetPlayerState(params.Player):GetHealthState()
		if params.Player == player and params.Notes and health_state ~= 'HealthState_Dead' then
			for col,tapnote in pairs(params.Notes) do
				local tnt = ToEnumShortString(tapnote:GetTapNoteType())

				-- we don't want to consider TapNoteTypes like Mine, HoldTail, Attack, etc. when counting judgments
				-- we do want to consider normal tapnotes, hold heads, and lifts
				-- see: https://quietly-turning.github.io/Lua-For-SM5/LuaAPI#Enums-TapNoteType
				if tnt == "Tap" or tnt == "HoldHead" or tnt == "Lift" then
					local tns = ToEnumShortString(params.TapNoteScore)
					-- This was a rescored hit. Track what it was rescored to.
					if params.EarlyTapNoteScore ~= nil then
						local etns = ToEnumShortString(params.EarlyTapNoteScore)
						
						if etns ~= "None" then
							if IsW0Judgment(params, player) then
								judgments[col]["Early"]["W0"] = judgments[col]["Early"]["W0"] + 1
							elseif tns ~= "W4" and tns ~= "W5" and tns ~= "Miss" then
								judgments[col]["Early"][tns] = judgments[col]["Early"][tns] + 1
							end

							-- What was it rescored from?
							-- Note that jumps are not rescored, so we don't need to worry about double counting them.
							judgments[col]["Early"][etns] = judgments[col]["Early"][etns] + 1
						end
					end

					if mods.ShowFaPlusWindow and mods.ShowFaPlusPane and IsW0Judgment(params, player) then
						tns = "W0"
					end
					judgments[col][tns] = judgments[col][tns] + 1

					if tnt ~= "Lift" and tns == "Miss" and tapnote:GetTapNoteResult():GetHeld() then
						judgments[col].MissBecauseHeld = judgments[col].MissBecauseHeld + 1
					end
				end
			end
		end
	end
}
