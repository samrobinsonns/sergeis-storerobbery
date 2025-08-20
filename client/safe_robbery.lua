local QBCore = exports['qb-core']:GetCoreObject()
local spawnedSafes = {}
local robbedSafes = {}
local isRobbing = false

-- Initialize safe spawning
CreateThread(function()
    if not Config.Safe.Enabled then return end
    
    Wait(2000) -- Wait for everything to load
    
    -- Spawn safes at configured locations
    for i, location in pairs(Config.Safe.Locations) do
        SpawnSafe(location, i)
    end
    
    if Config.Debug then
        print('[StoreRobbery] Safe spawning initialized')
    end
end)

-- Spawn safe at location
function SpawnSafe(location, index)
    local safeModel = Config.Safe.Props[1] -- Use first safe prop by default
    
    RequestModel(safeModel)
    while not HasModelLoaded(safeModel) do
        Wait(10)
    end
    
    local safe = CreateObject(GetHashKey(safeModel), location.coords.x, location.coords.y, location.coords.z - 1.0, false, false, false)
    SetEntityHeading(safe, location.heading)
    FreezeEntityPosition(safe, true)
    SetEntityAsMissionEntity(safe, true, true)
    
    -- Add ox_target to safe
    exports.ox_target:addLocalEntity(safe, {
        {
            name = 'rob_safe_' .. index,
            icon = 'fas fa-vault',
            label = 'Rob Safe',
            distance = 2.0,
            onSelect = function()
                RobSafe(index, location, safe)
            end,
            canInteract = function()
                return not isRobbing and IsPlayerAllowed() and not IsSafeRobbed(index)
            end
        }
    })
    
    spawnedSafes[index] = {
        entity = safe,
        location = location,
        robbed = false
    }
    
    if Config.Debug then
        print('[StoreRobbery] Safe spawned at:', location.name)
    end
end

-- Check if safe was recently robbed
function IsSafeRobbed(index)
    for _, robbed in pairs(robbedSafes) do
        if robbed.index == index then
            if GetGameTimer() - robbed.time < Config.Safe.Cooldown then
                return true
            else
                -- Remove expired cooldown
                for i = #robbedSafes, 1, -1 do
                    if robbedSafes[i].index == index then
                        table.remove(robbedSafes, i)
                        break
                    end
                end
            end
        end
    end
    
    return false
end

-- Main safe robbery function
function RobSafe(index, location, safeEntity)
    if isRobbing then return end
    
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    -- Check if player is in a vehicle
    if IsPedInAnyVehicle(playerPed, false) then
        ShowNotification({
            title = 'Cannot Rob',
            description = 'You cannot rob while in a vehicle!',
            type = 'error'
        })
        return
    end
    
    -- Check distance to safe
    local distance = #(playerCoords - location.coords)
    if distance > 3.0 then
        ShowNotification({
            title = 'Too Far',
            description = 'You are too far from the safe!',
            type = 'error'
        })
        return
    end
    
    if Config.Debug then
        print('[StoreRobbery] Starting safe robbery at:', location.name)
    end
    
    -- Create dispatch alert when robbery STARTS
    if Config.Safe.DispatchAlert and Config.Dispatch.Enabled then
        TriggerServerEvent('storerobbery:createDispatch', playerCoords, 'safe')
    end
    
    isRobbing = true
    
    -- Start minigame
    StartMinigame(function(success)
        if success then
            -- Minigame completed successfully
            TriggerServerEvent('storerobbery:robSafe', index, location.coords)
            
            -- Add to robbed safes list
            table.insert(robbedSafes, {
                index = index,
                time = GetGameTimer()
            })
            
            -- Mark safe as robbed
            spawnedSafes[index].robbed = true
            
            if Config.Debug then
                print('[StoreRobbery] Safe robbery completed at:', location.name)
            end
        else
            -- Minigame failed
            ShowNotification(Config.Notifications.Failed)
            
            if Config.Debug then
                print('[StoreRobbery] Safe robbery failed at:', location.name)
            end
        end
        
        isRobbing = false
    end)
end

-- Event handlers
RegisterNetEvent('storerobbery:safeRobbed', function(index, cashAmount, coords)
    ShowNotification({
        title = Config.Notifications.Success.title,
        description = 'You got away with $' .. cashAmount,
        type = 'success'
    })
end)

RegisterNetEvent('storerobbery:safeCooldown', function()
    ShowNotification(Config.Notifications.Cooldown)
end)

RegisterNetEvent('storerobbery:locationCooldown', function()
    ShowNotification({
        title = 'Location Recently Robbed',
        description = 'This location was recently robbed. Try another location or wait.',
        type = 'warning'
    })
end)

-- Export functions
exports('SpawnSafe', SpawnSafe)
exports('RobSafe', RobSafe)
