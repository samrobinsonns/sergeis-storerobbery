local QBCore = exports['qb-core']:GetCoreObject()
local minigameActive = false

-- Start minigame function
function StartMinigame(callback)
    if minigameActive then return end
    
    minigameActive = true
    
    -- Show NUI
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'startMinigame',
        type = Config.Minigame.Type,
        difficulty = Config.Minigame.Difficulty,
        timeLimit = Config.Minigame.TimeLimit,
        attempts = Config.Minigame.Attempts
    })
    
    if Config.Debug then
        print('[StoreRobbery] Minigame started:', Config.Minigame.Type)
    end
    
    -- Store callback
    _G.minigameCallback = callback
end

-- NUI Callbacks
RegisterNUICallback('minigameComplete', function(data, cb)
    minigameActive = false
    SetNuiFocus(false, false)
    
    if Config.Debug then
        print('[StoreRobbery] Minigame completed with success:', data.success)
    end
    
    -- Call stored callback
    if _G.minigameCallback then
        _G.minigameCallback(data.success)
        _G.minigameCallback = nil
    end
    
    cb('ok')
end)

RegisterNUICallback('minigameClose', function(data, cb)
    minigameActive = false
    SetNuiFocus(false, false)
    
    if Config.Debug then
        print('[StoreRobbery] Minigame closed')
    end
    
    -- Call stored callback with failure
    if _G.minigameCallback then
        _G.minigameCallback(false)
        _G.minigameCallback = nil
    end
    
    cb('ok')
end)

-- Safe opening sequence
function OpenSafe(safeEntity, callback)
    if not safeEntity or not DoesEntityExist(safeEntity) then
        if callback then callback() end
        return
    end
    
    -- Play safe opening animation
    local coords = GetEntityCoords(safeEntity)
    local rotation = GetEntityHeading(safeEntity)
    
    -- Create particle effect
    RequestNamedPtfxAsset("scr_rcbarry2")
    while not HasNamedPtfxAssetLoaded("scr_rcbarry2") do
        Wait(10)
    end
    
    UseParticleAssetNextCall("scr_rcbarry2")
    local particle = StartParticleFxLoopedAtCoord("scr_clown_appears", coords.x, coords.y, coords.z, 0.0, 0.0, rotation, 1.0, false, false, false, false)
    
    -- Wait for safe to open
    CreateThread(function()
        Wait(Config.Safe.SafeOpenTime)
        
        -- Stop particle effect
        if particle then
            StopParticleFxLooped(particle, false)
        end
        
        -- Call callback
        if callback then
            callback()
        end
        
        if Config.Debug then
            print('[StoreRobbery] Safe opened successfully')
        end
    end)
end

-- Export functions
exports('StartMinigame', StartMinigame)
exports('OpenSafe', OpenSafe)
