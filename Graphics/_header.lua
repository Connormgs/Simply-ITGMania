-- tables of rgba values
local dark  = {0,0,0,0.9}
local light = {0.65,0.65,0.65,1}

return Def.ActorFrame{
	Name="Header",

	
		ScreenChangedMessageCommand=function(self)
			local topscreen = SCREENMAN:GetTopScreen():GetName()
			if SL.Global.GameMode == "Casual" and (topscreen == "ScreenEvaluationStage" or topscreen == "ScreenEvaluationSummary") then
				self:diffuse(dark)
			end
			if ThemePrefs.Get("VisualStyle") == "SRPG7" then
				self:diffuse(GetCurrentColor(true))
			end
			self:visible(topscreen ~= "ScreenCRTTestPatterns")
		end,
		ColorSelectedMessageCommand=function(self)
			if ThemePrefs.Get("VisualStyle") == "SRPG7" then
				self:diffuse(GetCurrentColor(true))
			end
		end,
	},


}
