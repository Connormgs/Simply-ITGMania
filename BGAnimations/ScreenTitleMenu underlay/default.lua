InitializeSimplyLove()

local style = ThemePrefs.Get("ITG1") and "_flare" or "flare"
local num = ThemePrefs.Get("ITG1") and "" or " 2"

return Def.ActorFrame{
	LoadActor("../ScreenLogo background"),



	
	Def.Sprite{
		Texture=style,
		 OnCommand=function(self)
			self:diffuse(GetCurrentColor(true)):xy(SCREEN_LEFT-64,SCREEN_CENTER_Y-197):rotationz(0):linear(1):x(SCREEN_RIGHT+64):rotationz(360)
		end
	},
	
	Def.Sprite{
		Texture=style,
		 OnCommand=function(self)
			self:diffuse(GetCurrentColor(true)):xy(SCREEN_LEFT-64,SCREEN_CENTER_Y+202):rotationz(0):linear(1):x(SCREEN_RIGHT+64):rotationz(360)
		end
	},

	Def.BitmapText{
		Condition=PREFSMAN:GetPreference("UseUnlockSystem"),
		Font="Common Normal",
		OnCommand=function(s)
			local unlocked = 0
			for i=1,UNLOCKMAN:GetNumUnlocks() do
				local Code = UNLOCKMAN:GetUnlockEntry( i-1 )
				if Code and not Code:IsLocked() then
					unlocked = unlocked + 1
				end
			end

			s:settext( string.format( THEME:GetString("ScreenUnlock","%d/%d unlocked"), unlocked, 15 ) )
			:halign(1):xy(SCREEN_RIGHT-30,SCREEN_CENTER_Y+100):zoom(0.6):diffusealpha(0.5)
		end;
	};

	Def.HelpDisplay {
		File="_eurostile normal",
		OnCommand=function(self)
			self:x(SCREEN_CENTER_X):y(SCREEN_CENTER_Y+203):zoom(0.7):diffuseblink():maxwidth(SCREEN_WIDTH/0.8)
		end;
		InitCommand=function(self)
			self:SetSecsBetweenSwitches(THEME:GetMetric("HelpDisplay","TipSwitchTime"))
			self:SetTipsColonSeparated( THEME:GetString("ScreenTitleMenu","HelpText") );
			for i=1,UNLOCKMAN:GetNumUnlocks() do
				if PREFSMAN:GetPreference("UseUnlockSystem") then
					local Code = UNLOCKMAN:GetUnlockEntry( i-1 )
					if Code and Code:IsLocked() then
						UNLOCKMAN:LockEntryID( tostring(i) )
					end
				end
			end
		end;
		OffCommand=function(self)
			self:linear(0.5):zoomy(0)
			
		end
	},
	

	LoadActor("../ScreenWithMenuElements underlay"),
	LoadActor("PercentComplete","StepsType_Dance_Single")..{ OnCommand=function(self) self:xy(SCREEN_RIGHT-90,SCREEN_TOP+30):zoom(0.9) end; };
	LoadActor("PercentComplete","StepsType_Dance_Double")..{ OnCommand=function(self) self:xy(SCREEN_RIGHT-90,SCREEN_TOP+50):zoom(0.9) end; };
	

	Def.Sprite{
		Texture="../ScreenLogo background/roxor",
		OnCommand=function(self)
			self:xy(SCREEN_LEFT+90,SCREEN_TOP+30):diffusealpha(0):sleep(0.5):linear(0.5):diffusealpha(1)
		end;
	};
}