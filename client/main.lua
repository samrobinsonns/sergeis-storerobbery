local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local isLoggedIn = false

-- Initialize
CreateThread(function()
    while not QBCore do
        Wait(100)
    end
    
    while not QBCore.Functions.GetPlayerData().citizenid do
        Wait(100)
    end
    
    PlayerData = QBCore.Functions.GetPlayerData()
    isLoggedIn = true
    
    if Config.Debug then
        print('[StoreRobbery] Client initialized successfully')
    end
end)

-- Event handlers
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    isLoggedIn = true
    
    if Config.Debug then
        print('[StoreRobbery] Player loaded')
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
    isLoggedIn = false
    
    if Config.Debug then
        print('[StoreRobbery] Player unloaded')
    end
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
    
    if Config.Debug then
        print('[StoreRobbery] Job updated:', JobInfo.name)
    end
end)

-- Utility functions
function IsPlayerAllowed()
    if not Config.RequireJob then
        return true
    end
    
    if not PlayerData.job then
        return false
    end
    
    for _, job in pairs(Config.AllowedJobs) do
        if PlayerData.job.name == job then
            return false
        end
    end
    
    return true
end

function ShowNotification(data)
    if Config.Debug then
        print('[StoreRobbery] Notification:', data.title, data.description)
    end
    
    lib.notify({
        title = data.title,
        description = data.description,
        type = data.type or 'inform'
    })
end

function CreateBlip(coords, sprite, color, scale, duration)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, color)
    SetBlipScale(blip, scale)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Store Robbery")
    EndTextCommandSetBlipName(blip)
    
    if duration then
        CreateThread(function()
            Wait(duration)
            RemoveBlip(blip)
        end)
    end
    
    return blip
end

-- Create dispatch blip based on system
function CreateDispatchBlip(coords, alertData)
    local dispatchSystem = Config.Dispatch.System
    local blipSettings = {}
    
    -- Get blip settings based on dispatch system
    if dispatchSystem == 'qb-core' then
        blipSettings = Config.Dispatch.QB
    elseif dispatchSystem == 'ps-dispatch' then
        blipSettings = Config.Dispatch.PS
    elseif dispatchSystem == 'linden_outlawalert' then
        blipSettings = Config.Dispatch.Linden
    elseif dispatchSystem == 'cd_dispatch' then
        blipSettings = Config.Dispatch.CD
    elseif dispatchSystem == 'custom' then
        blipSettings = Config.Dispatch.Custom
    end
    
    -- Create blip with system-specific settings
    local blip = CreateBlip(
        coords, 
        blipSettings.BlipSprite or 156, 
        blipSettings.BlipColor or 1, 
        blipSettings.BlipScale or 1.0, 
        blipSettings.BlipDuration or 300000
    )
    
    if Config.Debug then
        print(string.format('[StoreRobbery] Created dispatch blip using %s system', dispatchSystem))
    end
    
    return blip
end

-- Export functions for other resources
exports('IsPlayerAllowed', IsPlayerAllowed)
exports('ShowNotification', ShowNotification)
exports('CreateBlip', CreateBlip)
exports('CreateDispatchBlip', CreateDispatchBlip)

-- Event handlers
RegisterNetEvent('storerobbery:createDispatchBlip', function(coords, alertData)
    if Config.Debug then
        print('[StoreRobbery] Creating dispatch blip for robbery')
    end
    
    CreateDispatchBlip(coords, alertData)
end)
