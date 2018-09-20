--[[

	oUF_Lyn

	Author:		Lyn
	Mail:		post@endlessly.de
	URL:		http://www.wowinterface.com/list.php?skinnerid=62149

	Credits:	oUF_TsoHG (used as base) / http://www.wowinterface.com/downloads/info8739-oUF_TsoHG.html
				Rothar for buff border (and Neal for the edited version)
				p3lim for party toggle function

--]]

-- ------------------------------------------------------------------------
-- local horror
-- ------------------------------------------------------------------------
local select = select
local UnitClass = UnitClass
local UnitIsDead = UnitIsDead
local UnitIsPVP = UnitIsPVP
local UnitIsGhost = UnitIsGhost
local UnitIsPlayer = UnitIsPlayer
local UnitReaction = UnitReaction
local UnitIsConnected = UnitIsConnected
local UnitCreatureType = UnitCreatureType
local UnitClassification = UnitClassification
local UnitReactionColor = UnitReactionColor
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

-- ------------------------------------------------------------------------
-- font, fontsize and textures
-- ------------------------------------------------------------------------
local font = "Interface\\AddOns\\oUF_Lyn\\fonts\\font.ttf"
local upperfont = "Interface\\AddOns\\oUF_Lyn\\fonts\\upperfont.ttf"
local fontsize = 10
local bartex = "Interface\\AddOns\\oUF_Lyn\\textures\\statusbar"
local bufftex = "Interface\\AddOns\\oUF_Lyn\\textures\\border"
local playerClass = select(2, UnitClass("player"))

-- castbar position
local playerCastBar_x = 0
local playerCastBar_y = -300
local targetCastBar_x = 0
local targetCastBar_y = -413

-- ------------------------------------------------------------------------
-- change some colors :)
-- ------------------------------------------------------------------------
oUF.colors.happiness = {
	[1] = {182/225, 34/255, 32/255},	-- unhappy
	[2] = {220/225, 180/225, 52/225},	-- content
	[3] = {143/255, 194/255, 32/255},	-- happy
}

-- ------------------------------------------------------------------------
-- right click
-- ------------------------------------------------------------------------
local menu = function(self)
	local unit = self.unit:sub(1, -2)
	local cunit = self.unit:gsub("(.)", string.upper, 1)

	if(unit == "party" or unit == "partypet") then
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor", 0, 0)
	elseif(_G[cunit.."FrameDropDown"]) then
		ToggleDropDownMenu(1, nil, _G[cunit.."FrameDropDown"], "cursor", 0, 0)
	end
end

-- ------------------------------------------------------------------------
-- reformat everything above 9999, i.e. 10000 -> 10k
-- ------------------------------------------------------------------------
local numberize = function(v)
	if v <= 9999 then return v end
	if v >= 1000000 then
		local value = string.format("%.1fm", v/1000000)
		return value
	elseif v >= 10000 then
		local value = string.format("%.1fk", v/1000)
		return value
	end
end

-- ------------------------------------------------------------------------
-- level update
-- ------------------------------------------------------------------------
oUF.Tags['lyn:level'] = function(unit)
	local lvl = UnitLevel(unit)
	local color = GetQuestDifficultyColor(lvl)

	if ( lvl <= 0 ) then
		lvl = "??"
	end

	-- Level/Colors for players
	if ( UnitIsPlayer(unit) ) then
		local class, cname = UnitClass(unit)

		color = RAID_CLASS_COLORS[cname]

		return Hex(color.r, color.g, color.b)..lvl

	-- Level/Colors for npcs
	else
		local typ = UnitClassification(unit)

		if ( typ == "worldboss" ) then
			return "|cffff0000"..lvl
		else
			return Hex(color.r, color.g, color.b)..lvl
		end
	end
end

-- ------------------------------------------------------------------------
-- health update
-- ------------------------------------------------------------------------
oUF.Tags['lyn:health'] = function(unit)
	local cur = UnitHealth(unit)
	local max = UnitHealthMax(unit)
	local d = floor( cur / max * 100 )

	if ( unit == "player" ) then
		return numberize( cur ).."|r."..d.."%"
	elseif ( unit == "target" ) then
		return d.."%"
	end
end

oUF.TagEvents['lyn:health'] = oUF.TagEvents.missinghp

local updateHealth = function(health, unit, min, max)
	if(UnitIsDead(unit) or UnitIsGhost(unit)) then
		health:SetValue(0)
		health.value:SetText("dead")
	elseif(not UnitIsConnected(unit)) then
		health.value:SetText("offline")
	elseif(min == max) then
		health.value:SetText()
    end
end

-- ------------------------------------------------------------------------
-- power update
-- ------------------------------------------------------------------------
oUF.Tags['lyn:power'] = function(unit)
	local cur = UnitPower(unit)
	local max = UnitPowerMax(unit)
	local d = floor( cur / max * 100 )

	if ( unit == "player" ) then
		return numberize(cur).."|r."..d.."%"
	elseif ( unit == "target" ) then
		return d.."%"
	end
end

oUF.TagEvents['lyn:power'] = oUF.TagEvents.missingpp

local updatePower = function(power, unit, min, max)
	if(UnitIsDead(unit) or UnitIsGhost(unit)) then
		power:SetValue(0)
	elseif(min==0 or min==max) then
		power.value:SetText()
	elseif(not UnitIsConnected(unit)) then
		power.value:SetText()
	end
end

-- ------------------------------------------------------------------------
-- buff reskin
-- ------------------------------------------------------------------------
local buffIcon = function(self, button)
	button.icon.showDebuffType = true -- show debuff border type color

	button.icon:SetTexCoord(.07, .93, .07, .93)
	button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
	button.icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)

	button.overlay:SetTexture(bufftex)
	button.overlay:SetTexCoord(0,1,0,1)

	button.overlay.Hide = function(self) self:SetVertexColor(0.3, 0.3, 0.3) end

	button.cd:SetReverse()
	button.cd:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
	button.cd:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
end

-- ------------------------------------------------------------------------
-- the layout starts here
-- ------------------------------------------------------------------------
local func = function(self, unit)
	self.menu = menu -- Enable the menus

	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)

	self:RegisterForClicks"anyup"
	self:SetAttribute("*type2", "menu")

	--
	-- background
	--
	self:SetBackdrop{
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16,
	insets = {left = -2, right = -2, top = -2, bottom = -2},
	}
	self:SetBackdropColor(0,0,0,1) -- and color the backgrounds

	--
	-- healthbar
	--
	self.Health = CreateFrame"StatusBar"
	self.Health:SetHeight(19) -- Custom height
	self.Health:SetStatusBarTexture(bartex)
   	self.Health:SetParent(self)
	self.Health:SetPoint"TOP"
	self.Health:SetPoint"LEFT"
	self.Health:SetPoint"RIGHT"
	--
	-- healthbar background
	--
	self.Health.bg = self.Health:CreateTexture(nil, "BORDER")
	self.Health.bg:SetAllPoints(self.Health)
	self.Health.bg:SetTexture(bartex)
	self.Health.bg:SetAlpha(0.30)

	--
	-- healthbar text
	--
	self.Health.value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.value:SetFont(font, 10, nil)
	self.Health.value:SetJustifyH("RIGHT")

	--
	-- healthbar functions
	--
	self.Health.colorClass = true
	self.Health.colorReaction = true
	self.Health.colorDisconnected = true
	self.Health.colorTapping = true
	self.Health.PostUpdate = updateHealth -- let the colors be

	self:Tag( self.Health.value, '[lyn:health]' )

	--
	-- powerbar
	--
	self.Power = CreateFrame"StatusBar"
	self.Power:SetHeight(3)
	self.Power:SetStatusBarTexture(bartex)
	self.Power:SetParent(self)
	self.Power:SetPoint"LEFT"
	self.Power:SetPoint"RIGHT"
	self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -1.45) -- Little offset to make it pretty

	--
	-- powerbar background
	--
	self.Power.bg = self.Power:CreateTexture(nil, "BORDER")
	self.Power.bg:SetAllPoints(self.Power)
	self.Power.bg:SetTexture(bartex)
	self.Power.bg:SetAlpha(0.30)

	--
	-- powerbar text
	--
	self.Power.value = self.Power:CreateFontString(nil, "OVERLAY")
    self.Power.value:SetJustifyH("RIGHT")
	self.Power.value:SetFont(font, 8, nil)

    	--
	-- powerbar functions
	--
	self.Power.colorTapping = true
	self.Power.colorDisconnected = true
	self.Power.colorClass = true
	self.Power.colorPower = true
	self.Power.colorHappiness = false
	self.Power.PostUpdate = updatePower -- let the colors be

	self:Tag( self.Power.value, '[lyn:power]' )

	--
	-- names
	--
	self.Name = self.Health:CreateFontString(nil, "OVERLAY")
    self.Name:SetPoint("LEFT", self, 0, 17)
    self.Name:SetJustifyH("LEFT")
	self.Name:SetFont(upperfont, fontsize, nil)
	-- self.Name:SetShadowOffset(1, -1)

    self:Tag(self.Name, '[name]')

	--
	-- level
	--
	self.Level = self.Health:CreateFontString(nil, "OVERLAY")
	self.Level:SetPoint("LEFT", self.Health, -2, 14)
	self.Level:SetJustifyH("LEFT")
	self.Level:SetFont(font, fontsize, nil)
    self.Level:SetTextColor(1,1,1)
	-- self.Level:SetShadowOffset(1, -1)

	self:Tag(self.Level, '[lyn:level]')


	-- ------------------------------------
	-- player
	-- ------------------------------------
    if unit=="player" then
        self:SetWidth(145)
      	self:SetHeight(16)
		self.Health:SetHeight(12.5)
		self.Name:Hide()
		self.Power:SetHeight(2)
        self.Power.value:Show()
		self.Level:Hide()
		self.Health.value:SetPoint("RIGHT", -150, 3)
		self.Power.value:SetPoint("RIGHT", -150, 1)

		--[[
	--	if(playerClass=="DRUID") then
	--		-- bar
	--		self.DruidMana = CreateFrame('StatusBar', nil, self)
	--		self.DruidMana:SetPoint('TOP', self, 'BOTTOM', 0, -6)
	--		self.DruidMana:SetStatusBarTexture(bartex)
	--		self.DruidMana:SetStatusBarColor(45/255, 113/255, 191/255)
	--		self.DruidMana:SetHeight(10)
	--		self.DruidMana:SetWidth(250)
	--		-- bar bg
	--		self.DruidMana.bg = self.DruidMana:CreateTexture(nil, "BORDER")
	--		self.DruidMana.bg:SetAllPoints(self.DruidMana)
	--		self.DruidMana.bg:SetTexture(bartex)
	--		self.DruidMana.bg:SetAlpha(0.30)
	--		-- black bg
	--		self.DruidMana:SetBackdrop{
	--			bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16,
	--			insets = {left = -2, right = -2.5, top = -2.5, bottom = -2},
	--			}
	--		self.DruidMana:SetBackdropColor(0,0,0,1)
	--		-- text
	--		self.DruidManaText = self.DruidMana:CreateFontString(nil, 'OVERLAY')
	--		self.DruidManaText:SetPoint("CENTER", self.DruidMana, "CENTER", 0, 1)
	--		self.DruidManaText:SetFont(font, 12, "OUTLINE")
	--		self.DruidManaText:SetTextColor(1,1,1)
	--		self.DruidManaText:SetShadowOffset(1, -1)
	--	end
	--	--]]

		--
		-- leader icon
		--
		self.Leader = self.Health:CreateTexture(nil, "OVERLAY")
		self.Leader:SetHeight(12)
		self.Leader:SetWidth(12)
		self.Leader:SetPoint("BOTTOMRIGHT", self, -2, 4)
		self.Leader:SetTexture"Interface\\GroupFrame\\UI-Group-LeaderIcon"

		--
		-- raid target icons
		--
		self.RaidIcon = self.Health:CreateTexture(nil, "OVERLAY")
		self.RaidIcon:SetHeight(16)
		self.RaidIcon:SetWidth(16)
		self.RaidIcon:SetPoint("TOP", self, 0, 9)
		self.RaidIcon:SetTexture"Interface\\TargetingFrame\\UI-RaidTargetingIcons"

		--
		-- oUF_PowerSpark support
		--
        	--self.Spark = self.Power:CreateTexture(nil, "OVERLAY")
		--self.Spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
		--self.Spark:SetVertexColor(1, 1, 1, 1)
		--self.Spark:SetBlendMode("ADD")
		--self.Spark:SetHeight(self.Power:GetHeight()*2.5)
		--self.Spark:SetWidth(self.Power:GetHeight()*2)
        	-- self.Spark.rtl = true -- Make the spark go from Right To Left instead
		-- self.Spark.manatick = true -- Show mana regen ticks outside FSR (like the energy ticker)
		-- self.Spark.highAlpha = 1 	-- What alpha setting to use for the FSR and energy spark
		-- self.Spark.lowAlpha = 0.25 -- What alpha setting to use for the mana regen ticker

		--
		-- oUF_BarFader
		--
		--self.BarFade = true
		--self.BarFadeAlpha = 0.2
	end

	-- ------------------------------------
	-- pet
	-- ------------------------------------
	--if unit=="pet" then
	--	self:SetWidth(120)
	--	self:SetHeight(18)
	--	self.Health:SetHeight(18)
	--	self.Power:Hide()
	--	self.Health.value:Hide()
	--	self.Level:Hide()
	--	self.Name:Hide()

	--	if playerClass=="HUNTER" then
	--		self.Health.colorReaction = false
	--		self.Health.colorClass = false
	--		self.Health.colorHappiness = true
	--	end

		--
		-- oUF_BarFader
		--
		--self.BarFade = true
		--self.BarFadeAlpha = 0.2
	--end

	-- ------------------------------------
	-- target
	-- ------------------------------------
    if unit=="target" then
		self:SetWidth(145)
		self:SetHeight(16)
		self.Health:SetHeight(12.5)
		self.Power:SetHeight(2)
		self.Name:SetPoint("LEFT", self.Level, "RIGHT", 2, 0)
		self.Name:SetHeight(20)
		self.Name:SetWidth(150)

		self.Health.value:SetPoint("LEFT", 148, 3)
		self.Power.value:SetPoint("LEFT", 148, 1)

		self.Health.colorClass = false

		--
		-- combo points
		--
		--if(playerClass=="ROGUE" or playerClass=="DRUID") then
		--	self.CPoints = self:CreateFontString(nil, "OVERLAY")
		--	self.CPoints:SetPoint("RIGHT", self, "LEFT", -10, 0)
		--	self.CPoints:SetFont(font, 38, "OUTLINE")
		--	self.CPoints:SetTextColor(0, 0.81, 1)
		--	self.CPoints:SetShadowOffset(1, -1)
		--	self.CPoints:SetJustifyH"RIGHT"
		--end

		--
		-- raid target icons
		--
		--self.RaidIcon = self.Health:CreateTexture(nil, "OVERLAY")
		--self.RaidIcon:SetHeight(24)
		--self.RaidIcon:SetWidth(24)
		--self.RaidIcon:SetPoint("RIGHT", self, 30, 0)
		--self.RaidIcon:SetTexture"Interface\\TargetingFrame\\UI-RaidTargetingIcons"

		--
		-- buffs
		--
		self.Buffs = CreateFrame("Frame", nil, self) -- buffs
		self.Buffs.size = 16
		self.Buffs:SetHeight(self.Buffs.size)
		self.Buffs:SetWidth(self.Buffs.size * 9)
		self.Buffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", -2, 18)
		self.Buffs.initialAnchor = "BOTTOMLEFT"
		self.Buffs["growth-y"] = "TOP"
		self.Buffs.num = 16
		self.Buffs.spacing = 2

		self.Buffs.PostCreateIcon = buffIcon

		--
		-- debuffs
		--
		self.Debuffs = CreateFrame("Frame", nil, self)
		self.Debuffs.size = 16
		self.Debuffs:SetHeight(self.Debuffs.size)
		self.Debuffs:SetWidth(self.Debuffs.size * 9)
		self.Debuffs:SetPoint("TOPLEFT", self, "BOTTOMLEFT", -2, -4)
		self.Debuffs.initialAnchor = "BOTTOMLEFT"
		self.Debuffs.filter = false
		self.Debuffs.num = 8
		self.Debuffs.spacing = 2

		self.Debuffs.PostCreateIcon = buffIcon
	end

	-- ------------------------------------
	-- target of target and focus
	-- ------------------------------------
	--if unit=="targettarget" or unit=="focus" then
	if unit=="targettarget" then
		--if (self:GetParent():GetName():match"oUF_Raid" or self:GetParent():GetName():match"oUF_Party") then
			self:SetWidth(60)
			self:SetHeight(16)
			self.Health:SetHeight(16)
			self.Power:Hide()
			self.Power.value:Hide()
			self.Health.value:Hide()
			self.Level:Hide()
		--end
	end


			--
			-- raid target icons
			--
	--		self.RaidIcon = self.Health:CreateTexture(nil, "OVERLAY")
	--		self.RaidIcon:SetHeight(16)
	--		self.RaidIcon:SetWidth(16)
	--		self.RaidIcon:SetPoint("RIGHT", self, 0, 9)
	--		self.RaidIcon:SetTexture"Interface\\TargetingFrame\\UI-RaidTargetingIcons"

			--
			-- oUF_BarFader
			--
			--if unit=="focus" then
			--	self.BarFade = true
			--	self.BarFadeAlpha = 0.2
			--end
	--	end
	--end

	-- ------------------------------------
	-- player and target castbar
	-- ------------------------------------
	if(unit == 'player' or unit == 'target') then
	    	self.Castbar = CreateFrame('StatusBar', nil, self)
	    	self.Castbar:SetStatusBarTexture(bartex)

		if(unit == "player") then
			self.Castbar:SetStatusBarColor(1, 0.50, 0)
			self.Castbar:SetHeight(8)
			self.Castbar:SetWidth(250)

			self.Castbar:SetBackdrop({
				bgFile = "Interface\ChatFrame\ChatFrameBackground",
				insets = {top = -3, left = -3, bottom = -3, right = -3}})

			self.Castbar:SetPoint('CENTER', UIParent, 'CENTER', playerCastBar_x, playerCastBar_y)
		else
			self.Castbar:SetStatusBarColor(0.80, 0.01, 0)
			self.Castbar:SetHeight(8)
			self.Castbar:SetWidth(250)

			self.Castbar:SetBackdrop({
			bgFile = "Interface\ChatFrame\ChatFrameBackground",
			insets = {top = -3, left = -30, bottom = -3, right = -3}})

			self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY")
			self.Castbar.Text:SetPoint('TOPLEFT', -1, 12)
			self.Castbar.Text:SetFont(upperfont, 10, nil)
			self.Castbar.Text:SetShadowOffset(1, -1)
			self.Castbar.Text:SetTextColor(1, 1, 1)
	    		self.Castbar.Text:SetJustifyH('RIGHT')

			self.Castbar:SetPoint('CENTER', UIParent, 'CENTER', targetCastBar_x, targetCastBar_y)
		end

		self.Castbar:SetBackdropColor(0, 0, 0, 0.5)

	    	self.Castbar.bg = self.Castbar:CreateTexture(nil, 'BORDER')
	    	self.Castbar.bg:SetAllPoints(self.Castbar)
	    	self.Castbar.bg:SetTexture(0, 0, 0, 0.6)

	    	self.Castbar.Time = self.Castbar:CreateFontString(nil, "OVERLAY")
	    	self.Castbar.Time:SetPoint("LEFT", self.Castbar, "RIGHT", 4, 0)
	    	self.Castbar.Time:SetFont(upperfont, 10, nil)
	    	self.Castbar.Time:SetTextColor(1, 1, 1)
	    	self.Castbar.Time:SetJustifyH("LEFT")
	end

	--
	-- raid target icons
	--
	if(self:GetParent():GetName():match"oUF_Raid") then
		self.RaidIcon = self.Health:CreateTexture(nil, "OVERLAY")
		self.RaidIcon:SetHeight(12)
		self.RaidIcon:SetWidth(12)
		self.RaidIcon:SetPoint("RIGHT", self, -5, 0)
		self.RaidIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
	end

	-- ------------------------------------
	-- party
	-- ------------------------------------
	--if(self:GetParent():GetName():match"oUF_Party") then
	--	self:SetWidth(160)
	--	self:SetHeight(20)
	--	self.Health:SetHeight(15)
	--	self.Power:SetHeight(3)
	--	self.Power.value:Hide()
	--	self.Health.value:SetPoint("RIGHT", 0 , 9)
	--	self.Name:SetPoint("LEFT", 0, 9)

		--
		-- debuffs
		--
	--	self.Debuffs = CreateFrame("Frame", nil, self)
	--	self.Debuffs.size = 20 * 1.3
	--	self.Debuffs:SetHeight(self.Debuffs.size)
	--	self.Debuffs:SetWidth(self.Debuffs.size * 5)
	--	self.Debuffs:SetPoint("LEFT", self, "RIGHT", 5, 0)
	--	self.Debuffs.initialAnchor = "TOPLEFT"
	--    self.Debuffs.filter = false
	--	self.Debuffs.showDebuffType = true
	--	self.Debuffs.spacing = 2
	--	self.Debuffs.num = 2 -- max debuffs

		--
		-- raid target icons
		--
	--	self.RaidIcon = self.Health:CreateTexture(nil, "OVERLAY")
	--	self.RaidIcon:SetHeight(12)
	--	self.RaidIcon:SetWidth(12)
	--	self.RaidIcon:SetPoint("RIGHT", self, -5, 0)
	--	self.RaidIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
	--end

	-- -----------------------------------
	-- Raid
	-- -----------------------------------
	--if(self:GetParent():GetName():match"oUF_Raid") then
	--	local raiddiff = GetRaidDifficulty()

	--	self:SetHeight(12)
	--	self.Health:SetHeight(12)
	--	self.Power:Hide()
	--	self.Health:SetFrameLevel(2)
	--	self.Power:SetFrameLevel(2)
	--	self.Health.value:Hide()
	--	self.Power.value:Hide()

	   	-- 10 man raids
	--   	if ( raiddiff == 1 or raiddiff == 3 ) then
	--		self:SetWidth(65)
	--		self.Name:SetFont(font, 10, nil)
	--		self.Name:SetWidth(65)
	--		self.Name:SetHeight(15)
	--		self.Name:SetPoint("LEFT", self, 2, 1)
	--	elseif ( raiddiff == 2 or raiddiff == 4 ) then
	--	-- 25 man raids
	--		self:SetWidth(23)
	--		self.Name:Hide()
	--	else
	--	-- 40 man raids
	--		self:SetWidth(12.5)
	--		self.Name:Hide()
	--	end
	--end

	--
	-- custom aura textures
	--
	self.PostCreateAuraIcon = auraIcon
	self.SetAuraPosition = auraOffset

	--if(self:GetParent():GetName():match"oUF_Party") then
	--	self:SetAttribute('initial-height', 20)
	--	self:SetAttribute('initial-width', 160)
	--else
		self:SetAttribute('initial-height', height)
		self:SetAttribute('initial-width', width)
	--end

	return self
end

-- ------------------------------------------------------------------------
-- spawning the frames
-- ------------------------------------------------------------------------

--
-- normal frames
--
oUF:RegisterStyle("Lyn", func)
oUF:SetActiveStyle("Lyn")

local player = oUF:Spawn("player", "oUF_Player")
player:SetPoint("BOTTOM", -125,140)

local target = oUF:Spawn("target", "oUF_Target")
target:SetPoint("BOTTOM", 125, 140)

local tot = oUF:Spawn("targettarget", "oUF_TargetTarget")
tot:SetPoint("BOTTOM", 257, 140)

--local pet = oUF:Spawn("pet", "oUF_Pet")
--pet:SetPoint("BOTTOMLEFT", player, 0, -30)

local focus = oUF:Spawn("focus", "oUF_Focus")
focus:Hide()
--focus:SetPoint("TOPRIGHT", player, -330, 0)

--
-- party
--
--local party	= oUF:Spawn("header", "oUF_Party")
--party:SetManyAttributes("showParty", true, "yOffset", -15)
--party:SetPoint("TOPLEFT", 35, -200)
--party:Show()
--party:SetAttribute("showRaid", false)

--
-- raid
--
--local Raid = {}
--local raiddiff = GetRaidDifficulty()
--local raidgroups = 1

--if (raiddiff == 1 or raiddiff == 3) then
--	raidgroups = 2
--else
--	raidgroups = 5
--end

--for i = 1, NUM_RAID_GROUPS do
--	local RaidGroup = oUF:Spawn("header", "oUF_Raid" .. i)
--	RaidGroup:SetAttribute("groupFilter", tostring(i))
--	RaidGroup:SetAttribute("yOffset", -5)
--	RaidGroup:SetAttribute("point", "TOP")
--	RaidGroup:SetAttribute("showRaid", true)
--	table.insert(Raid, RaidGroup)
--	if i == 1 then
--		RaidGroup:SetPoint("BOTTOMLEFT", UIParent, 500, 15)
--	else
--		RaidGroup:SetPoint("TOPLEFT", Raid[i-1], "TOPRIGHT", 5, 0)
--	end
--	RaidGroup:Show()
--end

--
-- party toggle in raid
--
--local partyToggle = CreateFrame('Frame')
--partyToggle:RegisterEvent('PLAYER_LOGIN')
--partyToggle:RegisterEvent('RAID_ROSTER_UPDATE')
--partyToggle:RegisterEvent('PARTY_LEADER_CHANGED')
--partyToggle:RegisterEvent('PARTY_MEMBER_CHANGED')
--partyToggle:SetScript('OnEvent', function(self)
--	if(InCombatLockdown()) then
--		self:RegisterEvent('PLAYER_REGEN_ENABLED')
--	else
--		self:UnregisterEvent('PLAYER_REGEN_DISABLED')
--		if(HIDE_PARTY_INTERFACE == "1" and GetNumRaidMembers() > 0) then
--			party:Hide()
--		else
--			party:Show()
--		end
--	end
--end)