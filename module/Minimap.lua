-- =========================
-- Minimap Button
-- =========================
local function CreateMinimapButton()
    local minimap = CreateFrame("Button", "LovacRaidButtonsMinimap", Minimap)
    minimap:SetSize(25, 25)
    minimap:SetFrameStrata("MEDIUM")
    minimap:SetNormalTexture("Interface/AddOns/LovacRaidButtons/media/LovacRaidButtons")
    minimap:SetHighlightTexture("Interface/Minimap/UI-Minimap-ZoomButton-Highlight")
    minimap:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    
    minimap:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            LovacRaidButtonsDB.frameVisible = not LovacRaidButtonsDB.frameVisible
            LovacRaidButtons_UpdateVisibility(nil, true)
        elseif button == "RightButton" then
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