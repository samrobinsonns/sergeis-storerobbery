Config = {}

-- General Settings
Config.Debug = false
Config.RequireJob = false -- Set to true if you want to restrict to specific jobs
Config.AllowedJobs = {'police', 'ambulance'} -- Jobs that can't rob stores

-- Cash Register Settings
Config.CashRegister = {
    Enabled = true,
    Props = {
        'prop_till_01',
        'prop_till_02',
        'prop_till_03',
        'v_ret_gc_till',
        'v_ret_gc_till2',
        'v_ret_gc_till3'
    },
    MinCash = 50,
    MaxCash = 200,
    ProgressBarTime = 30000, -- 30 seconds
    Cooldown = 300000, -- 5 minutes between robberies (per player)
    LocationCooldown = 600000, -- 10 minutes between robberies (per location)
    DispatchAlert = true
}

-- Safe Settings
Config.Safe = {
    Enabled = true,
    Props = {
        'prop_ld_safe_01',
        'prop_ld_safe_02',
        'v_ilev_gb_safe'
    },
    Locations = {
        {
            coords = vector3(24.03, -1347.35, 29.5),
            heading = 0.0,
            name = "24/7 Store - Grove Street"
        },
        {
            coords = vector3(2557.458, 382.282, 108.622),
            heading = 0.0,
            name = "24/7 Store - Palomino Freeway"
        },
        {
            coords = vector3(373.875, 325.896, 103.566),
            heading = 0.0,
            name = "24/7 Store - Downtown"
        },
        {
            coords = vector3(147.037, -1035.643, 29.368),
            heading = 0.0,
            name = "24/7 Store - La Mesa"
        },
        {
            coords = vector3(-1222.915, -907.983, 12.326),
            heading = 0.0,
            name = "24/7 Store - Venice Beach"
        }
    },
    MinigameTime = 30000, -- 30 seconds to complete minigame
    SafeOpenTime = 10000, -- 10 seconds for safe to open
    MinCash = 200,
    MaxCash = 500,
    Cooldown = 1800000, -- 30 minutes between safe robberies (per player)
    LocationCooldown = 3600000, -- 60 minutes between safe robberies (per location)
    DispatchAlert = true
}

-- Dispatch Settings
Config.Dispatch = {
    Enabled = true,
    System = 'qb-core', -- 'qb-core', 'ps-dispatch', 'linden_outlawalert', 'cd_dispatch', 'custom'
    
    -- QB-Core Settings
    QB = {
        JobName = 'police',
        AlertTitle = 'Store Robbery in Progress',
        AlertDescription = 'A store robbery has been reported',
        BlipSprite = 156,
        BlipColor = 1,
        BlipScale = 1.0,
        BlipDuration = 300000 -- 5 minutes
    },
    
    -- PS-Dispatch Settings
    PS = {
        JobName = 'police',
        AlertTitle = 'Store Robbery',
        AlertDescription = 'A store robbery has been reported',
        BlipSprite = 156,
        BlipColor = 1,
        BlipScale = 1.0,
        BlipDuration = 300000
    },
    
    -- Linden Outlaw Alert Settings
    Linden = {
        JobName = 'police',
        AlertTitle = 'Store Robbery',
        AlertDescription = 'A store robbery has been reported',
        BlipSprite = 156,
        BlipColor = 1,
        BlipScale = 1.0,
        BlipDuration = 300000
    },
    
    -- CD Dispatch Settings
    CD = {
        JobName = 'police',
        AlertTitle = 'Store Robbery',
        AlertDescription = 'A store robbery has been reported',
        BlipSprite = 156,
        BlipColor = 1,
        BlipScale = 1.0,
        BlipDuration = 300000
    },
    
    -- Custom Dispatch Settings
    Custom = {
        JobName = 'police',
        AlertTitle = 'Store Robbery',
        AlertDescription = 'A store robbery has been reported',
        BlipSprite = 156,
        BlipColor = 1,
        BlipScale = 1.0,
        BlipDuration = 300000,
        EventName = 'custom:dispatch:alert', -- Custom event name
        DataField = 'robbery' -- Custom data field
    }
}

-- Minigame Settings
Config.Minigame = {
    Type = 'lockpick', -- 'lockpick', 'hacking', 'pattern'
    Difficulty = 'medium', -- 'easy', 'medium', 'hard'
    TimeLimit = 30, -- seconds
    Attempts = 3
}

-- Notification Settings
Config.Notifications = {
    Success = {
        title = 'Robbery Successful',
        description = 'You got away with some cash!',
        type = 'success'
    },
    Failed = {
        title = 'Robbery Failed',
        description = 'You failed to complete the robbery!',
        type = 'error'
    },
    Cooldown = {
        title = 'Cooldown Active',
        description = 'You must wait before attempting another robbery!',
        type = 'warning'
    }
}
