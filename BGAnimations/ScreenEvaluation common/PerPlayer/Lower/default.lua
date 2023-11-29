-- per-player lower half of ScreenEvaluation

local player = ...
local NumPlayers = #GAMESTATE:GetHumanPlayers()

local pane_spacing = 10
local small_pane_w = 300

-- smaller width (used when both players are joined) by default
local pane_width = 200
local pane_height  = 180

-- if only one player is joined, use more screen width to draw two
-- side-by-side panes that both belong to this player
if NumPlayers == 1 and SL.Global.GameMode ~= "Casual" then
	pane_width = (pane_width * 2) + pane_spacing
end

local af = Def.ActorFrame{
	Name=ToEnumShortString(player).."_AF_Lower",
	InitCommand=function(self)

		-- if 2 players joined, or if Casual Mode where panes are not full-width,
		-- give each player their own distinct space for a half-width pane
		if NumPlayers == 2 or SL.Global.GameMode == "Casual" then
			self:x(_screen.cx + ((350) * (player==PLAYER_1 and -0.3 or 0.9)))
			self:y(-260)
		else
			self:x(_screen.cx + ((350) * (player==PLAYER_1 and -0.3 or 0.9)))
			self:y(-260)
		end
	end
}

-- -----------------------------------------------------------------------
-- background quad for player stats


-- "Look at this graph."  –Some sort of meme on The Internet
af[#af+1] = LoadActor("./Graphs.lua", player)

-- list of modifiers used by this player for this song
af[#af+1] = LoadActor("./PlayerModifiers.lua", player)

-- was this player disqualified from ranking?
af[#af+1] = LoadActor("./Disqualified.lua", player)

-- -----------------------------------------------------------------------

return af