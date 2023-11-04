local t = Def.ActorFrame{}
local reverseindex = ...


t[#t+1] = Def.Sprite{
	Texture=THEME:GetPathG("MenuElements icon",GAMESTATE:GetCurrentStyle(GAMESTATE:GetMasterPlayerNumber()):GetName()),
	OnCommand=function(self)
		self:animate(0):setstate( Enum.Reverse(PlayerNumber)[GAMESTATE:GetMasterPlayerNumber()] )
		:x(0):y(2):zoom(0.8)
	end,
}

return t;

