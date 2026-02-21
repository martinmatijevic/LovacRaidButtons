-- =========================
-- Custom Edit Button Popup
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
_G.LovacRaidButtons_ShowEditPopup = ShowEditPopup

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
_G.LovacRaidButtons_ShowRenamePopup = ShowRenamePopup


-- =========================
-- Add Button Popup
-- =========================
local function ShowAddButtonPopup(RefreshOptionsFunc)
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

    local closeX = CreateFrame("Button", nil, popup, "UIPanelCloseButton")
    closeX:SetPoint("TOPRIGHT", -6, -6)
    closeX:SetScript("OnClick", function() popup:Hide() end)

    local labelBox = CreateFrame("EditBox", nil, popup, "InputBoxTemplate")
    labelBox:SetSize(200,20)
    labelBox:SetPoint("TOP", title, "BOTTOM", 0, -10)
    labelBox:SetAutoFocus(true)
    labelBox:SetText("")
    labelBox:SetMaxLetters(50)

    local labelText = popup:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    labelText:SetPoint("BOTTOMLEFT", labelBox, "TOPLEFT", 0, 0)
    labelText:SetText("Button Label:")

    local msgBox = CreateFrame("EditBox", nil, popup, "InputBoxTemplate")
    msgBox:SetSize(200,20)
    msgBox:SetPoint("TOP", labelBox, "BOTTOM", 0, -20)
    msgBox:SetAutoFocus(false)
    msgBox:SetText("")
    msgBox:SetMaxLetters(200)

    local msgText = popup:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    msgText:SetPoint("BOTTOMLEFT", msgBox, "TOPLEFT", 0, 0)
    msgText:SetText("Message:")

    local addBtn = CreateFrame("Button", nil, popup, "UIPanelButtonTemplate")
    addBtn:SetSize(80,24)
    addBtn:SetPoint("BOTTOMLEFT", 20, 10)
    addBtn:SetText("Add")
    addBtn:SetScript("OnClick", function()
        local label = labelBox:GetText() or "CUSTOM"
        local msg = msgBox:GetText() or ""
        if msg ~= "" then
            local id = LovacRaidButtons_GenerateID()
            LovacRaidButtonsDB.buttons[id] = { id = id, label = label, message = msg }
            table.insert(LovacRaidButtonsDB.order, id)
            LovacRaidButtons_RebuildButtons()
            if RefreshOptionsFunc then RefreshOptionsFunc() end
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
end
_G.LovacRaidButtons_ShowAddButtonPopup = ShowAddButtonPopup