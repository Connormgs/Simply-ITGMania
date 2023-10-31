-- Pane1 displays the player's score out of a possible 100.00
-- aggregate judgment counts (overall W1, overall W2, overall miss, etc.)
-- and judgment counts on holds, mines, hands, rolls
--
-- Pane1 is the what the original Simply Love for SM3.95 shipped with.
local stuff = ...
local player = stuff[1]

return Def.ActorFrame{

	-- score displayed as a percentage


	-- labels like "FANTASTIC", "MISS", "holds", "rolls", etc.
	LoadActor("./JudgmentLabels.lua", ...),

	-- "Look at this graph."  –Some sort of meme on The Internet
	LoadActor("./Graphs.lua", player),

	-- list of modifiers used by this player for this song
	LoadActor("./PlayerModifiers.lua", player),

	-- was this player disqualified from ranking?
	LoadActor("./Disqualified.lua", player)

}