-- per-player lower half of ScreenEvaluation

local player = ...
local NumPlayers = #GAMESTATE:GetHumanPlayers()

local pane_spacing = 10
local small_pane_w = 300

-- smaller width (used when both players are joined) by default
local pane_width = 200
local pane_height  = 180






return af