local QBCore = exports['qb-core']:GetCoreObject()

-- Safe robbery event
RegisterNetEvent('storerobbery:robSafe', function(index, coords)
    local source = source
    
    -- Check if player is allowed
    if not IsPlayerAllowed(source) then
        TriggerClientEvent('storerobbery:safeCooldown', source)
        return
    end
    
    -- Check player cooldown
    if IsPlayerOnCooldown(source, 'safe') then
        TriggerClientEvent('storerobbery:safeCooldown', source)
        return
    end
    
    -- Check location cooldown
    if IsLocationOnCooldown(coords, 'safe') then
        TriggerClientEvent('storerobbery:locationCooldown', source)
        return
    end
    
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    -- Generate random cash amount
    local cashAmount = GenerateRandomCash(Config.Safe.MinCash, Config.Safe.MaxCash)
    
    -- Add money to player
    Player.Functions.AddMoney('cash', cashAmount, 'store-robbery-safe')
    
    -- Set both cooldowns
    SetPlayerCooldown(source, 'safe')
    SetLocationCooldown(coords, 'safe')
    
    -- Log robbery
    if Config.Debug then
        print(string.format('[StoreRobbery] Player %s robbed safe %d for $%d', Player.PlayerData.name, index, cashAmount))
    end
    
    -- Notify client
    TriggerClientEvent('storerobbery:safeRobbed', source, index, cashAmount, coords)
end)

-- Dispatch alert creation
function CreateDispatchAlert(coords, type, playerName)
    if not Config.Dispatch.Enabled then return end
    
    local dispatchSystem = Config.Dispatch.System
    local locationName = GetLocationName(coords)
    
    if Config.Debug then
        print(string.format('[StoreRobbery] Creating dispatch alert using system: %s', dispatchSystem))
    end
    
    -- Handle different dispatch systems
    if dispatchSystem == 'qb-core' then
        CreateQBDispatch(coords, type, playerName, locationName)
    elseif dispatchSystem == 'ps-dispatch' then
        CreatePSDispatch(coords, type, playerName, locationName)
    elseif dispatchSystem == 'linden_outlawalert' then
        CreateLindenDispatch(coords, type, playerName, locationName)
    elseif dispatchSystem == 'cd_dispatch' then
        CreateCDDispatch(coords, type, playerName, locationName)
    elseif dispatchSystem == 'custom' then
        CreateCustomDispatch(coords, type, playerName, locationName)
    else
        print('[StoreRobbery] Unknown dispatch system:', dispatchSystem)
    end
end

-- QB-Core Dispatch
function CreateQBDispatch(coords, type, playerName, locationName)
    local Players = QBCore.Functions.GetQBPlayers()
    local alertData = {
        title = Config.Dispatch.QB.AlertTitle,
        description = Config.Dispatch.QB.AlertDescription,
        coords = coords,
        type = type,
        playerName = playerName
    }
    
    for _, Player in pairs(Players) do
        if Player.PlayerData.job.name == Config.Dispatch.QB.JobName then
            TriggerClientEvent('storerobbery:createDispatchBlip', Player.PlayerData.source, coords, alertData)
            
            -- Send notification
            TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, 
                string.format('%s at %s by %s', alertData.title, locationName, playerName), 
                'error', 10000)
        end
    end
    
    if Config.Debug then
        print(string.format('[StoreRobbery] QB-Core dispatch alert sent for %s robbery at %s by %s', type, locationName, playerName))
    end
end

-- PS-Dispatch
function CreatePSDispatch(coords, type, playerName, locationName)
    local alertData = {
        type = 'robbery',
        title = Config.Dispatch.PS.AlertTitle,
        description = Config.Dispatch.PS.AlertDescription,
        coords = coords,
        playerName = playerName,
        location = locationName
    }
    
    -- Trigger PS-Dispatch event
    TriggerEvent('ps-dispatch:server:CreateAlert', alertData)
    
    if Config.Debug then
        print(string.format('[StoreRobbery] PS-Dispatch alert sent for %s robbery at %s by %s', type, locationName, playerName))
    end
end

-- Linden Outlaw Alert
function CreateLindenDispatch(coords, type, playerName, locationName)
    local alertData = {
        type = 'robbery',
        title = Config.Dispatch.Linden.AlertTitle,
        description = Config.Dispatch.Linden.AlertDescription,
        coords = coords,
        playerName = playerName,
        location = locationName
    }
    
    -- Trigger Linden Outlaw Alert event
    TriggerEvent('linden_outlawalert:alertPolice', alertData)
    
    if Config.Debug then
        print(string.format('[StoreRobbery] Linden Outlaw Alert sent for %s robbery at %s by %s', type, locationName, playerName))
    end
end

-- CD Dispatch
function CreateCDDispatch(coords, type, playerName, locationName)
    local alertData = {
        type = 'robbery',
        title = Config.Dispatch.CD.AlertTitle,
        description = Config.Dispatch.CD.AlertDescription,
        coords = coords,
        playerName = playerName,
        location = locationName
    }
    
    -- Trigger CD Dispatch event
    TriggerEvent('cd_dispatch:AddNotification', alertData)
    
    if Config.Debug then
        print(string.format('[StoreRobbery] CD Dispatch alert sent for %s robbery at %s by %s', type, locationName, playerName))
    end
end

-- Custom Dispatch
function CreateCustomDispatch(coords, type, playerName, locationName)
    local alertData = {
        type = Config.Dispatch.Custom.DataField,
        title = Config.Dispatch.Custom.AlertTitle,
        description = Config.Dispatch.Custom.AlertDescription,
        coords = coords,
        playerName = playerName,
        location = locationName
    }
    
    -- Trigger custom dispatch event
    TriggerEvent(Config.Dispatch.Custom.EventName, alertData)
    
    if Config.Debug then
        print(string.format('[StoreRobbery] Custom dispatch alert sent for %s robbery at %s by %s', type, locationName, playerName))
    end
end

-- Get location name from coordinates
function GetLocationName(coords)
    local street1, street2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local streetName = GetStreetNameFromHashKey(street1)
    
    if street2 ~= 0 then
        streetName = streetName .. ' & ' .. GetStreetNameFromHashKey(street2)
    end
    
    return streetName
end

-- Command to spawn safe at player location (admin only)
QBCore.Commands.Add('spawnsafe', 'Spawn a safe at your current location (Admin Only)', {}, true, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    if Player.PlayerData.job.name ~= 'admin' and Player.PlayerData.job.name ~= 'superadmin' then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have permission to use this command!', 'error')
        return
    end
    
    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)
    
    -- Add new safe location to config
    local newLocation = {
        coords = coords,
        heading = GetEntityHeading(playerPed),
        name = "Admin Spawned Safe"
    }
    
    table.insert(Config.Safe.Locations, newLocation)
    
    -- Spawn safe on client
    TriggerClientEvent('storerobbery:spawnSafeAtLocation', source, newLocation, #Config.Safe.Locations)
    
    TriggerClientEvent('QBCore:Notify', source, 'Safe spawned at your location!', 'success')
    
    if Config.Debug then
        print(string.format('[StoreRobbery] Admin %s spawned safe at %s', Player.PlayerData.name, GetLocationName(coords)))
    end
end)

-- Command to remove safe (admin only)
QBCore.Commands.Add('removesafe', 'Remove the nearest safe (Admin Only)', {}, true, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    if Player.PlayerData.job.name ~= 'admin' and Player.PlayerData.job.name ~= 'superadmin' then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have permission to use this command!', 'error')
        return
    end
    
    local playerPed = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(playerPed)
    
    -- Find nearest safe
    local nearestIndex = nil
    local nearestDistance = math.huge
    
    for i, location in pairs(Config.Safe.Locations) do
        local distance = #(playerCoords - location.coords)
        if distance < nearestDistance then
            nearestDistance = distance
            nearestIndex = i
        end
    end
    
    if nearestIndex and nearestDistance <= 10.0 then
        -- Remove safe from config
        table.remove(Config.Safe.Locations, nearestIndex)
        
        -- Remove safe on client
        TriggerClientEvent('storerobbery:removeSafe', source, nearestIndex)
        
        TriggerClientEvent('QBCore:Notify', source, 'Safe removed!', 'success')
        
        if Config.Debug then
            print(string.format('[StoreRobbery] Admin %s removed safe at index %d', Player.PlayerData.name, nearestIndex))
        end
    else
        TriggerClientEvent('QBCore:Notify', source, 'No safe found nearby!', 'error')
    end
end)

-- Server event handler for dispatch creation
RegisterNetEvent('storerobbery:createDispatch', function(coords, type)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    -- Create dispatch alert when robbery starts
    if Config.Dispatch.Enabled then
        CreateDispatchAlert(coords, type, Player.PlayerData.name)
    end
end)

-- Export functions
exports('CreateDispatchAlert', CreateDispatchAlert)
exports('GetLocationName', GetLocationName)
