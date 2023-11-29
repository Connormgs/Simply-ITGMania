-- Pane2 displays the FA+ centric score out of a possible 100.00
-- aggregate judgment counts (overall W1, overall W2, overall miss, etc.)
-- and judgment counts on holds, mines, rolls
local player = unpack(...)
local pn = ToEnumShortString(player)

-- We only want to use this in ITG mode.
-- In FA+ mode the data in this pane is handled by Pane 1
-- We don't want this version in casual mode at all.
if SL.Global.GameMode ~= "ITG" or not SL[pn].ActiveModifiers.ShowFaPlusPane then
	return
end

return Def.ActorFrame{
	-- score displayed as a percentage
	

	-- labels like "FANTASTIC", "MISS", "holds", "rolls", etc.
	LoadActor("./JudgmentLabels.lua", ...),

	LoadActor("./JudgmentNumbers.lua", ...),
	LoadActor("./fa.lua", ...),
	LoadActor("./fa2.lua", ...),
	-- numbers (How many Fantastics? How many Misses? etc.)


	
	-- "Look at this graph."  –Some sort of meme on The Internet
	LoadActor("./Graphs.lua", player),

	-- list of modifiers used by this player for this song
	LoadActor("./PlayerModifiers.lua", player),

	-- was this player disqualified from ranking?
	LoadActor("./Disqualified.lua", player),
	LoadActor("./RecordTexts.lua", player)
}