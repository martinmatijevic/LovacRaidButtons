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

_G.LovacRaidButtons_OptionsFrame = options

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
scrollFrame:SetPoint("TOPLEFT", 10, -100)
scrollFrame:SetPoint("BOTTOMRIGHT", -30, 60)

local scrollChild = CreateFrame("Frame", nil, scrollFrame)
scrollChild:SetSize(1,1)
scrollFrame:SetScrollChild(scrollChild)

-- =========================
-- Refresh Options
-- =========================
local function RefreshOptions()
    if options.rows then
        for _, r in pairs(options.rows) do 
            r:Hide()
        end
    end
    options.rows = {}
    
    -- =========================
    -- Pull Timer Row
    -- =========================
    local pullRow = CreateFrame("Frame", nil, options)
    pullRow:SetSize(280, 24)
    pullRow:SetPoint("TOPLEFT", 20, -40)

    local pullLabel = pullRow:CreateFontString(nil,"OVERLAY","GameFontNormal")
    pullLabel:SetPoint("LEFT", 4, 0)
    pullLabel:SetText("Pull Timer (seconds):")

    local pullBox = CreateFrame("EditBox", nil, pullRow, "InputBoxTemplate")
    pullBox:SetSize(50,20)
    pullBox:SetPoint("LEFT", pullLabel, "RIGHT", 10, 0)
    pullBox:SetAutoFocus(false)
    pullBox:SetText(LovacRaidButtonsDB.pullTimer or "10")
    pullBox:SetMaxLetters(4)
    pullBox:SetNumeric(true)

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

    table.insert(options.rows, pullRow)

    -- =========================
    -- Interpolate Me Checkbox
    -- =========================
    local interpolateRow = CreateFrame("Frame", nil, options)
    interpolateRow:SetSize(280, 24)
    interpolateRow:SetPoint("TOPLEFT", 20, -70)

    local interpolateCheckbox = CreateFrame("CheckButton", nil, interpolateRow, "UICheckButtonTemplate")
    interpolateCheckbox:SetSize(24, 24)
    interpolateCheckbox:SetPoint("LEFT", 0, 0)
    interpolateCheckbox:SetChecked(LovacRaidButtonsDB.interpolateMe or false)
    interpolateCheckbox:SetScript("OnClick", function(self)
        LovacRaidButtonsDB.interpolateMe = self:GetChecked()
    end)

    local interpolateLabel = interpolateRow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    interpolateLabel:SetPoint("LEFT", interpolateCheckbox, "RIGHT", 8, 0)
    interpolateLabel:SetText("Replace 'me' in /rw with my name-realm")

    table.insert(options.rows, interpolateRow)

    local y = 0

    for _, id in ipairs(LovacRaidButtonsDB.order) do
        local data = LovacRaidButtonsDB.buttons[id]
        if data then
            local row = CreateFrame("Frame", nil, scrollChild)
            row:SetSize(280, 24)
            row:SetPoint("TOPLEFT", 10, y)

            local text = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            text:SetPoint("LEFT", 4, 0)
            text:SetText(LovacRaidButtons_TruncateText(data.label, 10))

            local del = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            del:SetSize(40, 20)
            del:SetPoint("RIGHT", -12, 0)
            del:SetText("Del")
            del:SetScript("OnClick", function()
                LovacRaidButtonsDB.buttons[id] = nil
                for i, oid in ipairs(LovacRaidButtonsDB.order) do
                    if oid == id then table.remove(LovacRaidButtonsDB.order,i) break end
                end
                LovacRaidButtons_RebuildButtons()
                RefreshOptions()
            end)

            local edit = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            edit:SetSize(40, 20)
            edit:SetPoint("RIGHT", del, "LEFT", -5, 0)
            edit:SetText("Edit")
            edit:SetScript("OnClick", function()
                LovacRaidButtons_ShowEditPopup(data, LovacRaidButtons_RebuildButtons, RefreshOptions)
            end)

            local rename = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            rename:SetSize(70, 20)
            rename:SetPoint("RIGHT", edit, "LEFT", -5, 0)
            rename:SetText("Rename")
            rename:SetScript("OnClick", function()
                LovacRaidButtons_ShowRenamePopup(data, LovacRaidButtons_RebuildButtons, RefreshOptions)
            end)

            table.insert(options.rows,row)
            y = y - 28
        end
    end

    scrollChild:SetHeight(-y + 5)
end
_G.LovacRaidButtons_RefreshOptions = RefreshOptions

-- =========================
-- Add Button
-- =========================
local add = CreateFrame("Button", nil, options, "UIPanelButtonTemplate")
add:SetSize(150,24)
add:SetPoint("BOTTOM", 0, 20)
add:SetText("Add Button")
add:SetScript("OnClick", function()
    LovacRaidButtons_ShowAddButtonPopup(RefreshOptions)
end)