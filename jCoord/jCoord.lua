local jcoord = CreateFrame("Frame", "jCoord", UIParent)

local frame_anchor, pos_y, pos_x

--frame_anchor = "TOPRIGHT"
--pos_x = -10
--pos_y = 0

frame_anchor = "BOTTOM"
pos_x = 152
pos_y = 102

local color = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
local font = "Fonts\\frizqt__.ttf"
local size = 12

function jCoord:new()
	coords = self:CreateFontString(nil, "OVERLAY")
	coords:SetFont(font, size, nil)

	coords:SetPoint("CENTER", self)
	coords:SetTextColor(color.r, color.g, color.b)

	self:SetPoint(frame_anchor, UIParent, frame_anchor, pos_x, pos_y)
	self:SetWidth(50)
	self:SetHeight(20)

	self:SetScript("OnUpdate", self.update)
end

local last = 0
function jCoord:update(elapsed)
	last = last + elapsed

	if last > 1 then
		local mapID = C_Map.GetBestMapForUnit("player")

		if mapID then
			x, y = C_Map.GetPlayerMapPosition(mapID, "player"):GetXY()
			coords:SetText(string.format( "%.1f", x*100 ) .. " , " .. string.format( "%.1f", y*100) )

			self:SetWidth(coords:GetStringWidth())
			last = 0
		end
	end
end

jcoord:new()