local QBCore = exports['qb-core']:GetCoreObject()

-- Cash register robbery event
RegisterNetEvent('storerobbery:robCashRegister', function(coords)
    local source = source
    
    -- Check if player is allowed
    if not IsPlayerAllowed(source) then
        TriggerClientEvent('storerobbery:registerCooldown', source)
        return
    end
    
    -- Check player cooldown
    if IsPlayerOnCooldown(source, 'cash_register') then
        TriggerClientEvent('storerobbery:registerCooldown', source)
        return
    end
    
    -- Check location cooldown
    if IsLocationOnCooldown(coords, 'cash_register') then
        TriggerClientEvent('storerobbery:locationCooldown', source)
        return
    end
    
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    -- Generate random cash amount
    local cashAmount = GenerateRandomCash(Config.CashRegister.MinCash, Config.CashRegister.MaxCash)
    
    -- Add money to player
    Player.Functions.AddMoney('cash', cashAmount, 'store-robbery-cash-register')
    
    -- Set both cooldowns
    SetPlayerCooldown(source, 'cash_register')
    SetLocationCooldown(coords, 'cash_register')
    
    -- Log robbery
    if Config.Debug then
        print(string.format('[StoreRobbery] Player %s robbed cash register for $%d', Player.PlayerData.name, cashAmount))
    end
    
    -- Notify client
    TriggerClientEvent('storerobbery:cashRegisterRobbed', source, cashAmount, coords)
end)

-- Command to reset cooldown (admin only)
QBCore.Commands.Add('resetrobberycooldown', 'Reset robbery cooldown for a player (Admin Only)', {{name = 'id', help = 'Player ID'}}, true, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    if Player.PlayerData.job.name ~= 'admin' and Player.PlayerData.job.name ~= 'superadmin' then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have permission to use this command!', 'error')
        return
    end
    
    local targetId = tonumber(args[1])
    if not targetId then
        TriggerClientEvent('QBCore:Notify', source, 'Please provide a valid player ID!', 'error')
        return
    end
    
    local TargetPlayer = QBCore.Functions.GetPlayer(targetId)
    if not TargetPlayer then
        TriggerClientEvent('QBCore:Notify', source, 'Player not found!', 'error')
        return
    end
    
    -- Reset player cooldowns
    local citizenid = TargetPlayer.PlayerData.citizenid
    if robbedPlayers[citizenid] then
        robbedPlayers[citizenid] = {}
        TriggerClientEvent('QBCore:Notify', source, 'Player robbery cooldowns reset for ' .. TargetPlayer.PlayerData.name, 'success')
        TriggerClientEvent('QBCore:Notify', targetId, 'Your robbery cooldowns have been reset by an admin', 'success')
    else
        TriggerClientEvent('QBCore:Notify', source, 'Player has no active cooldowns', 'inform')
    end
end)

-- Command to reset location cooldowns (admin only)
QBCore.Commands.Add('resetlocationcooldowns', 'Reset all location robbery cooldowns (Admin Only)', {}, true, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    if Player.PlayerData.job.name ~= 'admin' and Player.PlayerData.job.name ~= 'superadmin' then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have permission to use this command!', 'error')
        return
    end
    
    -- Reset all location cooldowns
    robbedLocations = {}
    
    TriggerClientEvent('QBCore:Notify', source, 'All location robbery cooldowns have been reset!', 'success')
    
    if Config.Debug then
        print('[StoreRobbery] Admin ' .. Player.PlayerData.name .. ' reset all location cooldowns')
    end
end)

-- Command to check cooldown status
QBCore.Commands.Add('checkrobberycooldown', 'Check robbery cooldown status', {}, false, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    local citizenid = Player.PlayerData.citizenid
    local currentTime = os.time()
    
    if not robbedPlayers[citizenid] then
        TriggerClientEvent('QBCore:Notify', source, 'No robbery cooldowns active', 'success')
        return
    end
    
    local message = 'Robbery Cooldowns:\n'
    
    if robbedPlayers[citizenid]['cash_register'] then
        local timeDiff = (currentTime - robbedPlayers[citizenid]['cash_register']) * 1000
        local remaining = math.max(0, Config.CashRegister.Cooldown - timeDiff)
        local minutes = math.floor(remaining / 60000)
        local seconds = math.floor((remaining % 60000) / 1000)
        message = message .. 'Cash Register: ' .. minutes .. 'm ' .. seconds .. 's remaining\n'
    else
        message = message .. 'Cash Register: Ready\n'
    end
    
    if robbedPlayers[citizenid]['safe'] then
        local timeDiff = (currentTime - robbedPlayers[citizenid]['safe']) * 1000
        local remaining = math.max(0, Config.Safe.Cooldown - timeDiff)
        local minutes = math.floor(remaining / 60000)
        local seconds = math.floor((remaining % 60000) / 1000)
        message = message .. 'Safe: ' .. minutes .. 'm ' .. seconds .. 's remaining'
    else
        message = message .. 'Safe: Ready'
    end
    
    TriggerClientEvent('QBCore:Notify', source, message, 'inform')
end)

-- Command to check location cooldown status
QBCore.Commands.Add('checklocationcooldowns', 'Check location robbery cooldown status', {}, false, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    if #robbedLocations == 0 then
        TriggerClientEvent('QBCore:Notify', source, 'No location cooldowns active', 'success')
        return
    end
    
    local message = 'Location Cooldowns:\n'
    local currentTime = os.time()
    local count = 0
    
    for locationKey, types in pairs(robbedLocations) do
        for type, time in pairs(types) do
            count = count + 1
            local timeDiff = (currentTime - time) * 1000
            local cooldown = type == 'cash_register' and Config.CashRegister.Cooldown or Config.Safe.Cooldown
            local remaining = math.max(0, cooldown - timeDiff)
            local minutes = math.floor(remaining / 60000)
            local seconds = math.floor((remaining % 60000) / 1000)
            
            message = message .. string.format('%s at %s: %dm %ds remaining\n', 
                type == 'cash_register' and 'Cash Register' or 'Safe', 
                locationKey, minutes, seconds)
        end
    end
    
    if count == 0 then
        message = 'No location cooldowns active'
    end
    
    TriggerClientEvent('QBCore:Notify', source, message, 'inform')
end)
