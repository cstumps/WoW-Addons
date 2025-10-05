local Apoint = "TOP"
local Bpoint = "TOP"
local xOffSet = 0
local yOffSet = -7

hooksecurefunc("GameTooltip_SetDefaultAnchor", function (tooltip, parent)
		tooltip:ClearAllPoints()
		--tooltip:SetOwner(UIParent,"ANCHOR_TOP")
		tooltip:SetPoint(Apoint, UIParent, Bpoint, xOffSet, yOffSet)
end);