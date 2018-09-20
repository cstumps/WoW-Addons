-- --------------------------------
-- Panels
-- --------------------------------
local playerClass = select(2, UnitClass("player"))

--if (playerClass == "MAGE" or playerClass == "PALADIN" or playerClass == "HUNTER") then
	local backpanel = CreateFrame("Frame", "Backpanel", UIParent)
	local bpbg = backpanel:CreateTexture(nil, "BACKGROUND")

	bpbg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
	bpbg:SetAllPoints(backpanel)

	backpanel:SetFrameStrata("BACKGROUND")

	backpanel:SetPoint("CENTER", UIParent, "CENTER", 0, -542)
	backpanel:SetWidth(399)
	backpanel:SetHeight(92)

--else
--	local backpanel = CreateFrame("Frame", "Backpanel", UIParent)
--	backpanel:SetFrameStrata("BACKGROUND")
--	backpanel:SetPoint("CENTER", UIParent, "CENTER", 0, -486)
--	backpanel:SetWidth(371)
--	backpanel:SetHeight(65)

--	local bpbg = backpanel:CreateTexture(nil, "BACKGROUND")
--	bpbg:SetAllPoints()
--	bpbg:SetTexture(0.1, 0.1, 0.1, 0.8)

	-- Map panel
--	local mappanel = CreateFrame("Frame", "Mappanel", UIParent)
--	mappanel:SetFrameStrata("BACKGROUND")
--	mappanel:SetPoint("CENTER", UIParent, "CENTER", 245, -458.5)
--	mappanel:SetWidth(120)
--	mappanel:SetHeight(120)

--	local mpbg = mappanel:CreateTexture(nil, "BACKGROUND")
--	mpbg:SetAllPoints()
--	mpbg:SetTexture(0.1, 0.1, 0.1, 0.8)
--end
