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

-- =========================
-- ID Helper
-- =========================
local function GenerateID()
    LovacRaidButtonsDB._lastID = LovacRaidButtonsDB._lastID + 1
    return "btn"..LovacRaidButtonsDB._lastID
end

-- =========================
-- Text Truncation
-- =========================
local function TruncateText(text, limit)
    if #text > limit then
        return text:sub(1, limit) .. "..."
    end
    return text
end

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
-- Options Window
-- =========================
local options = CreateFrame("Frame", "LovacRaidButtonsOptions", UIParent, "BackdropTemplate")
options:SetSize(320, 400)
options:SetPoint("CENTER")
options:Hide()

options:SetBackdrop({
    bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
    edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
    edgeSize = 32,
    insets = { left = 12, right = 12, top = 12, bottom = 12 }
})

options:SetMovable(true)
options:EnableMouse(true)
options:RegisterForDrag("LeftButton")
options:SetScript("OnDragStart", options.StartMoving)
options:SetScript("OnDragStop", options.StopMovingOrSizing)

local title = options:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
title:SetPoint("TOP", 0, -16)
title:SetText("Lovac Raid Buttons")

-- Close "X" button
local closeBtn = CreateFrame("Button", nil, options, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", -6, -6)
closeBtn:SetScript("OnClick", function() options:Hide() end)

-- =========================
-- Scroll Frame
-- =========================
local scrollFrame = CreateFrame("ScrollFrame", "LovacRaidButtonsScrollFrame", options, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 10, -70)
scrollFrame:SetPoint("BOTTOMRIGHT", -30, 60)

local scrollChild = CreateFrame("Frame", nil, scrollFrame)
scrollChild:SetSize(1,1)
scrollFrame:SetScrollChild(scrollChild)



-- =========================
-- Visibility
-- =========================
local function UpdateVisibility(target, force)
    if target == "options" then
        if options:IsShown() then
            options:Hide()
        else
            options:Show()
        end
        return
    end

    if force then
        frame:Show()
        return
    end

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
    btn:SetScript("OnClick", function()
        SendChatMessage(message, "RAID_WARNING")
    end)
    return btn
end


-- =========================
-- Rebuild Buttons
-- =========================
local function RebuildButtons()
    -- hide old dynamic buttons
    for _, b in pairs(buttons) do b:Hide() end
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


-- =========================
-- Custom Edit Button Popup (replaces StaticPopup)
-- =========================
local function ShowEditPopup(data, RebuildButtonsFunc, RefreshOptionsFunc)
    local popup = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    popup:SetSize(280,200)
    popup:SetPoint("CENTER")
    popup:SetBackdrop({
        bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
        edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
        edgeSize = 32,
        insets = { left=11,right=12,top=12,bottom=11 }
    })
    popup:SetMovable(true)
    popup:EnableMouse(true)
    popup:RegisterForDrag("LeftButton")
    popup:SetScript("OnDragStart", popup.StartMoving)
    popup:SetScript("OnDragStop", popup.StopMovingOrSizing)
    popup:SetResizable(true)
    popup:SetScript("OnSizeChanged", function(self, width, height)
        if width < 280 then self:SetWidth(280) end
        if height < 200 then self:SetHeight(200) end
    end)

    local resizeHandle = CreateFrame("Button", nil, popup)
    resizeHandle:SetSize(16, 16)
    resizeHandle:SetPoint("BOTTOMRIGHT", -10, 10)
    resizeHandle:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizeHandle:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeHandle:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")

    resizeHandle:SetScript("OnMouseDown", function(self)
        popup:StartSizing("BOTTOMRIGHT")
    end)
    resizeHandle:SetScript("OnMouseUp", function(self)
        popup:StopMovingOrSizing()
    end)

    local title = popup:CreateFontString(nil,"OVERLAY","GameFontHighlightLarge")
    title:SetPoint("TOP",0,-20)
    title:SetText("Edit Raid Message")

    local closeX = CreateFrame("Button", nil, popup, "UIPanelCloseButton")
    closeX:SetPoint("TOPRIGHT", -6, -6)
    closeX:SetScript("OnClick", function() popup:Hide() end)

    -- Message
    local msgBox = CreateFrame("EditBox", nil, popup, "BackdropTemplate")
    msgBox:SetSize(220,100)
    msgBox:SetPoint("TOP", title, "BOTTOM", 0, -25)
    msgBox:SetMultiLine(true)
    msgBox:SetAutoFocus(true)
    msgBox:SetFontObject("ChatFontNormal")
    msgBox:SetTextInsets(8, 8, 8, 8)
    msgBox:SetText(data.message)
    msgBox:SetMaxLetters(200)

    local msgText = popup:CreateFontString(nil,"OVERLAY","GameFontNormal")
    msgText:SetPoint("BOTTOMLEFT", msgBox, "TOPLEFT", 0, 2)
    msgText:SetText("Message:")

    -- Save / Cancel
    local saveBtn = CreateFrame("Button", nil, popup, "UIPanelButtonTemplate")
    saveBtn:SetSize(80,24)
    saveBtn:SetPoint("BOTTOMLEFT", 20, 10)
    saveBtn:SetText("Save")
    saveBtn:SetScript("OnClick", function()
        data.message = msgBox:GetText()
        if RebuildButtonsFunc then RebuildButtonsFunc() end
        if RefreshOptionsFunc then RefreshOptionsFunc() end
        popup:Hide()
    end)

    local cancelBtn = CreateFrame("Button", nil, popup, "UIPanelButtonTemplate")
    cancelBtn:SetSize(80,24)
    cancelBtn:SetPoint("BOTTOMRIGHT", -20, 10)
    cancelBtn:SetText("Cancel")
    cancelBtn:SetScript("OnClick", function() popup:Hide() end)
end

-- =========================
-- Custom Rename Button Popup
-- =========================
local function ShowRenamePopup(data, RebuildButtonsFunc, RefreshOptionsFunc)
    local popup = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    popup:SetSize(280,180)
    popup:SetPoint("CENTER")
    popup:SetBackdrop({
        bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
        edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
        edgeSize = 32,
        insets = { left=11,right=12,top=12,bottom=11 }
    })
    popup:SetMovable(true)
    popup:EnableMouse(true)
    popup:RegisterForDrag("LeftButton")
    popup:SetScript("OnDragStart", popup.StartMoving)
    popup:SetScript("OnDragStop", popup.StopMovingOrSizing)

    local title = popup:CreateFontString(nil,"OVERLAY","GameFontHighlightLarge")
    title:SetPoint("TOP",0,-20)
    title:SetText("Rename Raid Button")

    local closeX = CreateFrame("Button", nil, popup, "UIPanelCloseButton")
    closeX:SetPoint("TOPRIGHT", -6, -6)
    closeX:SetScript("OnClick", function() popup:Hide() end)

    local labelBox = CreateFrame("EditBox", nil, popup, "InputBoxTemplate")
    labelBox:SetSize(220,24)
    labelBox:SetPoint("TOP", title, "BOTTOM", 0, -25)
    labelBox:SetAutoFocus(true)
    labelBox:SetText(data.label)
    labelBox:SetMaxLetters(50)

    local labelText = popup:CreateFontString(nil,"OVERLAY","GameFontNormal")
    labelText:SetPoint("BOTTOMLEFT", labelBox, "TOPLEFT", 0, 2)
    labelText:SetText("New Label:")

    local saveBtn = CreateFrame("Button", nil, popup, "UIPanelButtonTemplate")
    saveBtn:SetSize(80,24)
    saveBtn:SetPoint("BOTTOMLEFT", 20, 10)
    saveBtn:SetText("Save")
    saveBtn:SetScript("OnClick", function()
        data.label = labelBox:GetText()
        if RebuildButtonsFunc then RebuildButtonsFunc() end
        if RefreshOptionsFunc then RefreshOptionsFunc() end
        popup:Hide()
    end)

    local cancelBtn = CreateFrame("Button", nil, popup, "UIPanelButtonTemplate")
    cancelBtn:SetSize(80,24)
    cancelBtn:SetPoint("BOTTOMRIGHT", -20, 10)
    cancelBtn:SetText("Cancel")
    cancelBtn:SetScript("OnClick", function() popup:Hide() end)
end




-- =========================
-- Refresh Options
-- =========================
local function RefreshOptions()
    if options.rows then
        for _, r in pairs(options.rows) do r:Hide() end
    end
    options.rows = {}
    -- =========================
    -- Pull Timer Row
    -- =========================
    local pullRow = CreateFrame("Frame", nil, options)
    pullRow:SetSize(280, 24)
    pullRow:SetPoint("TOPLEFT", 20, -40)  -- top padding

    -- Label
    local pullLabel = pullRow:CreateFontString(nil,"OVERLAY","GameFontNormal")
    pullLabel:SetPoint("LEFT", 4, 0)
    pullLabel:SetText("Pull Timer (seconds):")

    -- EditBox
    local pullBox = CreateFrame("EditBox", nil, pullRow, "InputBoxTemplate")
    pullBox:SetSize(50,20)
    pullBox:SetPoint("LEFT", pullLabel, "RIGHT", 10, 0)
    pullBox:SetAutoFocus(false)
    pullBox:SetText(LovacRaidButtonsDB.pullTimer or "10")
    pullBox:SetMaxLetters(4)
    pullBox:SetNumeric(true)

    -- Save Button
    local pullSave = CreateFrame("Button", nil, pullRow, "UIPanelButtonTemplate")
    pullSave:SetSize(60,20)
    pullSave:SetPoint("LEFT", pullBox, "RIGHT", 10, 0)
    pullSave:SetText("Save")
    pullSave:SetScript("OnClick", function()
        local val = tonumber(pullBox:GetText())
        if not val then val = 10 end
        if val < 1 then val = 1 end
        if val > 3600 then val = 3600 end
        LovacRaidButtonsDB.pullTimer = val
        pullBox:SetText(val)
    end)

    -- Adjust scrollChild starting offset for next buttons
    local y = 0  -- row height + padding

    for _, id in ipairs(LovacRaidButtonsDB.order) do
        local data = LovacRaidButtonsDB.buttons[id]
        if data then
            local row = CreateFrame("Frame", nil, scrollChild)
            row:SetSize(280, 24) -- row height
            row:SetPoint("TOPLEFT", 10, y)

            -- Label (truncated to 10 chars)
            local text = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            text:SetPoint("LEFT", 4, 0)
            text:SetText(TruncateText(data.label, 10))

            -- Delete button (12 px from right)
            local del = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            del:SetSize(40, 20)
            del:SetPoint("RIGHT", -12, 0)
            del:SetText("Del")
            del:SetScript("OnClick", function()
                LovacRaidButtonsDB.buttons[id] = nil
                for i, oid in ipairs(LovacRaidButtonsDB.order) do
                    if oid == id then table.remove(LovacRaidButtonsDB.order,i) break end
                end
                RebuildButtons()
                RefreshOptions()
            end)

            -- Edit button (5 px to the left of Del)
            local edit = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            edit:SetSize(40, 20)
            edit:SetPoint("RIGHT", del, "LEFT", -5, 0)
            edit:SetText("Edit")
            edit:SetScript("OnClick", function()
                ShowEditPopup(data, RebuildButtons, RefreshOptions)
            end)

            -- Rename button (5 px to the left of Edit)
            local rename = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            rename:SetSize(70, 20)
            rename:SetPoint("RIGHT", edit, "LEFT", -5, 0)
            rename:SetText("Rename")
            rename:SetScript("OnClick", function()
                ShowRenamePopup(data, RebuildButtons, RefreshOptions)
            end)

            table.insert(options.rows,row)
            y = y - 28
        end
    end

    -- Adjust scrollChild height
    scrollChild:SetHeight(-y + 5)
end



-- =========================
-- Add Button Popup (with Label + Message)
-- =========================
local add = CreateFrame("Button", nil, options, "UIPanelButtonTemplate")
add:SetSize(150,24)
add:SetPoint("BOTTOM", 0, 20)
add:SetText("Add Button")
add:SetScript("OnClick", function()
    -- Popup frame
    local popup = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    popup:SetSize(260,160)
    popup:SetPoint("CENTER")
    popup:SetBackdrop({
        bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
        edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
        edgeSize = 32,
        insets = { left=11,right=12,top=12,bottom=11 }
    })
    popup:SetMovable(true)
    popup:EnableMouse(true)
    popup:RegisterForDrag("LeftButton")
    popup:SetScript("OnDragStart", popup.StartMoving)
    popup:SetScript("OnDragStop", popup.StopMovingOrSizing)

    local title = popup:CreateFontString(nil,"OVERLAY","GameFontHighlightLarge")
    title:SetPoint("TOP",0,-10)
    title:SetText("New Raid Button")

    -- Close X
    local closeX = CreateFrame("Button", nil, popup, "UIPanelCloseButton")
    closeX:SetPoint("TOPRIGHT", -6, -6)
    closeX:SetScript("OnClick", function() popup:Hide() end)

    -- Label
    local labelBox = CreateFrame("EditBox", nil, popup, "InputBoxTemplate")
    labelBox:SetSize(200,20)
    labelBox:SetPoint("TOP", title, "BOTTOM", 0, -10)
    labelBox:SetAutoFocus(true)
    labelBox:SetText("")
    labelBox:SetMaxLetters(50)

    local labelText = popup:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    labelText:SetPoint("BOTTOMLEFT", labelBox, "TOPLEFT", 0, 0)
    labelText:SetText("Button Label:")

    -- Message
    local msgBox = CreateFrame("EditBox", nil, popup, "InputBoxTemplate")
    msgBox:SetSize(200,20)
    msgBox:SetPoint("TOP", labelBox, "BOTTOM", 0, -20)
    msgBox:SetAutoFocus(false)
    msgBox:SetText("")
    msgBox:SetMaxLetters(200)

    local msgText = popup:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    msgText:SetPoint("BOTTOMLEFT", msgBox, "TOPLEFT", 0, 0)
    msgText:SetText("Message:")

    -- Buttons Add / Cancel
    local addBtn = CreateFrame("Button", nil, popup, "UIPanelButtonTemplate")
    addBtn:SetSize(80,24)
    addBtn:SetPoint("BOTTOMLEFT", 20, 10)
    addBtn:SetText("Add")
    addBtn:SetScript("OnClick", function()
        local label = labelBox:GetText() or "CUSTOM"
        local msg = msgBox:GetText() or ""
        if msg ~= "" then
            local id = GenerateID()
            LovacRaidButtonsDB.buttons[id] = { id = id, label = label, message = msg }
            table.insert(LovacRaidButtonsDB.order, id)
            RebuildButtons()
            RefreshOptions()
            popup:Hide()
        else
            print("Message cannot be empty!")
        end
    end)

    local cancelBtn = CreateFrame("Button", nil, popup, "UIPanelButtonTemplate")
    cancelBtn:SetSize(80,24)
    cancelBtn:SetPoint("BOTTOMRIGHT", -20, 10)
    cancelBtn:SetText("Cancel")
    cancelBtn:SetScript("OnClick", function() popup:Hide() end)
end)

-- =========================
-- Minimap Button
-- =========================
local minimap = CreateFrame("Button", "LovacRaidButtonsMinimap", Minimap)
minimap:SetSize(25,25)
minimap:SetFrameStrata("MEDIUM")
minimap:SetNormalTexture("Interface/AddOns/LovacRaidButtons/media/LovacRaidButtons")
minimap:SetHighlightTexture("Interface/Minimap/UI-Minimap-ZoomButton-Highlight")
minimap:RegisterForClicks("LeftButtonUp","RightButtonUp")
minimap:SetScript("OnClick",function(_,button)
    if button=="LeftButton" then
        LovacRaidButtonsDB.frameVisible = not LovacRaidButtonsDB.frameVisible
        UpdateVisibility()
    elseif button=="RightButton" then
        if options:IsShown() then options:Hide() else RefreshOptions() options:Show() end
    end
end)
minimap:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine("LovacRaidButtons", 1, 0.82, 0, true) -- title (gold-ish)
    GameTooltip:AddLine("Left Click: Show/Hide Buttons", 1, 1, 1)
    GameTooltip:AddLine("Right Click: Show/Hide Options", 1, 1, 1)
    GameTooltip:Show()
end)
minimap:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)


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
    RefreshOptions()
    UpdateVisibility()
end)