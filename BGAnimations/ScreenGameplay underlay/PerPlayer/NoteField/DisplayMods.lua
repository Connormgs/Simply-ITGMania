local player = ...

if SL.Global.GameMode == "Casual" or GAMESTATE:IsCourseMode() then return end

local optionslist = GetPlayerOptionsString(player)

local af = Def.ActorFrame{
  InitCommand = function(self)
      self:xy(GetNotefieldX(player), SCREEN_HEIGHT/4*1.3)
  end,
  OnCommand=function(self)
    self:sleep(5):decelerate(0.5):diffusealpha(0)
  end
}

af[#af+1] = LoadFont("Common Normal")..{
  Text=optionslist,
  InitCommand=function(self)
    self:y(15)
    self:zoom(0.8)
    self:wrapwidthpixels(125)
    self:shadowcolor(Color.Black)
    self:shadowlength(1)
  end,
}

-- For tournament packs that have No CMOD rules 
local song = GAMESTATE:GetCurrentSong()
local song_dir = song:GetSongDir()
local group = string.lower(song:GetGroupName())
local tourneyPack = false
local tourneyPacks = {"itl", "rip"}
for pack in ivalues(tourneyPacks) do
	if string.find(group,pack) ~= nil then tourneyPack = true end
end

-- Tourney specific only
-- for tournament packs with rules, give a more obvious warning when cmod is on when it is not allowed
local subtitle = song:GetDisplaySubTitle()
if tourneyPack 
	and string.find(string.upper(subtitle), "(NO CMOD)") 
	and GAMESTATE:GetPlayerState(ToEnumShortString(player)):GetPlayerOptions("ModsLevel_Preferred"):CMod() then
		af[#af+1] = Def.ActorFrame{
			InitCommand=function(self)
				self:y(15+15*#values)
			end,
			Name="CModWarning",
			Def.Quad{
				Name="BGCmodWarning",
				InitCommand=function(self)
					self:diffuse(0,0,0,0.8)
						:x(0)
						:setsize(90, 30)
				end,
			},
			Def.BitmapText {
				Name="CModWarningText",
				Font="Common Normal",
				Text="CMod On",
				InitCommand=function(self)
					self:zoom(1.5)
						:diffuse(1,0,0,1)
						:horizalign(center)						
				end,
			}
		}
		
end

return af