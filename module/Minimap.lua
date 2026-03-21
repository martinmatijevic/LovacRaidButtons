-- =========================
-- Minimap Button
-- =========================
local MINIMAP_RADIUS = 80

local function UpdateMinimapPosition(btn, angle)
    local x = math.cos(math.rad(angle)) * MINIMAP_RADIUS
    local y = math.sin(math.rad(angle)) * MINIMAP_RADIUS
    btn:ClearAllPoints()
    btn:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function CreateMinimapButton()
    local minimap = CreateFrame("Button", "LovacRaidButtonsMinimap", Minimap)
    minimap:SetSize(25, 25)
    minimap:SetFrameStrata("MEDIUM")
    minimap:SetNormalTexture("Interface\\Icons\\Inv_misc_note_02")
    minimap:SetHighlightTexture("Interface/Minimap/UI-Minimap-ZoomButton-Highlight")
    minimap:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    minimap:EnableMouse(true)
    minimap:SetMovable(true)
    minimap:RegisterForDrag("LeftButton")

    LovacRaidButtonsDB.minimapAngle = LovacRaidButtonsDB.minimapAngle or 45
    UpdateMinimapPosition(minimap, LovacRaidButtonsDB.minimapAngle)

    minimap:SetScript("OnDragStart", function(self) self.isDragging = true end)
    minimap:SetScript("OnDragStop", function(self) self.isDragging = false end)

    minimap:SetScript("OnUpdate", function(self)
        if not self.isDragging then return end
        local mx, my = Minimap:GetCenter()
        local px, py = GetCursorPosition()
        local scale = Minimap:GetEffectiveScale()
        px, py = px / scale, py / scale
        local angle = math.deg(math.atan2(py - my, px - mx))
        if angle < 0 then angle = angle + 360 end
        LovacRaidButtonsDB.minimapAngle = angle
        UpdateMinimapPosition(self, angle)
    end)

    minimap:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            LovacRaidButtonsDB.frameVisible = not LovacRaidButtonsDB.frameVisible
            LovacRaidButtons_UpdateVisibility(nil, true)
        elseif button == "RightButton" and LovacRaidButtons_OptionsFrame then
            if LovacRaidButtons_OptionsFrame:IsShown() then
                LovacRaidButtons_OptionsFrame:Hide()
            else
                LovacRaidButtons_RefreshOptions()
                LovacRaidButtons_OptionsFrame:Show()
            end
        end
    end)

    minimap:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("LovacRaidButtons", 1, 0.82, 0, true)
        GameTooltip:AddLine("Left Click: Show/Hide Buttons", 1, 1, 1)
        GameTooltip:AddLine("Right Click: Show/Hide Options", 1, 1, 1)
        GameTooltip:Show()
    end)

    minimap:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return minimap
end

-- Initialize on player login
local minimapInitFrame = CreateFrame("Frame")
minimapInitFrame:RegisterEvent("PLAYER_LOGIN")
minimapInitFrame:SetScript("OnEvent", function()
    CreateMinimapButton()
end)