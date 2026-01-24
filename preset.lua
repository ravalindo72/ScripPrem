-- ========================================
-- Variables Global
-- ========================================
FishingDelay = 0.70
CancelDelay = 0.30
StabilDelay = 0.00 -- Default 0, kalo ada "Stabil" jadi 0.080
AutoFishEnabled = false

-- ========================================
-- Preset System
-- ========================================
local Presetv2 = VyperUI:CreateCollapsibleSection(AutoTab, {
    Title = "Preset Fishing v2",
    DefaultExpanded = false,
})

-- Variables untuk track pilihan
local SelectedRod = "Element"
local SelectedSkin = "No Skin"
local SettingsDropdown = nil

-- Database preset lengkap
local PresetDatabase = {
    ["Element"] = {
        ["No Skin"] = {
            ["3 Notifly"] = {fish = 1.38, cancel = 0.3, stabil = 0},
            ["5 Notifly"] = {fish = 0.71, cancel = 0.3, stabil = 0}
        },
        ["Eclipse Katana"] = {
            ["3 Notifly"] = {fish = 1.38, cancel = 0.3, stabil = 0},
            ["5 Notifly"] = {fish = 0.71, cancel = 0.3, stabil = 0},
            ["5 Notifly Stabil"] = {fish = 0.72, cancel = 0.3, stabil = 0.080},
            ["7 Notifly Stabil"] = {fish = 0.36, cancel = 0.3, stabil = 0.080}
        },
        ["The Vanquisher"] = {
            ["3 Notifly"] = {fish = 1.38, cancel = 0.3, stabil = 0},
            ["5 Notifly"] = {fish = 0.71, cancel = 0.3, stabil = 0},
            ["5 Notifly Stabil"] = {fish = 0.72, cancel = 0.3, stabil = 0.080},
            ["7 Notifly Stabil"] = {fish = 0.36, cancel = 0.3, stabil = 0.080}
        },
        ["Krampus Scythe"] = {
            ["3 Notifly"] = {fish = 1.38, cancel = 0.3, stabil = 0},
            ["5 Notifly"] = {fish = 0.71, cancel = 0.3, stabil = 0},
            ["5 Notifly Stabil"] = {fish = 0.72, cancel = 0.3, stabil = 0.080},
            ["7 Notifly Stabil"] = {fish = 0.36, cancel = 0.3, stabil = 0.080},
            ["9 Notifly"] = {fish = 0.263, cancel = 0.3, stabil = 0}
        },
        ["Soul Scyhte"] = {
            ["3 Notifly"] = {fish = 1.38, cancel = 0.3, stabil = 0},
            ["5 Notifly"] = {fish = 0.71, cancel = 0.3, stabil = 0},
            ["5 Notifly Stabil"] = {fish = 0.72, cancel = 0.3, stabil = 0.080},
            ["8 Notifly"] = {fish = 0.68, cancel = 0.3, stabil = 0}
        },
        ["Holy Trident"] = {
            ["3 Notifly"] = {fish = 1.38, cancel = 0.3, stabil = 0},
            ["5 Notifly"] = {fish = 0.71, cancel = 0.3, stabil = 0},
            ["5 Notifly Stabil"] = {fish = 0.72, cancel = 0.3, stabil = 0.080},
            ["8 Notifly"] = {fish = 0.68, cancel = 0.3, stabil = 0}
        }
    },
    ["Diamond"] = {
        ["No Skin"] = {
            ["3 Notifly"] = {fish = 1.38, cancel = 0.3, stabil = 0},
            ["5 Notifly"] = {fish = 0.71, cancel = 0.3, stabil = 0}
        },
        ["Eclipse Katana"] = {
            ["3 Notifly"] = {fish = 1.38, cancel = 0.3, stabil = 0},
            ["5 Notifly"] = {fish = 0.71, cancel = 0.3, stabil = 0},
            ["5 Notifly Stabil"] = {fish = 0.72, cancel = 0.3, stabil = 0.080},
            ["7 Notifly Stabil"] = {fish = 0.36, cancel = 0.3, stabil = 0.080}
        },
        ["The Vanquisher"] = {
            ["3 Notifly"] = {fish = 1.38, cancel = 0.3, stabil = 0},
            ["5 Notifly"] = {fish = 0.71, cancel = 0.3, stabil = 0},
            ["5 Notifly Stabil"] = {fish = 0.72, cancel = 0.3, stabil = 0.080},
            ["7 Notifly Stabil"] = {fish = 0.36, cancel = 0.3, stabil = 0.080}
        },
        ["Krampus Scythe"] = {
            ["3 Notifly"] = {fish = 1.38, cancel = 0.3, stabil = 0},
            ["5 Notifly"] = {fish = 0.71, cancel = 0.3, stabil = 0},
            ["5 Notifly Stabil"] = {fish = 0.72, cancel = 0.3, stabil = 0.080},
            ["7 Notifly Stabil"] = {fish = 0.36, cancel = 0.3, stabil = 0.080},
            ["9 Notifly"] = {fish = 0.263, cancel = 0.3, stabil = 0}
        },
        ["Soul Scyhte"] = {
            ["3 Notifly"] = {fish = 1.38, cancel = 0.3, stabil = 0},
            ["5 Notifly"] = {fish = 0.71, cancel = 0.3, stabil = 0},
            ["5 Notifly Stabil"] = {fish = 0.72, cancel = 0.3, stabil = 0.080},
            ["7 Notifly Stabil"] = {fish = 0.68, cancel = 0.3, stabil = 0.080},
            ["11-13 Notifly"] = {fish = 0.175, cancel = 0.3, stabil = 0}
        },
        ["Holy Trident"] = {
            ["3 Notifly"] = {fish = 1.38, cancel = 0.3, stabil = 0},
            ["5 Notifly"] = {fish = 0.71, cancel = 0.3, stabil = 0},
            ["5 Notifly Stabil"] = {fish = 0.72, cancel = 0.3, stabil = 0.080},
            ["7 Notifly Stabil"] = {fish = 0.68, cancel = 0.3, stabil = 0.080},
            ["11-13 Notifly"] = {fish = 0.175, cancel = 0.3, stabil = 0}
        }
    }
}

-- Function untuk get available settings berdasarkan Rod + Skin
local function GetSettingsOptions()
    if PresetDatabase[SelectedRod] and PresetDatabase[SelectedRod][SelectedSkin] then
        local options = {}
        for settingName, _ in pairs(PresetDatabase[SelectedRod][SelectedSkin]) do
            table.insert(options, settingName)
        end
        return options
    end
    return {"3 Notifly"} -- Fallback
end

-- Function untuk apply preset
local function ApplyPreset(settingName)
    if PresetDatabase[SelectedRod] and 
       PresetDatabase[SelectedRod][SelectedSkin] and 
       PresetDatabase[SelectedRod][SelectedSkin][settingName] then
        
        local preset = PresetDatabase[SelectedRod][SelectedSkin][settingName]
        FishingDelay = preset.fish
        CancelDelay = preset.cancel
        StabilDelay = preset.stabil
        
        print("✅ PRESET APPLIED:")
        print("   Rod:", SelectedRod)
        print("   Skin:", SelectedSkin)
        print("   Setting:", settingName)
        print("   Fish Delay:", FishingDelay .. "s")
        print("   Cancel Delay:", CancelDelay .. "s")
        print("   Stabil Delay:", StabilDelay .. "s")
    else
        print("⚠️ Preset not found!")
    end
end

-- Function untuk recreate Settings Dropdown
local function UpdateSettingsDropdown()
    if SettingsDropdown then
        SettingsDropdown:Destroy()
    end
    
    local availableOptions = GetSettingsOptions()
    
    SettingsDropdown = VyperUI:CreateDropdownV2(Presetv2, {
        Title = "Settings",
        Subtitle = "Select Settings Type",
        Options = availableOptions,
        Default = availableOptions[1],
        AutoSave = false,
        Callback = function(val)
            ApplyPreset(val)
        end
    })
end

-- Dropdown 1: Rod Type
VyperUI:CreateDropdownV2(Presetv2, {
    Title = "Pilih RodMu",
    Subtitle = "Select rod Type",
    Options = {"Element", "Diamond"},
    Default = "Element",
    AutoSave = true,
    Callback = function(val)
        SelectedRod = val
        print("🎣 Rod Selected:", val)
        UpdateSettingsDropdown()
    end
})

-- Dropdown 2: Skin Type
VyperUI:CreateDropdownV2(Presetv2, {
    Title = "Skin Yang Di punya",
    Subtitle = "Select Skin Type",
    Options = {"No Skin", "Eclipse Katana", "The Vanquisher", "Krampus Scythe", "Soul Scyhte", "Holy Trident"},
    Default = "No Skin",
    AutoSave = true,
    Callback = function(val)
        SelectedSkin = val
        print("🎨 Skin Selected:", val)
        UpdateSettingsDropdown()
    end
})

-- Buat Settings Dropdown pertama kali
UpdateSettingsDropdown()

-- ========================================
-- Blatant V1 Section
-- ========================================
local BlatantFishSection = VyperUI:CreateCollapsibleSection(HomeTab, {
    Title = "Blatant V1",
    DefaultExpanded = false,
})

-- SAFE PARALLEL EXECUTION
local function safeFire(func)
    task.spawn(function()
        pcall(func)
    end)
end

-- MAIN LOOP
local function UltimateBypassFishing()
    task.spawn(function()
        while AutoFishEnabled do
            local currentTime = workspace:GetServerTimeNow()
            
            safeFire(function()
                RFChargeFishingRod:InvokeServer({[1] = currentTime})
            end)

            safeFire(function()
                RFRequestFishingMinigameStarted:InvokeServer(1, 0, currentTime)
            end)
            
            task.wait(FishingDelay)

            -- COMPLETE
            safeFire(function()
                REFishingCompleted:FireServer()
            end)

            task.wait(CancelDelay)

            -- CANCEL
            safeFire(function()
                RFCancelFishingInputs:InvokeServer()
            end)
            
            task.wait(StabilDelay) -- Delay tambahan untuk preset "Stabil"
        end
    end)
end

-- UI: Fish Delay
VyperUI:CreateNumericInput(BlatantFishSection, {
    Title = "Fish Delay",
    Subtitle = "V1 Fish Delay",
    AutoSave = true,
    Min = 0,
    Max = 5.5,
    Default = 0.70,
    DecimalPlaces = 2,
    Suffix = "s",
    Callback = function(v)
        FishingDelay = v
    end
})

-- UI: Cancel Delay
VyperUI:CreateNumericInput(BlatantFishSection, {
    Title = "Cancel Delay",
    Subtitle = "V1 Cancel Delay",
    AutoSave = true,
    Min = 0,
    Max = 5.5,
    Default = 0.30,
    DecimalPlaces = 2,
    Suffix = "s",
    Callback = function(v)
        CancelDelay = v
    end
})

-- TOGGLE
VyperUI:CreateToggle(BlatantFishSection, {
    Title = "Auto Fish",
    Subtitle = "Blatant V1",
    AutoSave = true,
    Default = false,
    Callback = function(state)
        AutoFishEnabled = state
        if state then
            print("🟢 BLATANT FISH: ENABLED")
            UltimateBypassFishing()
        else
            print("🔴 AUTO FISH STOPPED")
        end
    end
})
