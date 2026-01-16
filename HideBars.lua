-- HideBars Addon using ACE3 Libraries
local AceAddon = LibStub("AceAddon-3.0")
local AceEvent = LibStub("AceEvent-3.0")
local AceConsole = LibStub("AceConsole-3.0")
local AceDB = LibStub("AceDB-3.0")
local LDB = LibStub("LibDataBroker-1.1")
local DBIcon = LibStub("LibDBIcon-1.0")

-- Create the addon
local HideBars = AceAddon:NewAddon("HideBars", "AceEvent-3.0", "AceConsole-3.0")

-- Default settings
local defaults = {
    profile = {
        enabled = true,
        minimap = {
            hide = false,
        }
    }
}

-- List of UI elements to hide/show
local UI_ELEMENTS = {
    "MicroButtonContainer",
    "CharacterMicroButton",
    "SpellbookMicroButton",
    "TalentMicroButton",
    "WorldMapMicroButton",
    "AchievementMicroButton",
    "QuestLogMicroButton",
    "SocialsMicroButton",
    "HelpMicroButton",
    "LevelUpDisplayFrame",
    "MainMenuMicroButton",
    "MainMenuBarBackpackButton",
    "KeyRingButton",
    "CharacterBag0Slot",
    "CharacterBag1Slot",
    "CharacterBag2Slot",
    "CharacterBag3Slot",
}

function HideBars:HideBars()
    for _, element in ipairs(UI_ELEMENTS) do
        local frame = _G[element]
        if frame then 
            frame:Hide()
            -- Add a script to prevent the frame from being shown by other addons/events
            frame:SetScript("OnShow", function(self)
                if HideBars.db and HideBars.db.profile and HideBars.db.profile.enabled then
                    self:Hide()
                end
            end)
        end
    end
end

function HideBars:ShowBars()
    for _, element in ipairs(UI_ELEMENTS) do
        local frame = _G[element]
        if frame then frame:Show() end
    end
end

function HideBars:ToggleBars()
    self.db.profile.enabled = not self.db.profile.enabled
    if self.db.profile.enabled then
        self:HideBars()
        self:Print("|cff00ff00enabled|r")
    else
        self:ShowBars()
        self:Print("|cffff0000disabled|r")
    end
    self:UpdateMinimapButton()
end

function HideBars:OnInitialize()
    -- Initialize the database
    self.db = AceDB:New("HideBarsDB", defaults, true)
    
    -- Create LibDataBroker object
    self.ldb = LDB:NewDataObject("HideBars", {
        type = "launcher",
        label = "HideBars",
        icon = "Interface\\AddOns\\HideBars\\Media\\icon.blp",
        OnClick = function(_, button)
            if button == "LeftButton" then
                HideBars:ToggleBars()
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine("|cff808080HideBars|r")
            tooltip:AddLine("Left-click to toggle bars")
            if HideBars.db.profile.enabled then
                tooltip:AddLine("|cff00ff00Status: Enabled|r")
            else
                tooltip:AddLine("|cffff0000Status: Disabled|r")
            end
        end,
    })
    
    -- Create minimap button
    DBIcon:Register("HideBars", self.ldb, self.db.profile.minimap)
end

function HideBars:OnEnable()
    -- Register events to catch UI resets
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnPlayerEnteringWorld")
    self:RegisterEvent("PLAYER_LOGIN", "OnPlayerEnteringWorld")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnPlayerEnteringWorld")
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnPlayerEnteringWorld")
    
    -- Register slash commands
    self:RegisterChatCommand("hb", "SlashCommandHB")
    self:RegisterChatCommand("hidebars", "SlashCommandHB")
    self:RegisterChatCommand("ticket", "SlashCommandTicket")
    
    -- Apply initial state
    if self.db.profile.enabled then
        self:HideBars()
    else
        self:ShowBars()
    end
    
    self:UpdateMinimapButton()
end

function HideBars:OnPlayerEnteringWorld()
    -- Reapply the bars state when entering the world
    if self.db.profile.enabled then
        self:HideBars()
    else
        self:ShowBars()
    end
    self:UpdateMinimapButton()
    
    -- Show version message with current time
    local timeStamp = time()
    local timeStr = date("%I:%M %p", timeStamp)
    DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFFFF80FF%s [Broccoli] whispers: Thank you for always being there; your friendship means more to me than words can express.|r", timeStr))
end

function HideBars:UpdateMinimapButton()
    if self.ldb then
        if self.db.profile.enabled then
            self.ldb.text = "|cff00ff00●|r"
        else
            self.ldb.text = "|cffff0000●|r"
        end
    end
end

function HideBars:SlashCommandHB(msg)
    msg = msg:lower():trim()
    
    if msg == "hide" then
        self.db.profile.enabled = true
        self:HideBars()
        self:Print("|cff00ff00enabled|r")
    elseif msg == "show" then
        self.db.profile.enabled = false
        self:ShowBars()
        self:Print("|cffff0000disabled|r")
    elseif msg == "toggle" then
        self:ToggleBars()
        if self.db.profile.enabled then
            self:Print("|cff00ff00enabled|r")
        else
            self:Print("|cffff0000disabled|r")
        end
    else
        self:Print("|cffffaabfUsage:|r /hb show - hide - toggle")
    end
end

function HideBars:SlashCommandTicket()
    ToggleHelpFrame()
    -- Re-hide bars if they were hidden (help frame may show them)
    if self.db.profile.enabled then
        self:HideBars()
    end
end