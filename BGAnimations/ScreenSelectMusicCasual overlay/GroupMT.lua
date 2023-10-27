local args = ...
local GroupWheel = args[1]
local SongWheel = args[2]
local TransitionTime = args[3]
local steps_type = args[4]
local row = args[5]
local col = args[6]
local Input = args[7]
local PruneSongsFromGroup = args[8]

local max_chars = 64

local switch_to_songs = function(group_name)
	local songs, index = PruneSongsFromGroup(group_name)
	songs[#songs+1] = "CloseThisFolder"

	SongWheel:set_info_set(songs, index)
end


local item_mt = {
	__index = {
		create_actors = function(self, name)
			self.name=name

			-- this is a terrible way to do this
			local item_index = name:gsub("item", "")
			self.index = item_index

			local af = Def.ActorFrame{
				Name=name,

				InitCommand=function(subself)
					self.container = subself

					subself:xy(_screen.cx, _screen.cy)

					if GAMESTATE:GetCurrentSong() then

						if self.index ~= GroupWheel:get_actor_item_at_focus_pos().index then
							subself:playcommand("LoseFocus"):diffusealpha(0)
						else
							-- position this folder in the header
							subself:playcommand("GainFocus"):xy(70,35):zoom(0.35)

							local starting_group = GAMESTATE:GetCurrentSong():GetGroupName()
							switch_to_songs(starting_group)
							MESSAGEMAN:Broadcast("SwitchFocusToSongs")
							MESSAGEMAN:Broadcast("CurrentGroupChanged", {group=starting_group})
						end
					end
				end,
				OnCommand=function(subself) subself:finishtweening() end,

				StartCommand=function(subself)
					if self.index == GroupWheel:get_actor_item_at_focus_pos().index then
						-- slide the chosen Actor into place
						subself:queuecommand("SlideToTop")
						MESSAGEMAN:Broadcast("SwitchFocusToSongs")
					else
						-- hide everything else
						subself:linear(0.2):diffusealpha(0)
					end
				end,
				UnhideCommand=function(subself)
					-- we're going back to group selection
					-- slide the chosen group Actor back into grid position
					if self.index == GroupWheel:get_actor_item_at_focus_pos().index then
						subself:playcommand("SlideBackIntoGrid")
						MESSAGEMAN:Broadcast("SwitchFocusToGroups")
					else
						subself:sleep(0.25):linear(0.2):diffusealpha(1)
					end
				end,
				GainFocusCommand=function(subself) subself:linear(0.2):zoom(0.8) end,
				LoseFocusCommand=function(subself) subself:linear(0.2):zoom(0.6) end,
				SlideToTopCommand=function(subself)
					subself:linear(0.12):y(35):zoom(0.35)
					       :linear(0.2 ):x(70):queuecommand("Switch")
				end,
				SlideBackIntoGridCommand=function(subself)
					subself:linear( 0.2 ):x( _screen.cx )
					       :linear( 0.12 ):zoom( 0.9 ):y( _screen.cy )
				end,
				SwitchCommand=function(subself) switch_to_songs(self.groupName) end,


				-- back of folder
				LoadActor("./img/folderBack.png")..{
					Name="back",
					InitCommand=function(subself) subself:zoom(0.75) end,
					OnCommand=function(subself) subself:y(-10) end,
					GainFocusCommand=function(subself) subself:diffuse(color("#c47215")) end,
					LoseFocusCommand=function(subself) subself:diffuse(color("#4e4f54")) end
				},

				-- group banner
				Def.Banner{
					Name="Banner",
					InitCommand=function(subself) self.banner = subself end,
					OnCommand=function(subself) subself:y(-30):setsize(418,164):zoom(0.48) end,
				},

				-- front of folder
				LoadActor("./img/folderFront.png")..{
					Name="front",
					InitCommand=function(subself) subself:zoom(0.75):vertalign(bottom) end,
					OnCommand=function(subself) subself:y(64) end,
					GainFocusCommand=function(subself) subself:diffusetopedge(color("#eebc54")):diffusebottomedge(color("#7c5505")):decelerate(0.33):rotationx(50) end,
					LoseFocusCommand=function(subself) subself:diffusebottomedge(color("#3d3e43")):diffusetopedge(color("#8d8e93")):decelerate(0.15):rotationx(0) end,
				},

				-- group title bmt
				Def.BitmapText{
					Font="Common Normal",
					InitCommand=function(subself)
						self.bmt = subself
						subself:_wrapwidthpixels(150):vertspacing(-4):shadowlength(0.5)
					end,
					OnCommand=function(subself)
						if self.index == GroupWheel:get_actor_item_at_focus_pos().index then
							subself:horizalign(left):xy(150,-6):zoom(3):diffuse(Color.White):_wrapwidthpixels(480):shadowlength(0):playcommand("Untruncate")
						end
					end,
					UntruncateCommand=function(subself) subself:settext(self.groupName) end,
					TruncateCommand=function(subself) subself:settext(self.groupName):Truncate(max_chars) end,

					GainFocusCommand=function(subself) subself:x(0):horizalign(center):linear(0.15):y(20):zoom(1.1) end,
					LoseFocusCommand=function(subself) subself:xy(0,6):horizalign(center):linear(0.15):zoom(1):diffuse(Color.White) end,

					SlideToTopCommand=function(subself) subself:sleep(0.3):diffuse(Color.White):queuecommand("SlideToTop2") end,
					SlideToTop2Command=function(subself) subself:horizalign(left):linear(0.2):xy(150,-6):zoom(3):_wrapwidthpixels(480):shadowlength(0):playcommand("Untruncate") end,
					SlideBackIntoGridCommand=function(subself) subself:horizalign(center):linear(0.2):xy(0,20):zoom(1.1):diffuse(Color.White):_wrapwidthpixels(150):shadowlength(0.5):playcommand("Truncate") end,
				}
			}

			return af
		end,

		transform = function(self, item_index, num_items, has_focus)

			local offset = item_index - math.floor(num_items/2)
			local zm = scale(math.abs(offset),0,math.floor(num_items/2),0.9,0.05 )
			local ry = offset > 0 and 25 or (offset < 0 and -25 or 0)
			self.container:finishtweening()

			-- if we are initializing the screen, the focus starts (should start) on the SongWheel
			-- so we want to position all the folders "behind the scenes", and then call Init
			-- on the group folder with focus so that it is positioned correctly at the top
			if Input.WheelWithFocus ~= GroupWheel then
				self.container:x( offset * col.w * zm + _screen.cx ):z( -1 * math.abs(offset) ):zoom( zm ):rotationy( ry )
				if has_focus then self.container:playcommand("Init") end

			-- otherwise, we are performing a normal transform
			else
				if has_focus then
					self.container:playcommand("GainFocus")
					MESSAGEMAN:Broadcast("CurrentGroupChanged", {group=self.groupName})
				else
					self.container:playcommand("LoseFocus")
				end
				self.container:x( offset * col.w * zm + _screen.cx ):z( -1 * math.abs(offset) ):zoom( zm ):rotationy( ry )
			end
		end,

		set = function(self, groupName)

			self.groupName = groupName

			-- handle text
			self.bmt:settext(self.groupName):Truncate(max_chars)

			-- handle banner
			self.banner:LoadFromSongGroup(self.groupName):playcommand("On")
		end
	}
}

return item_mt