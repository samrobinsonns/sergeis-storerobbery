# Store Robbery Script for FiveM

A comprehensive store robbery script for FiveM servers with two different robbery processes: cash register robberies and safe robberies.

## Features

### 🏪 Cash Register Robberies
- **Automatic Detection**: Automatically detects cash register props using ox_target
- **Progress Bar**: Interactive progress bar during robbery
- **Configurable Rewards**: Min/max cash amounts in config
- **Cooldown System**: Prevents spam robberies
- **Dispatch Integration**: Automatic police alerts

### 🔐 Safe Robberies
- **Predefined Locations**: Multiple safe locations across the map
- **Dynamic Spawning**: Safes spawn at configured coordinates
- **Interactive Minigames**: Three different minigame types
- **Higher Rewards**: Better payouts than cash registers
- **Longer Cooldowns**: Balanced gameplay mechanics

### 🎮 Minigame System
- **Lockpick Game**: Rotating pin with target zone
- **Hacking Game**: Node connection puzzle
- **Pattern Game**: Memory sequence game
- **Difficulty Levels**: Easy, medium, hard
- **Responsive UI**: Modern, mobile-friendly interface

### 🚔 Dispatch Integration
- **QB-Core Based**: Integrates with QB-Core framework
- **Police Alerts**: Automatic notifications for law enforcement
- **Blip System**: Map markers for robbery locations
- **Configurable**: Customizable alert settings

## Dependencies

- **QB-Core**: Core framework
- **ox_lib**: UI components and utilities
- **oxmysql**: Database operations (optional)

## Dispatch System Compatibility

The script supports multiple dispatch systems out of the box:

### 🔧 **Supported Systems**
- **QB-Core**: Native QB-Core dispatch with blips and notifications
- **PS-Dispatch**: Popular dispatch system with advanced features
- **Linden Outlaw Alert**: Lightweight alert system
- **CD Dispatch**: Custom dispatch solution
- **Custom**: Your own dispatch system with configurable events

### 📋 **System Requirements**
- **QB-Core**: No additional resources needed
- **PS-Dispatch**: Requires `ps-dispatch` resource
- **Linden Outlaw Alert**: Requires `linden_outlawalert` resource  
- **CD Dispatch**: Requires `cd_dispatch` resource
- **Custom**: Configure your own event names and data fields

### ⚙️ **Configuration**
Simply change `Config.Dispatch.System` to your preferred dispatch system:
```lua
Config.Dispatch.System = 'ps-dispatch'  -- Use PS-Dispatch
Config.Dispatch.System = 'custom'        -- Use custom system
```

## Installation

1. **Download the Resource**
   ```bash
   cd resources
   git clone https://github.com/yourusername/sergeis-storerobbery
   ```

2. **Install Dependencies**
   - Ensure QB-Core is installed and running
   - Install ox_lib: `ox_lib`
   - Install oxmysql: `oxmysql`

3. **Configure the Resource**
   - Edit `config.lua` to customize settings
   - Adjust safe locations, cash amounts, and cooldowns
   - Configure dispatch settings for your server

4. **Add to server.cfg**
   ```cfg
   ensure sergeis-storerobbery
   ```

5. **Restart Your Server**

## Configuration

### General Settings
```lua
Config.Debug = false                    -- Enable debug mode
Config.RequireJob = false               -- Restrict to specific jobs
Config.AllowedJobs = {'police', 'ambulance'}  -- Jobs that can't rob
```

### Cash Register Settings
```lua
Config.CashRegister = {
    Enabled = true,
    MinCash = 50,                       -- Minimum cash reward
    MaxCash = 200,                      -- Maximum cash reward
    ProgressBarTime = 5000,             -- Robbery duration (ms)
    Cooldown = 300000,                  -- Cooldown between robberies (ms)
    DispatchAlert = true                -- Send police alerts
}
```

### Safe Settings
```lua
Config.Safe = {
    Enabled = true,
    MinCash = 200,                      -- Minimum cash reward
    MaxCash = 500,                      -- Maximum cash reward
    MinigameTime = 30000,              -- Minigame time limit (ms)
    SafeOpenTime = 10000,              -- Safe opening animation time (ms)
    Cooldown = 1800000,                -- Cooldown between robberies (ms)
    DispatchAlert = true                -- Send police alerts
}
```

### Dispatch Settings
```lua
Config.Dispatch = {
    Enabled = true,
    System = 'qb-core',                 -- Dispatch system to use
    
    -- Supported systems: 'qb-core', 'ps-dispatch', 'linden_outlawalert', 'cd_dispatch', 'custom'
    
    -- QB-Core Settings
    QB = {
        JobName = 'police',             -- Job that receives alerts
        AlertTitle = 'Store Robbery in Progress',
        BlipSprite = 156,               -- Map blip sprite
        BlipColor = 1,                  -- Map blip color
        BlipDuration = 300000           -- Blip duration (ms)
    },
    
    -- PS-Dispatch Settings
    PS = {
        JobName = 'police',
        AlertTitle = 'Store Robbery',
        BlipSprite = 156,
        BlipColor = 1,
        BlipDuration = 300000
    },
    
    -- Linden Outlaw Alert Settings
    Linden = {
        JobName = 'police',
        AlertTitle = 'Store Robbery',
        BlipSprite = 156,
        BlipColor = 1,
        BlipDuration = 300000
    },
    
    -- CD Dispatch Settings
    CD = {
        JobName = 'police',
        AlertTitle = 'Store Robbery',
        BlipSprite = 156,
        BlipColor = 1,
        BlipDuration = 300000
    },
    
    -- Custom Dispatch Settings
    Custom = {
        JobName = 'police',
        AlertTitle = 'Store Robbery',
        BlipSprite = 156,
        BlipColor = 1,
        BlipDuration = 300000,
        EventName = 'custom:dispatch:alert', -- Custom event name
        DataField = 'robbery'                -- Custom data field
    }
}
```

## Usage

### For Players

#### Cash Register Robberies
1. Find a cash register in any store
2. Use ox_target to interact with the register
3. Complete the progress bar
4. Receive cash reward
5. Wait for cooldown to expire

#### Safe Robberies
1. Locate a safe at configured locations
2. Use ox_target to start robbery
3. Complete the minigame
4. Wait for safe to open
5. Receive cash reward
6. Wait for cooldown to expire

### For Administrators

#### Commands
- `/resetrobberycooldown [id]` - Reset robbery cooldown for a player
- `/checkrobberycooldown` - Check your current cooldown status
- `/spawnsafe` - Spawn a safe at your location (admin only)
- `/removesafe` - Remove the nearest safe (admin only)

#### Adding Safe Locations
Edit `config.lua` and add new locations to the `Config.Safe.Locations` table:
```lua
{
    coords = vector3(x, y, z),
    heading = 0.0,
    name = "Store Name - Location"
}
```

## Minigame Types

### 🔓 Lockpick Game
- Rotating pin moves around a circle
- Green target zone indicates where to click
- Click when pin is in the target zone
- Score based on accuracy
- Multiple attempts allowed

### 💻 Hacking Game
- Grid-based node connection puzzle
- Connect start node to end node
- Click adjacent nodes to create path
- Different grid sizes based on difficulty
- Time-based scoring

### 🧩 Pattern Game
- Memory sequence game
- Watch the pattern, then repeat it
- Multiple levels with increasing difficulty
- Score based on level completion
- Pattern gets longer each level

## Customization

### Adding New Props
To add new cash register or safe props, edit the respective arrays in `config.lua`:
```lua
Config.CashRegister.Props = {
    'prop_till_01',
    'your_new_prop'
}
```

### Modifying Rewards
Adjust cash amounts and cooldowns in the config file to balance gameplay for your server.

### Custom Minigames
The minigame system is modular and can be extended with new game types by modifying the HTML/JavaScript files.

## Troubleshooting

### Common Issues

1. **Targeting Not Working**
   - Ensure ox_target is properly installed
   - Check that props are correctly listed in config
   - Verify ox_target exports are working

2. **Minigame Not Showing**
   - Check browser console for JavaScript errors
   - Ensure HTML files are properly loaded
   - Verify NUI callbacks are registered

3. **Dispatch Not Working**
   - Confirm QB-Core is running
   - Check job names in config
   - Verify police job exists on your server

### Debug Mode
Enable debug mode in config to see detailed console output:
```lua
Config.Debug = true
```

## Support

For support and questions:
- Create an issue on GitHub
- Join our Discord server
- Check the documentation

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Credits

- **Developer**: Sergei
- **Framework**: QB-Core
- **UI Library**: ox_lib
- **Targeting**: ox_target

## Changelog

### Version 1.0.0
- Initial release
- Cash register robbery system
- Safe robbery system with minigames
- Dispatch integration
- Configurable settings
- Admin commands
- Modern UI design
