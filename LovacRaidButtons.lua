-- =========================
-- Lovac Raid Buttons
-- =========================

-- Default buttons (used only on first install)
local DEFAULT_BUTTONS = {
    { label = "Welcome",  message = "Welcome to this Manaforge Omega Run. Everyone will get summoned inside the raid shortly. Please ONLY TRADE me inside the raid. If you have already paid, just wait for a summon." },
    { label = "Trade me",  message = "If you haven't paid, please trade {rt8} me {rt8}." },
    { label = "All paid",  message = "Everyone has paid! Thank you for joining, enjoy your raid. Good luck!" },
    { label = "Goodbye", message = "Thank you for joining this run! To get the best prices, find out about our deals or to leave a review, you can join our Discord here - discord.gg/dawneu" },
}

-- =========================
-- SavedVariables Initialization
-- =========================
if not LovacRaidButtonsDB then LovacRaidButtonsDB = {} end
if not LovacRaidButtonsDB.buttons then LovacRaidButtonsDB.buttons = {} end
if not LovacRaidButtonsDB.order then LovacRaidButtonsDB.order = {} end
if not LovacRaidButtonsDB._lastID then LovacRaidButtonsDB._lastID = 0 end
if LovacRaidButtonsDB.frameVisible == nil then LovacRaidButtonsDB.frameVisible = true end
if LovacRaidButtonsDB.interpolateMe == nil then LovacRaidButtonsDB.interpolateMe = true end

-- =========================
-- ID Helper
-- =========================
local function GenerateID()
    LovacRaidButtonsDB._lastID = LovacRaidButtonsDB._lastID + 1
    return "btn"..LovacRaidButtonsDB._lastID
end
_G.LovacRaidButtons_GenerateID = GenerateID

-- =========================
-- Message Interpolation
-- =========================
local function InterpolateMessage(message)
    local playerName = UnitName("player")
    local realmName = GetRealmName()
    local playerNameRealm = playerName .. "-" .. realmName
    
    -- Replace "me" (case-insensitive) only when it's a standalone word
    -- Handle start of string
    message = message:gsub("^[Mm][Ee]%s", playerNameRealm .. " ")
    -- Handle middle of string
    message = message:gsub("%s[Mm][Ee]%s", " " .. playerNameRealm .. " ")
    -- Handle before punctuation
    message = message:gsub("%s[Mm][Ee]([%p])", " " .. playerNameRealm .. "%1")
    -- Handle end of string
    message = message:gsub("%s[Mm][Ee]$", " " .. playerNameRealm)
    
    return message
end
_G.LovacRaidButtons_InterpolateMessage = InterpolateMessage

-- =========================
-- Text Truncation
-- =========================
local function TruncateText(text, limit)
    if #text > limit then
        return text:sub(1, limit) .. "..."
    end
    return text
end
_G.LovacRaidButtons_TruncateText = TruncateText

-- =========================
-- Main Frame (Raid Buttons)
-- =========================
local frame = CreateFrame("Frame", "LovacRaidButtonsFrame", UIParent, "BackdropTemplate")
frame:SetWidth(200)

local BUTTON_HEIGHT = 26
local BUTTON_SPACING = 6
local TOP_PADDING = 16
local BOTTOM_PADDING = 10

-- =========================
-- Ready Check Button
-- =========================
local readyBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
readyBtn:SetSize(180, BUTTON_HEIGHT)
readyBtn:SetPoint("TOP", frame, "TOP", 0, -TOP_PADDING)
readyBtn:SetText("READY CHECK")
readyBtn:SetNormalFontObject("GameFontNormal")
readyBtn:SetHighlightFontObject("GameFontHighlight")
readyBtn:SetScript("OnClick", function()
    DoReadyCheck()
end)

-- =========================
-- Pull / Cancel Buttons
-- =========================
local pullBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
pullBtn:SetSize(180, BUTTON_HEIGHT)
pullBtn:SetPoint("TOP", readyBtn, "BOTTOM", 0, -BUTTON_SPACING)
pullBtn:SetText("PULL")
pullBtn:SetNormalFontObject("GameFontNormal")
pullBtn:SetHighlightFontObject("GameFontHighlight")
pullBtn:SetScript("OnClick", function()
    local seconds = LovacRaidButtonsDB.pullTimer or 10
    C_PartyInfo.DoCountdown(seconds)
end)

local cancelBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
cancelBtn:SetSize(180, BUTTON_HEIGHT)
cancelBtn:SetPoint("TOP", pullBtn, "BOTTOM", 0, -BUTTON_SPACING)
cancelBtn:SetText("CANCEL PULL")
cancelBtn:SetNormalFontObject("GameFontNormal")
cancelBtn:SetHighlightFontObject("GameFontHighlight")
cancelBtn:SetScript("OnClick", function()
    C_PartyInfo.DoCountdown(0)
end)

-- =========================
-- Restore position
-- =========================
if LovacRaidButtonsDB.position then
    local p = LovacRaidButtonsDB.position
    frame:SetPoint(p.point, UIParent, p.relPoint, p.x, p.y)
else
    frame:SetPoint("CENTER")
end

frame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
frame:SetBackdropColor(0,0,0,0.85)

frame:EnableMouse(true)
frame:SetMovable(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local p, _, rp, x, y = self:GetPoint()
    LovacRaidButtonsDB.position = { point=p, relPoint=rp, x=x, y=y }
end)


-- =========================
-- Visibility
-- =========================
local function UpdateVisibility(target, force)
    if target == "options" then
        if _G.LovacRaidButtons_OptionsFrame:IsShown() then
            _G.LovacRaidButtons_OptionsFrame:Hide()
        else
            _G.LovacRaidButtons_OptionsFrame:Show()
        end
        return
    end

    if force then
        if LovacRaidButtonsDB.frameVisible then
            frame:Show()
        else
            frame:Hide()
        end
        return
    end

    -- Only show if frameVisible is true AND in raid instance
    local inInstance, instanceType = IsInInstance()
    if LovacRaidButtonsDB.frameVisible
        and IsInRaid()
        and inInstance
        and instanceType == "raid" then
        frame:Show()
    else
        frame:Hide()
    end
end
_G.LovacRaidButtons_UpdateVisibility = UpdateVisibility

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:SetScript("OnEvent", UpdateVisibility)

-- =========================
-- Slash Commands
-- =========================
SLASH_LOVACRAIDBUTTONS1 = "/lrb"
SlashCmdList["LOVACRAIDBUTTONS"] = function(msg)
    msg = msg:lower()

    if msg == "options" then
        UpdateVisibility("options")
        return
    end

    if msg == "on" or msg == "show" then
        LovacRaidButtonsDB.frameVisible = true
    elseif msg == "off" or msg == "hide" then
        LovacRaidButtonsDB.frameVisible = false
        frame:Hide()
        return
    else
        LovacRaidButtonsDB.frameVisible = not LovacRaidButtonsDB.frameVisible
    end

    UpdateVisibility(nil, true)
end

-- =========================
-- Dynamic Buttons
-- =========================
local buttons = {}
local function CreateRaidButton(y, label, message)
    local btn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    btn:SetSize(180, BUTTON_HEIGHT)
    btn:SetPoint("TOP", 0, y)
    btn:SetText(TruncateText(label, 10))
    -- Store message on button to avoid closure capture
    btn.message = message
    btn:SetScript("OnClick", function(self)
        local finalMessage = self.message
        if LovacRaidButtonsDB.interpolateMe then
            finalMessage = InterpolateMessage(finalMessage)
        end
        SendChatMessage(finalMessage, "RAID_WARNING")
    end)
    return btn
end


-- =========================
-- Rebuild Buttons
-- =========================
local function RebuildButtons()
    -- destroy old dynamic buttons
    for id, b in pairs(buttons) do 
        if b then
            b:SetScript("OnClick", nil)
            b:SetScript("OnEnter", nil)
            b:SetScript("OnLeave", nil)
            b.message = nil  -- null out custom property
            b:Hide()
            b:ClearAllPoints()
            pcall(function() b:SetParent(nil) end)
            buttons[id] = nil
        end
    end
    wipe(buttons)

    -- Positioning starts below fixed buttons (PULL / CANCEL)
    local y = -TOP_PADDING - (BUTTON_HEIGHT + BUTTON_SPACING) * 3
    local count = 3

    -- Saved buttons (defaults + customs)
    for _, id in ipairs(LovacRaidButtonsDB.order) do
        local data = LovacRaidButtonsDB.buttons[id]
        if data then
            local btn = CreateRaidButton(y, data.label, data.message)
            buttons[id] = btn
            y = y - (BUTTON_HEIGHT + BUTTON_SPACING)
            count = count + 1
        end
    end

    -- adjust frame height
    frame:SetHeight(TOP_PADDING + (count * (BUTTON_HEIGHT + BUTTON_SPACING)) + BOTTOM_PADDING)
end
_G.LovacRaidButtons_RebuildButtons = RebuildButtons

-- =========================
-- PLAYER_LOGIN Init
-- =========================
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", function()
    -- first-time defaults
    if not next(LovacRaidButtonsDB.buttons) then
        for _, def in ipairs(DEFAULT_BUTTONS) do
            local id = GenerateID()
            LovacRaidButtonsDB.buttons[id] = { id=id, label=def.label, message=def.message }
            table.insert(LovacRaidButtonsDB.order,id)
        end
    end

    RebuildButtons()
    _G.LovacRaidButtons_RefreshOptions()
end)