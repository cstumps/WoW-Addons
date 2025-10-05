local function kill() end

-- --------------------------------
-- Chat frame changes
-- --------------------------------

-- Hide menu button
ChatFrameMenuButton:Hide()
ChatFrameMenuButton.Show = kill

-- Hide the social button
--ChatMenu:Hide()
--ChatMenu.Show = kill

-- Hide up/down buttons on every chat window
for i = 1, 10 do
	local bf = _G["ChatFrame"..i.."ButtonFrame"]

	bf:Hide()
	bf.Show = kill

	-- Let the box be positioned anywhere
	_G["ChatFrame"..i]:SetClampedToScreen(false)
end

-- Style the editbox
-- Hide the boder and background
for i = 1, 10 do
	local x=({_G["ChatFrame"..i.."EditBox"]:GetRegions()})

	for j = 3, 10 do
		x[j]:Hide()
	end
end

-- Disable fading by setting the max alpha possible to 0
DEFAULT_CHATFRAME_ALPHA = 0

-- Tabs fads to invisibility and adjust fade time
CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0;
CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA = 0;
CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0;
CHAT_TAB_HIDE_DELAY = 0;
CHAT_FRAME_FADE_OUT_TIME = 0.5;

-- Position the box
ChatFrame1EditBox:ClearAllPoints()
ChatFrame1EditBox:SetAltArrowKeyMode(false)
ChatFrame1EditBox:SetPoint("TOPLEFT",  ChatFrame1, "BOTTOMLEFT", -10, 0)
ChatFrame1EditBox:SetPoint("TOPRIGHT", ChatFrame1, "BOTTOMRIGHT", -10, 0)

-- Make a semi transparent backdrop
local bg = ChatFrame1EditBox:CreateTexture(nil, "BACKGROUND")
bg:SetPoint("BOTTOMRIGHT", -5, 6)
bg:SetPoint("TOPLEFT", 5, -6)
bg:SetTexture(0, 0, 0, .3)

-- Set the fonts
local evtFrame2 = CreateFrame('Frame')
evtFrame2:RegisterEvent('PLAYER_ENTERING_WORLD')
evtFrame2:SetScript('OnEvent', function(self)
	for i = 1, 10 do
        _G["ChatFrame"..i]:SetFont("Fonts\\FRIZQT__.TTF", 12, "")
	end
end)

ChatFrame1EditBox:SetFont("Fonts\\FRIZQT__.TTF", 14, "")

-- Sticky channels
ChatTypeInfo["YELL"].sticky = 1
ChatTypeInfo["OFFICER"].sticky = 1
ChatTypeInfo["WHISPER"].sticky = 1
ChatTypeInfo["CHANNEL"].sticky = 1
ChatTypeInfo["RAID_WARNING"].sticky = 1

-- Hide channel frames at top
for i = 1, 10 do
    local x=({_G["ChatFrame"..i.."Tab"]:GetRegions()})

    for j = 1, 10 do
    	x[j]:SetAlpha(0)
    end
end

CHAT_GUILD_GET = "|Hchannel:Guild|h[G]|h %s "
CHAT_RAID_GET = "|Hchannel:Raid|h[R]|h %s "
CHAT_PARTY_GET = "|Hchannel:Party|h[P]|h %s "
CHAT_RAID_WARNING_GET = "[RW] %s "
CHAT_RAID_LEADER_GET = "|Hchannel:raid|h[RL]|h %s "
CHAT_OFFICER_GET = "|Hchannel:o|h[O]|h %s "
CHAT_BATTLEGROUND_GET = "|Hchannel:Battleground|h[B]|h %s "
CHAT_BATTLEGROUND_LEADER_GET = "|Hchannel:Battleground|h[BL]|h %s "
CHAT_WHISPER_INFORM_GET = "[W:To] %s "
CHAT_WHISPER_GET = "[W:From] %s "
CHAT_SAY_GET = "%s "
CHAT_YELL_GET = "%s "

CHAT_FLAG_AFK = "[AFK] "
CHAT_FLAG_DND = "[DND] "
CHAT_FLAG_GM = "[GM] "