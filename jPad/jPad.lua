local jpad = jPadFrame
local ebox = jPadEditBox
local menu = jContextMenu

-- Saved variables
jPadSettings = {}
jPadText = ""

local undoBuffer, settings

-- Key binding definitions
BINDING_HEADER_JPAD = "jPad"
BINDING_NAME_JPAD_SAVE = "Save Notepad"
BINDING_NAME_JPAD_UNDO = "Undo Last Change"

-- map widget to toggle on / off - on hide, save contents
-- add right click to lock / unlock movement and resize

function jpad:PLAYER_LOGIN()
	local curTxt = jPadText

	settings = jPadSettings

	-- Set the edit box font to something monospaced
	ebox:SetFont( "Interface\\AddOns\\jPad\\fonts\\Hermit-medium.otf", 12 )

	jpad:SetMinResize( 300, 200 )
	jpad:OnSizeChanged( jpad:GetWidth() )

	self:RegisterEvent( "PLAYER_LOGOUT" )

	ebox:SetText( curTxt )
	undoBuffer = curTxt

	-- Slash handler
	SLASH_JPAD1 = "/jpad"
	SlashCmdList[ "JPAD" ] = jPadSlashHandler

	-- Starting window state
	if settings.Show then
		jpad:Show()
	else
		jpad:Hide()
	end
end

function jpad:PLAYER_LOGOUT()
	jpad:SaveText()
end

function jpad:SaveText()
	local curTxt = ebox:GetText()

	jPadText = curTxt
	undoBuffer = curTxt
end

-- Re-adjust the editbox size to the scroll frame
function jpad:OnSizeChanged( width )
	ebox:SetWidth( width - 38 )
end

function jpad:UndoEdit()
	local pos = ebox:GetCursorPosition()

	ebox:SetText( undoBuffer )
	ebox:SetCursorPosition( pos )
end

function jpad:ToggleShow()
	if settings.Show then
		jpad:SaveText()
		jpad:Hide()
		settings.Show = false
	else
		jpad:Show()
		settings.Show = true
	end
end

function jPadSlashHandler( msg )
	if msg == "unlock" then
		settings.Lock = false
		print( "|cffffFF00 jPad window is unlocked |r" )
	elseif msg == "lock" then
		settings.Lock = true
		print( "|cffffFF00 jPad window is locked |r" )
	else
		print( "|cffffFF00 jPad Help: |r" )
		print( "|cffffFF00   lock - Lock window and prevent movement and sizing |r" )
		print( "|cffffFF00   unlock - Unlock window and allow movement and sizing |r" )
	end
end