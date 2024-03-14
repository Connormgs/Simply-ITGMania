local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers
local opts = GAMESTATE:GetPlayerState(player):GetCurrentPlayerOptions()
local layout = GetGameplayLayout(player, opts:Reverse() ~= 0)

local af = Def.ActorFrame{
  Name="NoteFieldContainer"..pn,
  OnCommand=function(self)
    local adjusted_offset_x = mods.NoteFieldOffsetX * (player == PLAYER_1 and -1 or 1)

    self:addy(mods.NoteFieldOffsetY)
local player = SCREENMAN:GetTopScreen():GetChild("Player"..pn)
    player:addx(adjusted_offset_x)
    player:addy(mods.NoteFieldOffsetY)

    local notefield = player:GetChild("NoteField")
    if mods.MeasureLines == "Off" then
      notefield:SetBeatBars(false)
      notefield:SetBeatBarsAlpha(0, 0, 0, 0)
    else
      notefield:SetBeatBars(true)

      if mods.MeasureLines == "Measure" then
        notefield:SetBeatBarsAlpha(0.75, 0, 0, 0)
      elseif mods.MeasureLines == "Quarter" then
        notefield:SetBeatBarsAlpha(0.75, 0.5, 0, 0)
      elseif mods.MeasureLines == "Eighth" then
        notefield:SetBeatBarsAlpha(0.75, 0.5, 0.125, 0)
      end
    end
  end,
}

-- The following actors should also move along with the NoteFields.
-- NOTE(teejusb): Combo and Judgment are not included here because they are
-- controlled by Graphics/Player combo.lua and Graphics/Player judgment.lua
-- respectively.
af[#af+1] = LoadActor("ColumnFlashOnMiss.lua", player)
af[#af+1] = LoadActor("ErrorBar/default.lua", player, layout.ErrorBar)
af[#af+1] = LoadActor("MeasureCounter.lua", player, layout.MeasureCounter)
af[#af+1] = LoadActor("SubtractiveScoring.lua", player, layout.SubtractiveScoring)
af[#af+1] = LoadActor("ColumnCues.lua", player)
af[#af+1] = LoadActor("DisplayMods.lua", player)

-- zmod specific elements
af[#af+1] = LoadActor("DisplayMods.lua", player)
af[#af+1] = LoadActor("RunTimer.lua", player, layout.SubtractiveScoring.y, layout.MeasureCounter)
af[#af+1] = LoadActor("BrokenRunCounter.lua", player, layout.MeasureCounter)
af[#af+1] = LoadActor("OffsetDisplay.lua", player)
af[#af+1] = LoadActor("JudgmentBack.lua", player)

return af