local bar_texture = "Interface\\AddOns\\oUF_Mage\\textures\\statusbar"
local font = "Interface\\AddOns\\oUF_Mage\\fonts\\font.ttf"
local upperfont = "Interface\\AddOns\\oUF_Mage\\fonts\\upperfont.ttf"
local fontsize = 10

-- Castbar positions
local player_castbar_x = 0
local player_castbar_y = -300
local target_castbar_x = 0
local target_castbar_y = -275

-- ------------------------------------------------------------------------
-- Right click menu
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
-- Reformat everything above 9999, i.e. 10000 -> 10k
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
-- Level update
-- ------------------------------------------------------------------------
oUF.Tags.Methods['Mage:level'] = function(unit)
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
-- Power update
-- ------------------------------------------------------------------------
oUF.Tags.Methods['Mage:power'] = function(unit)
	local cur = UnitPower(unit)
	local max = UnitPowerMax(unit)
	local d = floor( cur / max * 100 )

	if ( unit == "player" ) then
		return numberize(cur).."|r."..d.."%"
	elseif ( unit == "target" ) then
		return d.."%"
	end
end

oUF.Tags.Events['Mage:power'] = oUF.Tags.Events.missingpp

local updatePower = function(power, unit, cur, min, max)
	if(UnitIsDead(unit) or UnitIsGhost(unit)) then
		power:SetValue(0)
	elseif(cur==0 or cur==max) then
		power.value:SetText()
	elseif(not UnitIsConnected(unit)) then
		power.value:SetText()
	end
end

-- ------------------------------------------------------------------------
-- Health update
-- ------------------------------------------------------------------------
oUF.Tags.Methods['Mage:health'] = function(unit)
	local cur = UnitHealth(unit)
	local max = UnitHealthMax(unit)
	local d = floor( cur / max * 100 )

	if ( unit == "player" ) then
		return numberize( cur ).."|r."..d.."%"
	elseif ( unit == "target" ) then
		return d.."%"
	end
end

oUF.Tags.Events['Mage:health'] = oUF.Tags.Events.missinghp

local updateHealth = function(health, unit, cur, max)
	if(UnitIsDead(unit) or UnitIsGhost(unit)) then
		health:SetValue(0)
		health.value:SetText("dead")
	elseif(not UnitIsConnected(unit)) then
		health.value:SetText("offline")
	elseif(cur == max) then
		health.value:SetText()
    end
end

-- ------------------------------------------------------------------------
-- Reskin buffs and debuffs
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
-- Layout starts here
-- ------------------------------------------------------------------------
local layout = function(self, unit)
	self.menu = menu -- Enable the menus
	
	self:RegisterForClicks"anyup"
	self:SetAttribute("*type2", "menu")
	
	-- Background
	self:SetBackdrop{
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16,
		insets = {left = -2, right = -2, top = -2, bottom = -2},
	}
	
	self:SetBackdropColor(0,0,0,1)
		
	-- ------------------------------------------------------------------------
	-- Global healthbar settings
	-- ------------------------------------------------------------------------
	self.Health = CreateFrame("StatusBar")
	self.Health:SetHeight(19) -- Custom height
	self.Health:SetStatusBarTexture(bar_texture)
   	self.Health:SetParent(self)
	self.Health:SetPoint("TOP")
	self.Health:SetPoint("LEFT")
	self.Health:SetPoint("RIGHT")
	
	self.Health.bg = self.Health:CreateTexture(nil, "BORDER")
	self.Health.bg:SetAllPoints(self.Health)
	self.Health.bg:SetTexture(bar_texture)
	self.Health.bg:SetAlpha(0.30)

	self.Health.value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.value:SetFont(font, 10, nil)
	self.Health.value:SetJustifyH("RIGHT")

	self.Health.colorClass = true
	self.Health.colorReaction = true
	self.Health.colorDisconnected = true
	self.Health.colorTapping = true
	self.Health.PostUpdate = updateHealth -- Set proper colors

	self:Tag(self.Health.value, '[Mage:health]')
	
	-- ------------------------------------------------------------------------
	-- Global powerbar settings
	-- ------------------------------------------------------------------------
	self.Power = CreateFrame("StatusBar")
	self.Power:SetHeight(3)
	self.Power:SetStatusBarTexture(bar_texture)
	self.Power:SetParent(self)
	self.Power:SetPoint("LEFT")
	self.Power:SetPoint("RIGHT")
	self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -1.45) -- Little offset to make it pretty

	self.Power.bg = self.Power:CreateTexture(nil, "BORDER")
	self.Power.bg:SetAllPoints(self.Power)
	self.Power.bg:SetTexture(bartex)
	self.Power.bg:SetAlpha(0.30)

	self.Power.value = self.Power:CreateFontString(nil, "OVERLAY")
    self.Power.value:SetJustifyH("RIGHT")
	self.Power.value:SetFont(font, 8, nil)

	self.Power.colorTapping = true
	self.Power.colorDisconnected = true
	self.Power.colorClass = true
	self.Power.colorPower = true
	self.Power.colorHappiness = false
	self.Power.PostUpdate = updatePower -- let the colors be

	self:Tag(self.Power.value, '[Mage:power]')
	
	-- ------------------------------------------------------------------------
	-- Names
	-- ------------------------------------------------------------------------
	self.Name = self.Health:CreateFontString(nil, "OVERLAY")
    --self.Name:SetPoint("LEFT", self, 0, 17)
    self.Name:SetPoint("LEFT", self.Health, 18, 14)
    self.Name:SetJustifyH("LEFT")
	self.Name:SetFont(upperfont, fontsize, nil)

    self:Tag(self.Name, '[name]')

	-- ------------------------------------------------------------------------
	-- Level
	-- ------------------------------------------------------------------------
	self.Level = self.Health:CreateFontString(nil, "OVERLAY")
	self.Level:SetPoint("LEFT", self.Health, -2, 14)
	self.Level:SetJustifyH("LEFT")
	self.Level:SetFont(font, fontsize, nil)
    self.Level:SetTextColor(1,1,1)

	self:Tag(self.Level, '[Mage:level]')
	
	-- ------------------------------------------------------------------------
	-- Player settings
	-- ------------------------------------------------------------------------
	if (unit == 'player') then
		self:SetWidth(145)
      	self:SetHeight(16)
	
		-- Player healthbar settings
		self.Health:SetHeight(12.5)
		self.Health.value:SetPoint("RIGHT", -150, 3)

		-- Player power
		self.Power:SetHeight(2)
        self.Power.value:Show()
		self.Power.value:SetPoint("RIGHT", -150, 1)
		
		-- Player name
		self.Name:Hide()
		
		-- Player level
		self.Level:Hide()
		
		-- Leader icon
		self.LeaderIndicator = self.Health:CreateTexture(nil, "OVERLAY")
		self.LeaderIndicator:SetHeight(12)
		self.LeaderIndicator:SetWidth(12)
		self.LeaderIndicator:SetPoint("BOTTOMRIGHT", self, -2, 4)
		self.LeaderIndicator:SetTexture"Interface\\GroupFrame\\UI-Group-LeaderIcon"

		-- Raid target icons
		self.RaidTargetIndicator = self.Health:CreateTexture(nil, "OVERLAY")
		self.RaidTargetIndicator:SetHeight(16)
		self.RaidTargetIndicator:SetWidth(16)
		self.RaidTargetIndicator:SetPoint("TOP", self, 0, 9)
		self.RaidTargetIndicator:SetTexture"Interface\\TargetingFrame\\UI-RaidTargetingIcons"
		
		-- Class icons
		local ClassIcons = {}
		
		for index = 1, 5 do
			local Icon = self:CreateTexture(nil, 'BACKGROUND')
   
			-- Position and size.
			Icon:SetSize(16, 16)
			Icon:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', index * Icon:GetWidth(), 0)
   
			ClassIcons[index] = Icon
		end
   
		-- Register with oUF
		self.ClassIcons = ClassIcons
	end	
	
	-- ------------------------------------------------------------------------
	-- Target settings
	-- ------------------------------------------------------------------------
	if (unit == 'target') then
		self:SetWidth(145)
		self:SetHeight(16)
		
		-- Target name
		--self.Name:SetPoint("LEFT", self.Level, "RIGHT", 2, 0)
		self.Name:SetHeight(20)
		self.Name:SetWidth(150)
		
		-- Target healthbar settings		
		self.Health:SetHeight(12.5)
		self.Health.value:SetPoint("LEFT", 148, 3)
		self.Health.colorClass = false
		
		-- Target powerbar settings
		self.Power:SetHeight(2)
		self.Power.value:SetPoint("LEFT", 148, 1)
		
		-- Target's buffs
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

		-- Target's debuffs
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
	
	-- ------------------------------------------------------------------------
	-- Target of target settings
	-- ------------------------------------------------------------------------
	if unit=="targettarget" then
		self:SetWidth(60)
		self:SetHeight(16)
		self.Health:SetHeight(16)
		self.Health.value:Hide()
		self.Power:Hide()
		self.Power.value:Hide()
		self.Level:Hide()
	end
	
	if (unit == 'player' or unit == 'target') then
		-- ------------------------------------------------------------------------
		-- Castbars
		-- ------------------------------------------------------------------------
		local castbar = CreateFrame("StatusBar", nil, self)
	
		castbar:SetStatusBarTexture(bar_texture)
		castbar:SetBackdropColor(0, 0, 0, 0.5)

		-- Background
		castbar_bg = castbar:CreateTexture(nil, 'BORDER')
		castbar_bg:SetAllPoints(castbar)
		castbar_bg:SetTexture(0, 0, 0, 0.6)

		-- Time
		castbar_time = castbar:CreateFontString(nil, "OVERLAY")
		castbar_time:SetPoint("LEFT", castbar, "RIGHT", 4, 0)
		castbar_time:SetFont(upperfont, 10, nil)
		castbar_time:SetTextColor(1, 1, 1)
		castbar_time:SetJustifyH("LEFT")
		
		-- Spell name
		castbar_text = castbar:CreateFontString(nil, "OVERLAY")
		castbar_text:SetPoint('TOPLEFT', -1, 12)
		castbar_text:SetFont(upperfont, 10, nil)
		castbar_text:SetShadowOffset(1, -1)
		castbar_text:SetTextColor(1, 1, 1)
		castbar_text:SetJustifyH('RIGHT')
		
		castbar:SetBackdrop({
			bg_file = "Interface\ChatFrame\ChatFrameBackground",
			insets = {top = -3, left = -3, bottom = -3, right = -3}
		})
	
		if(unit == "player") then
			castbar:SetStatusBarColor(1, 0.50, 0)
			castbar:SetHeight(8)
			castbar:SetWidth(250)

			castbar:SetPoint('CENTER', UIParent, 'CENTER', player_castbar_x, player_castbar_y)
		else
			castbar:SetStatusBarColor(0.80, 0.01, 0)
			castbar:SetHeight(8)
			castbar:SetWidth(250)
		
			castbar:SetPoint('CENTER', UIParent, 'CENTER', target_castbar_x, target_castbar_y)
		end
		
		self.Castbar = castbar
		self.Castbar.bg = castbar_bg
		self.Castbar.Time = castbar_time
		self.Castbar.Text = castbar_text
		-- ------------------------------------------------------------------------
	end
	
	return self
end

oUF:RegisterStyle("Mage", layout)
oUF:SetActiveStyle("Mage")

local player = oUF:Spawn("player", "oUF_Player")
player:SetPoint("BOTTOM", -125,140)

local target = oUF:Spawn("target", "oUF_Target")
target:SetPoint("BOTTOM", 125, 140)

local tot = oUF:Spawn("targettarget", "oUF_TargetTarget")
tot:SetPoint("BOTTOM", 257, 140)