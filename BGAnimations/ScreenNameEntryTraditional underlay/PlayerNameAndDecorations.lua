local Player = ...
local pn = ToEnumShortString(Player)
local CanEnterName = SL[pn].HighScores.EnteringName

if CanEnterName then
	SL[pn].HighScores.Name = ""
end

if PROFILEMAN:IsPersistentProfile(Player) then
	SL[pn].HighScores.Name = PROFILEMAN:GetProfile(Player):GetLastUsedHighScoreName()
end

local t = Def.ActorFrame{
	Name="PlayerNameAndDecorations_"..pn,
	InitCommand=function(self)
		if Player == PLAYER_1 then
			self:x(_screen.cx-160)
		elseif Player == PLAYER_2 then
			self:x(_screen.cx+160)
		end
		self:y(_screen.cy-20)
	end,



}


t[#t+1] = LoadActor("Cursor.png")..{
	Name="Cursor",
	InitCommand=function(self) self:diffuse(PlayerColor(Player)):zoom(1) end,
	OnCommand=function(self) self:visible( CanEnterName ):y(20) end,
	HideCommand=function(self) self:linear(0.25):diffusealpha(0) end
}

t[#t+1] = LoadFont("ScreenNameEntryTraditional entry")..{
	Name="PlayerName",
	InitCommand=function(self) self:zoom(1):halign(0):xy(-80,-30) end,
	OnCommand=function(self)
		self:visible( CanEnterName )
		self:settext( SL[pn].HighScores.Name or "" )
	end,
	SetCommand=function(self)
		self:settext( SL[pn].HighScores.Name or "" )
	end
}

t[#t+1] = LoadFont("Common Bold")..{
	Text=ScreenString("OutOfRanking"),
	OnCommand=function(self) self:zoom(0.7):diffuse(PlayerColor(Player)):y(58):visible(not CanEnterName) end
}

return t
