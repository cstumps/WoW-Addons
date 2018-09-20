local jclock = CreateFrame("Frame", "jClock", UIParent)

local frame_anchor, pos_y, pos_x
local playerClass = select(2, UnitClass("player"))

if (playerClass == "MAGE") then
	frame_anchor = "BOTTOM"
	pos_x = 90
	pos_y = 14
elseif (playerClass == "HUNTER") then
	frame_anchor = "BOTTOM"
	pos_x = 90
	pos_y = 14
elseif (playerClass == "ROGUE") then
	frame_anchor = "BOTTOM"
	pos_x = 88
	pos_y = 14
elseif (playerClass == "PALADIN") then
	frame_anchor = "BOTTOM"
	pos_x = 88
	pos_y = 14
else
	frame_anchor = "BOTTOM"
	pos_x = 88
	pos_y = 14
end


local clock_anchor = "TOPRIGHT"
local clock_size = 14 --16

local text_anchor = "BOTTOMRIGHT"
local font = "Fonts\\frizqt__.ttf"
local size = 12

local color = RAID_CLASS_COLORS[select(2, UnitClass("player"))]

local ticktack, lag, fps, text, clock

function jclock:new()
	clock = self:CreateFontString(nil, "OVERLAY")
	text = self:CreateFontString(nil, "OVERLAY")

	clock:SetFont(font, clock_size, nil)
	text:SetFont(font, size, nil)

	clock:SetPoint(clock_anchor, self, clock_anchor, 0, 0)
	clock:SetTextColor(color.r, color.g, color.b)

	text:SetPoint(text_anchor, self)
	text:SetTextColor(color.r, color.g, color.b)

	self:SetPoint(frame_anchor, UIParent, frame_anchor, pos_x, pos_y)
	self:SetWidth(50)
	self:SetHeight(26)

	self:SetScript("OnUpdate", self.update)
	self:SetScript("OnEnter", self.enter)
	--self:SetScript("OnLeave", function() GameTooltip:Hide() end)
	--self:SetScript("OnClick", function() cleargarbage() end)
end

local last = 0
function jclock:update(elapsed)
	last = last + elapsed

	if last > 1 then
		-- date thingy
		ticktack = "|c00ffffff"..date("%I:%M ").."|r"

		-- fps crap
		fps = GetFramerate()
		fps = "|c00ffffff"..floor(fps).."|rfps "

		-- right down downright + punch
		lag = select(3, GetNetStats())
		lag = "|c00ffffff"..lag.."|rms "

		-- reset timer
		last = 0

		-- the magic!
		clock:SetText(ticktack)
		--text:SetText(fps.."|c00ffff00+"..lag)
		text:SetText(lag)

		self:SetWidth(text:GetStringWidth())
	end
end

jclock:new()