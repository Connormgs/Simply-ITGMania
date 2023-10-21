local player = ...
local pn = ToEnumShortString(player)

local w = 136
local h = 18
local _x = _screen.cx + (player==PLAYER_1 and -1 or 1) * SL_WideScale(238, 288)
local oldlife = 0
local IsNotWide = (GetScreenAspectRatio() < 16/9)

-- get SongPosition specific to this player so that
-- split BPMs are handled if there are any
local songposition = GAMESTATE:GetPlayerState(player):GetSongPosition()
local swoosh, velocity

local Update = function(self)
	if not swoosh then return end
	velocity = -(songposition:GetCurBPS() * 0.5)
	if songposition:GetFreeze() or songposition:GetDelay() then velocity = 0 end
	swoosh:texcoordvelocity(velocity,0)
end

local meter = Def.ActorFrame{

	InitCommand=function(self) self:y(20):SetUpdateFunction(Update):visible(false) end,
	OnCommand=function(self) self:finishtweening():visible(true) end,

	-- frame
	Def.Quad{ InitCommand=function(self) self:x(_x):zoomto(w+4, h+4) end },
	Def.Quad{ InitCommand=function(self) self:x(_x):zoomto(w, h):diffuse(0,0,0,1) end },
	
	-- percent
	Def.Quad {
		InitCommand=function(self)
			self:visible(not IsNotWide and SL[pn].ActiveModifiers.ShowLifePercent)
		    self:zoomto(44, 18):diffuse(PlayerColor(player,true)):horizalign("left")
			if player==PLAYER_1 then
				self:x(_x-76):horizalign("right")
			else
				self:x(_x+76)
			end
		end,
		HealthStateChangedMessageCommand=function(self,params)
			if params.PlayerNumber == player then
				if params.HealthState == 'HealthState_Hot' then
					self:zoomto(52, 18)
					self:accelerate(1)
					self:diffusealpha(0)
				else
					-- ~~man's~~ lifebar's not hot
					self:zoomto(44, 18):finishtweening():diffusealpha(1)
				end
			end
		end,
		-- check life (LifeMeterBar)
		LifeChangedMessageCommand=function(self,params)
			if params.Player == player then
				local life = params.LifeMeter:GetLife() * 100
				if life < 100 then
					self:finishtweening()
				end
			end
		end,
	},
	Def.Quad {
		InitCommand=function(self)
			self:visible(not IsNotWide and SL[pn].ActiveModifiers.ShowLifePercent)
			self:zoomto(42, 16):diffuse(0,0,0,1):horizalign("left")
			if player==PLAYER_1 then
				self:x(_x-77):horizalign("right")
			else
				self:x(_x+77)
			end
		end,
		HealthStateChangedMessageCommand=function(self,params)
			if params.PlayerNumber == player then
				if params.HealthState == 'HealthState_Hot' then
					self:zoomto(50, 16)
					self:accelerate(1)
					self:diffusealpha(0)
				else
					-- ~~man's~~ lifebar's not hot
					self:zoomto(42, 16):finishtweening():diffusealpha(1)
				end
			end
		end,
		-- check life (LifeMeterBar)
		LifeChangedMessageCommand=function(self,params)
			if params.Player == player then
				local life = params.LifeMeter:GetLife() * 100
				if life < 100 then
					self:finishtweening()
				end
			end
		end,
	},
	Def.BitmapText {
		Font="Common Normal",
		InitCommand=function(self)
			self:visible(not IsNotWide and SL[pn].ActiveModifiers.ShowLifePercent)
			self:diffuse(PlayerColor(player,true)):horizalign("left")
			if player==PLAYER_1 then
				self:x(_x-77):horizalign("right")
			else
				self:x(_x+78)
			end
		end,
		HealthStateChangedMessageCommand=function(self,params)
			if params.PlayerNumber == player then
				if params.HealthState == 'HealthState_Hot' then
					self:accelerate(1):diffusealpha(0)
				else
					-- ~~man's~~ lifebar's not hot
					self:finishtweening():diffusealpha(1)
				end
			end
		end,
		-- check life (LifeMeterBar)
		LifeChangedMessageCommand=function(self,params)
			if params.Player == player then
				local life = params.LifeMeter:GetLife() * 100
				if life < 100 then
					self:finishtweening()
				end
				self:settext(("%.1f%%"):format(life))
			end
		end,
	},

	-- the Quad that changes width/color depending on current Life
	Def.Quad{
		Name="MeterFill",
		InitCommand=function(self) self:zoomto(0,h):diffuse(PlayerColor(player,true)):horizalign(left) end,
		OnCommand=function(self) self:x( _x - w/2 ) end,

		-- check whether the player's LifeMeter is "Hot"
		-- in LifeMeterBar.cpp, the engine says a LifeMeter is Hot if the current
		-- LifePercentage is greater than or equal to the HOT_VALUE, which is
		-- defined in Metrics.ini under [LifeMeterBar] like HotValue=1.0
		HealthStateChangedMessageCommand=function(self,params)
			if params.PlayerNumber == player then
				if params.HealthState == 'HealthState_Hot' then
					if SL[pn].ActiveModifiers.RainbowMax then
						self:rainbow()
					else
						self:diffuse(1,1,1,1)
					end
				else
					-- ~~man's~~ lifebar's not hot
					if SL[pn].ActiveModifiers.RainbowMax then
						self:stopeffect()
					elseif not SL[pn].ActiveModifiers.ResponsiveColors then
						self:diffuse( PlayerColor(player,true) )
					end
				end
			end
		end,

		-- when the engine broadcasts that the player's LifeMeter value has changed
		-- change the width of this MeterFill Quad to accommodate
		LifeChangedMessageCommand=function(self,params)
			if params.Player == player then
				local life = params.LifeMeter:GetLife() * w
				local absLife = params.LifeMeter:GetLife()
				if SL[pn].ActiveModifiers.ResponsiveColors then
					if absLife >= 0.9 then
						self:diffuse(0, 1, (absLife - 0.9) * 10, 1)
					elseif absLife >= 0.5 then
						self:diffuse((0.9 - absLife) * 10 / 4, 1, 0, 1)
					else
						self:diffuse(1, (absLife - 0.2) * 10 / 3, 0, 1)
					end
				end
				self:finishtweening()
				self:bouncebegin(0.1):zoomx( life )
			end
		end,
	},

	-- a simple scrolling gradient texture applied on top of MeterFill
	LoadActor("swoosh.png")..{
		Name="MeterSwoosh",
		InitCommand=function(self)
			swoosh = self

			self:zoomto(w,h)
				 :diffusealpha(0.2)
				 :horizalign( left )
		end,
		OnCommand=function(self)
			self:x(_x - w/2)
			self:customtexturerect(0,0,1,1)
			--texcoordvelocity is handled by the Update function below
		end,
		HealthStateChangedMessageCommand=function(self,params)
			if(params.PlayerNumber == player) then
				if(params.HealthState == 'HealthState_Hot') then
					self:diffusealpha(1)
				else
					self:diffusealpha(0.2)
				end
			end
		end,

		-- life-changing
		-- adjective
		--  /ˈlaɪfˌtʃeɪn.dʒɪŋ/
		-- having an effect that is strong enough to change someone's life
		-- synonyms: compelling, life-altering, puissant, blazing
		LifeChangedMessageCommand=function(self,params)
			if params.Player == player then
				local life = params.LifeMeter:GetLife() * w
				self:finishtweening()
				self:bouncebegin(0.1):zoomto( life, h )
			end
		end
	}
}

return meter

-- copyright 2008-2012 AJ Kelly/freem.
-- do not use this code in your own themes without my permission.