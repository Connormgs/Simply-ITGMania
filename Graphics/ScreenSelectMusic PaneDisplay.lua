local args=...
function RadarValue(pn,n)
	-- Maybe categorize this in another format

	-- 'RadarCategory_Stream'			0
	-- 'RadarCategory_Voltage'			1
	-- 'RadarCategory_Air'				2
	-- 'RadarCategory_Freeze'			3
	-- 'RadarCategory_Chaos'			4
	-- 'RadarCategory_Notes'			5
	-- 'RadarCategory_TapsAndHolds'		6
	-- 'RadarCategory_Jumps'			7
	-- 'RadarCategory_Holds'			8
	-- 'RadarCategory_Mines'			9
	-- 'RadarCategory_Hands'			10
	-- 'RadarCategory_Rolls'			11
	-- 'RadarCategory_Fakes'			13
	-- 'RadarCategory_Lifts'			12
	local SongOrCourse, StepsOrTrail, Result;
	if GAMESTATE:IsCourseMode() then
		SongOrCourse = GAMESTATE:GetCurrentCourse();
		StepsOrTrail = GAMESTATE:GetCurrentTrail(pn);
	else
		SongOrCourse = GAMESTATE:GetCurrentSong();
		StepsOrTrail = GAMESTATE:GetCurrentSteps(pn);
	end;

	if GAMESTATE:IsPlayerEnabled(pn) and (SongOrCourse and StepsOrTrail) then
		Result = StepsOrTrail:GetRadarValues(pn):GetValue(n)
	end
	return Result and (Result >= 0 and Result or "???") or 0
end
local IsNotWide = (GetScreenAspectRatio() < 16 / 9)
local IsWide = (GetScreenAspectRatio() > 4 / 3)
local pn1 = ...
local function PercentScore(pn,scoremethod)
	local SongOrCourse, StepsOrTrail;
	if GAMESTATE:IsCourseMode() then
		SongOrCourse = GAMESTATE:GetCurrentCourse();
		StepsOrTrail = GAMESTATE:GetCurrentTrail(pn);
	else
		SongOrCourse = GAMESTATE:GetCurrentSong();
		StepsOrTrail = GAMESTATE:GetCurrentSteps(pn);
	end;
	local profile, scorelist, profilechoose;
	local text,Rname = "",THEME:GetString("PaneDisplay","Best");
	if SongOrCourse and StepsOrTrail then
		-- args profile
		profile = {PROFILEMAN:IsPersistentProfile(pn) and PROFILEMAN:GetProfile(pn),PROFILEMAN:GetMachineProfile()};
		profilechoose = scoremethod and profile[1] or profile[2]
		scorelist = profilechoose:GetHighScoreList(SongOrCourse,StepsOrTrail);
		assert(scorelist)
		local scores = scorelist:GetHighScores();
		local topscore = scores[1];
		if topscore then
			text = string.format("%.2f%%", topscore:GetPercentDP()*100.0);
			Rname = topscore:GetName() ~= "" and topscore:GetName() or THEME:GetString("PaneDisplay","Best")
			text = text == "100.00%" and "100%" or text -- 100% hack
		else
			text = string.format("%.2f%%", 0);
		end;
	else
		text = "";
	end;
	return {text,Rname}
end

local t = Def.ActorFrame{
Name=base,
		OnCommand=function(s) s:y( ThemePrefs.Get("ITG1") and -2 or 0 ) end;
		CodeMessageCommand=function(s,p)
        if p.PlayerNumber == pn1 then
		if p.Name == "1OpenPanes" then
		 s:GetChild("base"):visible(false)
		s:GetChild("base2"):visible(true)
		end
		 if p.Name == "1ClosePanes" then
		  s:GetChild("base"):visible(true)
			s:GetChild("base2"):visible(false)
        end
		end
		end
	}
local af3 = Def.ActorFrame{

		OnCommand=function(s) s:x(1) end;
	}

t[#t+1] = Def.Sprite{
	Texture=THEME:GetPathG("","PaneDisplay Frame.png"),
Name="base",
	InitCommand=function(self)
		self:xy(-48,-9):diffuse(GetCurrentColor(true))
		if player == PLAYER_2 then self:x(9999) end
		if IsNotWide then self:x(20) end
	end
}
t[#t+1] = Def.Sprite{
	Texture=THEME:GetPathG("","PaneDisplay Frame2.png"),
Name="base2",
	InitCommand=function(self)
	self:visible(false)
		self:xy(0,-2):diffuse(GetCurrentColor(true))
		if player == PLAYER_2 then self:x(9999) end
		if IsNotWide then self:x(71) end
	end,
}

local levelcolors = { color("#FFFFFF"), color("#00FF00"), color("#FFDD23"), color("#DB6073") }

if GAMESTATE:IsPlayerEnabled(args) then
	local StepsOrCourse = function() return GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(args) or GAMESTATE:GetCurrentSteps(args) end
	local ObtainData = {
		--LEFT SIDE
		{
			{"Steps", function() return StepsOrCourse() and RadarValue(args, 5) or 0 end, {1,200,350,550} },
			{"Holds", function() return StepsOrCourse() and RadarValue(args, 8) or 9 end, {1,15,30,50} },

		
			xpos = {-125,-20},
			xpos2 = {-125,-20},
			xpos3 = {-125,-20},
		},
		--RIGHT SIDE
		{
			{"Jumps", function() return StepsOrCourse() and RadarValue(args, 7) or 0 end, {1,25,50,100} },
			{"Mines", function() return StepsOrCourse() and RadarValue(args, 9) or 0 end },
			{"Hands", function() return StepsOrCourse() and RadarValue(args, 10) or 0 end, {1,10,35,75} },
			{"Rolls", function() return StepsOrCourse() and RadarValue(args, 11) or 0 end, {1,10,35,75} },
			xpos = {-40,64},
			xpos2 = {-125,-20},
			xpos3 = {-20,84},
		},
		DiffPlacement = args == PLAYER_1 and 160 or -160
		
	}
	
	for ind,content in ipairs(ObtainData) do
		for vind,val in ipairs( ObtainData[ind] ) do
			t[#t+1] = Def.BitmapText{
				Font="_eurostile normal",
				Text=val[1],
				InitCommand=function(self)
					self:zoom(0.5):xy(
						ObtainData[ind].xpos[1] + (args == PLAYER_2 and 45 or 0) - 54
						,-34+14*(vind-1)):halign(0)
						if IsNotWide then self:zoom(0.5):xy(
						ObtainData[ind].xpos[1] + (args == PLAYER_2 and 45 or 0) - 40
						,-34+14*(vind-1)):halign(0):x(ObtainData[ind].xpos3[1] + 15) end
				end;
				["CurrentSteps"..ToEnumShortString(args).."ChangedMessageCommand"]=function(s)
					if GAMESTATE:GetCurrentSteps(args) then
						if val[1] and type(val[1]) == "function" then s:settext( val[1]() ) else s:settext(THEME:GetString("PaneDisplay",val[1])) end
					end
				end;
				["CurrentTrail"..ToEnumShortString(args).."ChangedMessageCommand"]=function(s)
					if GAMESTATE:GetCurrentTrail(args) then
						if val[1] and type(val[1]) == "function" then s:settext( val[1]() ) else s:settext(THEME:GetString("PaneDisplay",val[1])) end
						
					end
				end;
				
			};
			t[#t+1] = Def.BitmapText{
				Font="_eurostile normal",
				Text=val[2],
				InitCommand=function(self)
					self:zoom(0.48):xy(
						ObtainData[ind].xpos[2] + (args == PLAYER_2 and 45 or 0) - 100
						,-33+14*(vind-1))
						if IsNotWide then self:zoom(0.48):xy(
						ObtainData[ind].xpos3[2] + (args == PLAYER_2 and 45 or 0) - 25
						,-33+14*(vind-1)) end
				end;
				
				CurrentSongChangedMessageCommand=function(s) s:diffuse(Color.White):settext("") end;
				["CurrentSteps"..ToEnumShortString(args).."ChangedMessageCommand"]=function(s)
					
					if GAMESTATE:GetCurrentSteps(args) and val[2] then
						s:settext( val[2]() )
						if val[3] then
							for aqs,v in ipairs( ObtainData[ind][vind][3] ) do
								if val[2]() > v then
									s:diffuse( levelcolors[aqs] )
								end
							end
						end

						if val[1] == "Card" then
							s:diffuse(Color.White):stopeffect()
							if (PercentScore(args,true)[1] == PercentScore(args)[1] and PercentScore(args,true)[1] ~= "0.00%") then
								s:diffuseshift():effectcolor1( color("0,1,1,1") )
							end
						end
					end
				end;
				["CurrentTrail"..ToEnumShortString(args).."ChangedMessageCommand"]=function(s)
					if GAMESTATE:GetCurrentTrail(args) and val[2] then
						s:settext( val[2]() )
						if val[3] then
							for aqs,v in ipairs( ObtainData[ind][vind][3] ) do
								if val[2]() ~= "???" and val[2]() > v then
									s:diffuse( levelcolors[aqs] )
								end
							end
						end
					end
				end;
			};
		end
	end
	t[#t+1] = Def.BitmapText{
		Font="_futurist normal",
		InitCommand=function(self) 
		if IsWide then self:x(55):y(-24+4) end;
		if IsNotWide then self:x(118):y(-24) end;
		end;
CodeMessageCommand=function(s,p)
        if p.PlayerNumber == pn1 then
		if p.Name == "1OpenPanes" then
		s:addx(ObtainData.DiffPlacement + 999)
		end
		end
		 if p.Name == "1ClosePanes" and IsWide then
		s:x(55)
			end
			 if p.Name == "1ClosePanes" and IsNotWide then
		s:x(ObtainData.DiffPlacement - 40)
			end
		end;
		CurrentSongChangedMessageCommand=function(s) s:settext("") end;
		["CurrentSteps"..ToEnumShortString(args).."ChangedMessageCommand"]=function(self)
			if GAMESTATE:GetCurrentSong() and not GAMESTATE:IsCourseMode() then
				if GAMESTATE:GetCurrentSteps(args) then
					self:settext( GAMESTATE:GetCurrentSteps(args):GetMeter() )
					self:diffuse( DifficultyColor( GAMESTATE:GetCurrentSteps(args):GetDifficulty() ) )
				end
			end
		end;
		["CurrentTrail"..ToEnumShortString(args).."ChangedMessageCommand"]=function(self)
			if GAMESTATE:GetCurrentCourse() then
				self:settext( GAMESTATE:GetCurrentTrail(args):GetMeter() )
				self:diffuse( DifficultyColor( GAMESTATE:GetCurrentTrail(args):GetDifficulty() ) )
			end
		end;
	};
	t[#t+1] = Def.BitmapText{
		Font="_eurostile normal",
		InitCommand=function(self) 
		if IsWide then self:x(ObtainData.DiffPlacement - 105):y(-24+30):maxwidth(90):zoom(0.55) end;
		if IsNotWide then self:x(ObtainData.DiffPlacement - 40):y(0):maxwidth(90):zoom(0.55) end;
		end;
	CodeMessageCommand=function(s,p)
        if p.PlayerNumber == pn1 then
		if p.Name == "1OpenPanes" then
		s:x(ObtainData.DiffPlacement + 999)
		end
		end
		 if p.Name == "1ClosePanes" and IsWide then
	s:x(ObtainData.DiffPlacement - 105)
			end
			if p.Name == "1ClosePanes" and IsNotWide then
	s:x(ObtainData.DiffPlacement - 40)
			end
		end;
		CurrentSongChangedMessageCommand=function(s) s:settext("") end;
		["CurrentSteps"..ToEnumShortString(args).."ChangedMessageCommand"]=function(self)
			if GAMESTATE:GetCurrentSong() and not GAMESTATE:IsCourseMode() then
				if GAMESTATE:GetCurrentSteps(args) then
					self:settext(
						string.upper( 
							THEME:GetString("Difficulty", ToEnumShortString( GAMESTATE:GetCurrentSteps(args):GetDifficulty() ) )
						)
					)
					self:diffuse( DifficultyColor( GAMESTATE:GetCurrentSteps(args):GetDifficulty() ) )
					
				end
			end
		end;
		["CurrentTrail"..ToEnumShortString(args).."ChangedMessageCommand"]=function(self)
			if GAMESTATE:GetCurrentCourse() then
				self:settext(
					string.upper( 
						THEME:GetString("CourseDifficulty", ToEnumShortString( GAMESTATE:GetCurrentTrail(args):GetDifficulty() ) )
					)
				)
				self:diffuse( DifficultyColor( GAMESTATE:GetCurrentTrail(args):GetDifficulty() ) )
			end
		end;
	};
end

return t;