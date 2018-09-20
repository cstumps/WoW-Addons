-- --------------------------------
-- Buff appearance and location changes
-- --------------------------------
function ApplyStyle(buttonName, index)
	local icon = _G[buttonName..index.."Icon"]

	if (icon and not _G[buttonName..index.."Frame"]) then
		local buff     = _G[buttonName..index]
		local duration = _G[buttonName..index.."Duration"]
		local count    = _G[buttonName..index.."Count"]

		-- Remove silvery border
		icon:SetTexCoord(0.07,0.93,0.07,0.93)

		-- Apply the new skin
		local overlay = CreateFrame("Frame", buttonName..index.."Skin", buff)
		overlay:SetAllPoints(buff)
		overlay:SetParent(buff)

		local texture = overlay:CreateTexture(nil, "BORDER")
		texture:SetParent(buff)
		texture:SetTexture("Interface\\AddOns\\jBuffs\\media\\button")
		texture:SetPoint("TOPRIGHT", overlay, 4, 4)
		texture:SetPoint("BOTTOMLEFT", overlay, -4, -4)
		texture:SetVertexColor(0, 0, 0)

		-- Fix up text to compensate for scaling
		if (duration) then
		    duration:ClearAllPoints()
		   	duration:SetPoint("CENTER", buff, "BOTTOM", 0, -10)
		   	duration:SetFontObject("GameFontNormal")
    	end

    	-- Make the count number more visible
    	if (count) then
			count:ClearAllPoints()
			count:SetPoint("BOTTOMLEFT", buff, 2, 0)
			count:SetFont("Fonts\\FRIZQT__.TTF", 22, "OUTLINE")
			count:SetTextColor(1, 0, 0)
    	end

    	_G[buttonName..index.."Frame"] = overlay
    end
end

BuffFrame:SetScale(0.75)
TemporaryEnchantFrame:SetScale(0.75)

TemporaryEnchantFrame:ClearAllPoints()
TemporaryEnchantFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 15, -125)
TempEnchant1:ClearAllPoints()
TempEnchant2:ClearAllPoints()
TempEnchant1:SetPoint("TOPLEFT", 0, 0)
TempEnchant2:SetPoint("LEFT", TempEnchant1, "RIGHT", 8, 0)

ApplyStyle("TempEnchant", 1)
ApplyStyle("TempEnchant", 2)
_G["TempEnchant1".."Border"]:Hide()
_G["TempEnchant2".."Border"]:Hide()

function UpdateBuffAnchors()
	local buttonName = "BuffButton"
	local prevBuff

	for index=1,BUFF_ACTUAL_DISPLAY do
		local buff = _G[buttonName..index]
		buff:ClearAllPoints()

		ApplyStyle( buttonName, index, false )

		if (index == 16) then
			-- New row
			buff:SetPoint("TOP", prevBuff, "BOTTOM", 0, -25)
			prevBuff = buff
		elseif index == 1 then
			buff:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 15, -15)
			prevBuff = buff
		else
			buff:SetPoint("LEFT", _G[buttonName..(index-1)], "RIGHT", 8, 0)
		end
	end
end

function UpdateDebuffAnchors(buttonName, index)
	local debuff = _G[buttonName..index];
	local border = _G[buttonName..index.."Border"];

	ApplyStyle( buttonName, index, true )
	debuff:ClearAllPoints()
	border:Hide()

	if index == 1 then
		debuff:SetPoint("TOPLEFT",UIParent, "TOPLEFT", 15, -180)
	else
		debuff:SetPoint("LEFT", _G[buttonName..(index-1)], "RIGHT", 8, 0)
	end
end

hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", UpdateBuffAnchors)
hooksecurefunc("DebuffButton_UpdateAnchors", UpdateDebuffAnchors)