-- --------------------------------
-- Minimap stuff
-- --------------------------------
local function kill() end

local omenButton
local bwButton
local jPadButton

-- -------------------------------
-- Settings
-- -------------------------------
local playerClass = select(2, UnitClass("player"))

local mapScale, mapX, mapY
local buttonScale

if (playerClass == "MAGE") then
	mapScale = 0.61
	buttonScale = 0.6
	mapX = 153
	mapY = 16
elseif (playerClass == "ROGUE") then
	mapScale = 0.61
	buttonScale = 0.6
	mapX = 153
	mapY = 16
elseif (playerClass == "HUNTER") then
	mapScale = 0.61
	buttonScale = 0.6
	mapX = 153
	mapY = 16
elseif (playerClass == "PALADIN") then
	mapScale = 0.61
	buttonScale = 0.6
	mapX = 153
	mapY = 16
else
	mapScale = 0.61
	buttonScale = 0.6
	mapX = 153
	mapY = 16
end
-- -------------------------------

Minimap:SetMaskTexture("Interface\\BUTTONS\\WHITE8X8")

--MinimapCluster:SetFrameStrata("BACKGROUND")
--MinimapCluster:ClearAllPoints()
--MinimapCluster:SetPoint("BOTTOM", UIParent, "BOTTOM", mapX, mapY)
Minimap:ClearAllPoints()
--Minimap:SetMovable(true)
--Minimap:SetUserPlaced(true)
Minimap:SetWidth(Minimap:GetWidth() * mapScale)
Minimap:SetHeight(Minimap:GetHeight() * mapScale)
Minimap:SetPoint("BOTTOM", UIParent, "BOTTOM", mapX, mapY)

MinimapBorder:Hide()
MinimapBorderTop:Hide()
MinimapZoomIn:Hide()
MinimapZoomOut:Hide()

MinimapNorthTag.Show = kill
MinimapNorthTag:Hide()

GameTimeFrame:Hide()
--TimeManagerClockButton:GetReigons():Hide()
--TimeManagerClockButton:UnregisterAllEvents()
--TimeManagerClockButton:Hide()
--TimeManagerClockButton:ClearAllPoints()

MinimapZoneTextButton:Hide()
MinimapZoneTextButton:UnregisterAllEvents()

MiniMapWorldMapButton:Hide()
MiniMapWorldMapButton:UnregisterAllEvents()

-- MiniMapVoiceChatFrame:Hide()
-- MiniMapVoiceChatFrame:UnregisterAllEvents()
-- MiniMapVoiceChatFrame.Show = kill

MiniMapInstanceDifficulty:Hide()
MiniMapInstanceDifficulty.Show = kill

MiniMapTracking:ClearAllPoints()
MiniMapTracking:SetPoint("BOTTOM", Minimap, 0, -13)
MiniMapTracking:SetScale(buttonScale)
MiniMapTracking:Hide()

MiniMapMailFrame:ClearAllPoints()
MiniMapMailFrame:SetPoint("RIGHT", Minimap, 14, 0)
MiniMapMailFrame:SetScale(buttonScale)

-- Garrison Report Button Placement
GarrisonLandingPageMinimapButton:ClearAllPoints()
GarrisonLandingPageMinimapButton:SetPoint("RIGHT", Minimap, 26, -35)
GarrisonLandingPageMinimapButton:SetScale(buttonScale)

QueueStatusMinimapButton:ClearAllPoints()
QueueStatusMinimapButton:SetPoint("RIGHT", Minimap, 14, 30)
QueueStatusMinimapButton:SetScale(buttonScale)

DurabilityFrame:Hide()
DurabilityFrame.Show = kill

-- MiniMapBattlefieldFrame:ClearAllPoints()
-- MiniMapBattlefieldFrame:SetPoint("RIGHT", Minimap, 14, -30)
-- MiniMapBattlefieldFrame:SetScale(buttonScale)

--hooksecurefunc(WatchFrame, "SetPoint", function(_, _, parent)
--	if (parent == "MinimapCluster") or (parent == _G["MinimapCluster"]) then
--		WatchFrame:ClearAllPoints()
--		WatchFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, -300)
--	end
--end)

Minimap:EnableMouseWheel(true)
Minimap:SetScript("OnMouseWheel", function(self, d)
	if d > 0 then
		_G.MinimapZoomIn:Click()
	elseif d < 0 then
		_G.MinimapZoomOut:Click()
	end
end)

Minimap:SetScript("OnEnter", function(self, d)
	MiniMapTracking:Show()

	if ( omenButton ~= nil ) then
		omenButton:Show()
	end

	if ( bwButton ~= nil ) then
		bwButton:Show()
	end

	-- if ( jPadButton ~= nil ) then
	-- 	jPadButton:Show()
	-- end

	--local kids = { UIParent:GetChildren() };

	--for _, child in ipairs(kids) do
	--	print( child:GetName() )
	--end
end)

Minimap:SetScript("OnLeave", function(self, d)
	local mouseFocus

	if ( GetMouseFocus() == nil ) then
		mouseFocus = nil
	else
		mouseFocus = GetMouseFocus():GetName()
	end

	if ( mouseFocus ~= "MiniMapTrackingButton" and mouseFocus ~= "LibDBIcon10_Omen" and mouseFocus ~= "LibDBIcon10_BigWigs" ) then
		MiniMapTracking:Hide()

		if ( omenButton ~= nil ) then
			omenButton:Hide()
		end

		if ( bwButton ~= nil ) then
			bwButton:Hide()
		end

		-- if ( jPadButton ~= nil ) then
		-- 	jPadButton:Hide()
		-- end
	end
end)

local function HideButtons(self, d)
	MiniMapTracking:Hide()
	GameTooltip:Hide()

	if ( omenButton ~= nil ) then
		omenButton:Hide()
	end

	if ( bwButton ~= nil ) then
		bwButton:Hide()
	end

	-- if ( jPadButton ~= nil ) then
	-- 	jPadButton:Hide()
	-- end
end

local evtFrame = CreateFrame('Frame')
evtFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
evtFrame:SetScript('OnEvent', function(self)
	local kids = { Minimap:GetChildren() };

	for _, child in ipairs(kids) do
		if ( child:GetName() == "LibDBIcon10_BigWigs" ) then
			child:ClearAllPoints()
			child:SetPoint("BOTTOM", Minimap, 30, -13)
			child:SetScale(buttonScale)
			child:Hide()

			bwButton = child
		elseif ( child:GetName() == "LibDBIcon10_Omen" ) then
			child:ClearAllPoints()
			child:SetPoint("BOTTOM", Minimap, -30, -13)
			child:SetScale(buttonScale)
			child:Hide()

			omenButton = child
		elseif ( child:GetName() == "jPadMiniButton" ) then
			child:ClearAllPoints()
			child:SetPoint("RIGHT", Minimap, 12, 35)
			child:SetScale(buttonScale)
			--child:Hide()

			jPadButton = child
		end
	end

	MiniMapTrackingButton:SetScript("OnLeave", HideButtons)

	if ( omenButton ~= nil ) then
		omenButton:SetScript("OnLeave", HideButtons)
	end

	if ( bwButton ~= nil ) then
		bwButton:SetScript("OnLeave", HideButtons)
	end

	-- if ( jPadButton ~= nil ) then
	-- 	jPadButton:SetScript( "OnLeave", HideButtons )
	-- end
end)