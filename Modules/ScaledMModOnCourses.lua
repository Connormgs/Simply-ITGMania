-- Scaled MMod on Courses Module for Simply Love
--
-- This is a module to make MMod more useful for course mode, having MMod
--   scale on a per-song basis rather than a per-course basis.
--
-- This module can also let you opt-in to the course by changing the
--   songPrefix variable. I typically have mine set up to be "[Scale by Song]"
--   And then add "[Scale by Song]" in the front of any course I want this
--   module to work on. XMod also doesn't scale at all, which means XMod and
--   MMod have different behaviors under this module.

local t = {}

local mMod = {0, 0}
local maxCourseBPM = {0, 0}
local currentSong = -1
local songPrefix = ''

local ScaleMModOkay = function()
    if not GAMESTATE:IsCourseMode() then
        return false
    end
    local title = GAMESTATE:GetCurrentCourse():GetDisplayFullTitle()
    return title:sub(1, songPrefix:len()) == songPrefix
end

local UpdateMMod = function()
    if not ScaleMModOkay() then
        return
    end
    for player in ivalues(GAMESTATE:GetHumanPlayers()) do
        -- Get the BPM of the current stepchart.
        -- Since we're in Course Mode, this has have to be done manually...
        local songBPM = GAMESTATE:GetCurrentTrail(player):GetTrailEntries()[currentSong]:GetSteps():GetDisplayBpms()[2]
        local pn = PlayerNumber:Reverse()[player] + 1
        if mMod[pn] then
            -- Scale the MMod to the current song.
            local options = GAMESTATE:GetPlayerState(pn - 1):GetPlayerOptions('ModsLevel_Song')
            local adjustedMMod = mMod[pn] * maxCourseBPM[pn] / songBPM
            options:MMod(adjustedMMod, 9e9)
        end
    end
end

t['ScreenGameplay'] = Def.ActorFrame {
    ModuleCommand=function(self)
        if not ScaleMModOkay() then
            return
        end
        -- Get the MMod for both Player 1 and Player 2 (If it exists)
        for pn = 1, 2 do
            local options = GAMESTATE:GetPlayerState(pn - 1):GetPlayerOptions('ModsLevel_Song')
            mMod[pn] = options:MMod()
        end
        if (not mMod[1] and not mMod[2]) then
            return
        end
        -- Figure out the maximum BPM of the course.
        for player in ivalues(GAMESTATE:GetHumanPlayers()) do
            local pn = PlayerNumber:Reverse()[player] + 1
            maxCourseBPM[pn] = GetDisplayBPMs(player)[2]
        end
        currentSong = 1
        UpdateMMod()
    end,

    CurrentSongChangedMessageCommand=function(self)
        -- Make sure this ONLY runs when changing songs in a course.
        if (not GAMESTATE:IsCourseMode() or SCREENMAN:GetTopScreen():GetName() ~= 'ScreenGameplay') then
            return
        end
        currentSong = currentSong + 1
        UpdateMMod()
    end
}

return t