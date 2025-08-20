local QBCore = exports['qb-core']:GetCoreObject()
local robbedRegisters = {}
local isRobbing = false

-- Initialize cash register targeting
CreateThread(function()
    if not Config.CashRegister.Enabled then return end
    
    Wait(1000) -- Wait for everything to load
    
    -- Add ox_target to all cash register props
    for _, prop in pairs(Config.CashRegister.Props) do
        exports.ox_target:addModel(prop, {
            {
                name = 'rob_cash_register',
                icon = 'fas fa-cash-register',
                label = 'Rob Cash Register',
                distance = 2.0,
                onSelect = function()
                    RobCashRegister()
                end,
                canInteract = function()
                    return not isRobbing and IsPlayerAllowed() and not IsRegisterRobbed(prop)
                end
            }
        })
    end
    
    if Config.Debug then
        print('[StoreRobbery] Cash register targeting initialized')
    end
end)

-- Check if register was recently robbed
function IsRegisterRobbed(prop)
    local playerCoords = GetEntityCoords(PlayerPedId())
    
    for _, robbed in pairs(robbedRegisters) do
        if robbed.prop == prop and robbed.coords == playerCoords then
            if GetGameTimer() - robbed.time < Config.CashRegister.Cooldown then
                return true
            else
                -- Remove expired cooldown
                for i = #robbedRegisters, 1, -1 do
                    if robbedRegisters[i].prop == prop and robbedRegisters[i].coords == playerCoords then
                        table.remove(robbedRegisters, i)
                        break
                    end
                end
            end
        end
    end
    
    return false
end

-- Main robbery function
function RobCashRegister()
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
    
    -- Check if police are nearby (optional)
    if Config.Debug then
        print('[StoreRobbery] Starting cash register robbery')
    end
    
    -- Create dispatch alert when robbery STARTS
    if Config.CashRegister.DispatchAlert and Config.Dispatch.Enabled then
        TriggerServerEvent('storerobbery:createDispatch', playerCoords, 'cash_register')
    end
    
    isRobbing = true
    
    -- Start cash register robbery interface
    local estimatedAmount = math.random(Config.CashRegister.MinCash, Config.CashRegister.MaxCash)
    
    -- Show NUI
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'startCashRegisterRobbery',
        duration = Config.CashRegister.ProgressBarTime,
        estimatedAmount = estimatedAmount
    })
    
    -- Wait for completion or cancellation
    CreateThread(function()
        local startTime = GetGameTimer()
        local completed = false
        local cancelled = false
        
        while GetGameTimer() - startTime < Config.CashRegister.ProgressBarTime and not completed and not cancelled do
            Wait(100)
            
            -- Check if player moved too far or died
            local currentCoords = GetEntityCoords(playerPed)
            local distance = #(currentCoords - playerCoords)
            
            if distance > 3.0 or IsPedDeadOrDying(playerPed, true) then
                cancelled = true
                break
            end
        end
        
        if not cancelled then
            -- Robbery completed successfully
            TriggerServerEvent('storerobbery:robCashRegister', playerCoords)
            
            -- Add to robbed registers list
            table.insert(robbedRegisters, {
                prop = 'cash_register',
                coords = playerCoords,
                time = GetGameTimer()
            })
            
            if Config.Debug then
                print('[StoreRobbery] Cash register robbery completed')
            end
        else
            -- Robbery was cancelled
            ShowNotification({
                title = 'Robbery Cancelled',
                description = 'You moved too far or died during the robbery',
                type = 'warning'
            })
            
            if Config.Debug then
                print('[StoreRobbery] Cash register robbery cancelled')
            end
        end
        
        -- Hide NUI
        SetNuiFocus(false, false)
        SendNUIMessage({
            action = 'hideCashRegister'
        })
    end)
    
    isRobbing = false
end

-- Event handlers
RegisterNetEvent('storerobbery:cashRegisterRobbed', function(cashAmount, coords)
    ShowNotification({
        title = Config.Notifications.Success.title,
        description = 'You got away with $' .. cashAmount,
        type = 'success'
    })
end)

RegisterNetEvent('storerobbery:registerCooldown', function()
    ShowNotification(Config.Notifications.Cooldown)
end)

RegisterNetEvent('storerobbery:locationCooldown', function()
    ShowNotification({
        title = 'Location Recently Robbed',
        description = 'This location was recently robbed. Try another location or wait.',
        type = 'warning'
    })
end)

-- NUI Callbacks
RegisterNUICallback('cashRegisterCompleted', function(data, cb)
    if Config.Debug then
        print('[StoreRobbery] Cash register robbery completed via NUI')
    end
    
    -- Show success notification
    ShowNotification({
        title = 'Robbery Successful!',
        description = 'You got away with the cash!',
        type = 'success'
    })
    
    -- Trigger server event to give money
    TriggerServerEvent('storerobbery:robCashRegister', GetEntityCoords(PlayerPedId()))
    
    cb('ok')
end)

RegisterNUICallback('cashRegisterCancelled', function(data, cb)
    if Config.Debug then
        print('[StoreRobbery] Cash register robbery cancelled via NUI')
    end
    
    cb('ok')
end)

-- Export function
exports('RobCashRegister', RobCashRegister)
