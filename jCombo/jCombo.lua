local jcombo = CreateFrame("Frame", "jCombo", UIParent)

local update_rate = 0.2
local frame_anchor, pos_y, pos_x
local playerClass = select(2, UnitClass("player"))

frame_anchor = "BOTTOM"
pos_x = 0
pos_y = 180

local text_anchor = "CENTER"
local font = "Fonts\\frizqt__.ttf"
local size = 14
local text

local color = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
local class = select(2, UnitClass("player"))

function jcombo:new()
	text = self:CreateFontString(nil, "OVERLAY")
	
	if (class == "MAGE") then
		text:SetFont(font, size, "OUTLINE")
	else
		text:SetFont(font, size, nil)
	end

	text:SetPoint(text_anchor, self)
	text:SetTextColor(color.r, color.g, color.b)

	self:SetPoint(frame_anchor, UIParent, frame_anchor, pos_x, pos_y)
	self:SetWidth(50)
	self:SetHeight(26)

	self:SetScript("OnUpdate", self.update)
	self:SetScript("OnEnter", self.enter)
end

local time_elapsed = 0

function jcombo:update(elapsed)
	time_elapsed = time_elapsed + elapsed

	if (time_elapsed < update_rate) then
		return
	end

	time_elapsed = 0

	if (class == "ROGUE") then
		text:SetText(GetComboPoints("player", "target"))
	else
		text:SetText(UnitPower("player", SPELL_POWER_ARCANE_CHARGES))
	end

	self:SetWidth(text:GetStringWidth())
end

jcombo:new()