local QBCore = exports['qb-core']:GetCoreObject()
local robbedPlayers = {}

-- Initialize
CreateThread(function()
    if Config.Debug then
        print('[StoreRobbery] Server initialized successfully')
    end
end)

-- Utility functions
function IsPlayerAllowed(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    if not Config.RequireJob then
        return true
    end
    
    for _, job in pairs(Config.AllowedJobs) do
        if Player.PlayerData.job.name == job then
            return false
        end
    end
    
    return true
end

function IsPlayerOnCooldown(source, type)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return true end
    
    local citizenid = Player.PlayerData.citizenid
    local currentTime = os.time()
    
    if not robbedPlayers[citizenid] then
        robbedPlayers[citizenid] = {}
    end
    
    if not robbedPlayers[citizenid][type] then
        return false
    end
    
    local cooldown = type == 'cash_register' and Config.CashRegister.Cooldown or Config.Safe.Cooldown
    local timeDiff = (currentTime - robbedPlayers[citizenid][type]) * 1000
    
    if timeDiff < cooldown then
        return true
    end
    
    return false
end

function SetPlayerCooldown(source, type)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    local citizenid = Player.PlayerData.citizenid
    local currentTime = os.time()
    
    if not robbedPlayers[citizenid] then
        robbedPlayers[citizenid] = {}
    end
    
    robbedPlayers[citizenid][type] = currentTime
end

function GenerateRandomCash(min, max)
    return math.random(min, max)
end

-- Export functions
exports('IsPlayerAllowed', IsPlayerAllowed)
exports('IsPlayerOnCooldown', IsPlayerOnCooldown)
exports('SetPlayerCooldown', SetPlayerCooldown)
exports('GenerateRandomCash', GenerateRandomCash)
