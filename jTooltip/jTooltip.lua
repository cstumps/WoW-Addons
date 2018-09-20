local Apoint = "TOP"
local Bpoint = "TOP"
local xOffSet = 0
local yOffSet = 0

hooksecurefunc("GameTooltip_SetDefaultAnchor", function (tooltip, parent)
		tooltip:SetOwner(parent,"ANCHOR_TOP")
		tooltip:SetPoint(Apoint, UIParent, Bpoint, xOffSet, yOffSet)
end);