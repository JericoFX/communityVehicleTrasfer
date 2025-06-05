# Vehicle Transfer Contract (BETA)

A vehicle transfer system for FiveM servers that allows secure transactions between players using contracts.

⚠️ **This resource is currently in BETA. Use with caution on production servers.**

## Features

- Vehicle transfer contracts between players
- Digital signature system
- Basic anti-exploit protection
- Item-based contracts (blank and signed)
- Multi-language support (Spanish and English)
- ox_target integration

## Framework Support

- QBCore ✅
- QBX Core ✅
- ESX ✅

## Requirements

- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_target](https://github.com/overextended/ox_target)
- [oxmysql](https://github.com/overextended/oxmysql)
- [ox_inventory](https://github.com/overextended/ox_inventory)

## Installation

1. Download and place in your `resources` folder

2. Add the items to your inventory system:

```lua
-- Example for ox_inventory (data/items.lua)
['vehicle_contract_blank'] = {
    label = 'Vehicle Contract (Blank)',
    weight = 100,
    description = 'A blank contract for vehicle transfers'
},

['vehicle_contract_signed'] = {
    label = 'Vehicle Contract (Signed)',
    weight = 100,
    description = 'A signed vehicle transfer contract'
}
```

3. Start the resource:

```
ensure communityVehicleTrasfer
```

## Usage

### Current Owner:

1. Approach the vehicle you want to transfer
2. Use ox_target on the player you want to transfer to
3. Select "Transfer Vehicle"
4. Sign the contract
5. Wait for the new owner to sign

### New Owner:

1. Receive the contract notification
2. Review vehicle details
3. Sign the contract to complete the transfer

## Configuration

Basic configuration can be found in `config/init.lua`. Adjust settings according to your server needs.

## Known Issues

- This is a beta version, bugs may occur
- Limited testing on all framework combinations
- Some features may not work as expected

## Support

This is a community resource in beta testing. Use at your own risk.

## License

This project is licensed under the GNU General Public License v3.0 (GPL-3.0) - a permissive license that allows for free use, modification, and distribution while ensuring that derivative works remain open source.

## Credits

This script is developed for [@The-Order-Of-The-Sacred-Framework](https://github.com/The-Order-Of-The-Sacred-Framework/) - A developer fellowship focused on creating unified systems and high-quality FiveM resources for the community.
