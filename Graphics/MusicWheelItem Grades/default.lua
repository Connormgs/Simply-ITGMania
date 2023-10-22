local player = PLAYER_1
return Def.ActorFrame{
LoadActor( THEME:GetPathG("", "_grade models/"..STATSMAN:GetCurStageStats():GetPlayerStageStats(player):GetGrade()..".lua" ) )..{
InitCommand=function(self)
self:x(SCREEN_CENTER_X)
end
}
}