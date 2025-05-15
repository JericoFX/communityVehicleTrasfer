local QBCore = exports["qb-core"]:GetCoreObject()
local activeTransfers = {}

lib.callback.register("communityVehicle:server:getOwner", function(source, plate)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then
        return false
    end
    local vehicle = {}
    local result = MySQL.single.await("SELECT * FROM player_vehicles WHERE plate = ? AND owner = ?",
        { plate, Player.PlayerData.citizenid })
    if result.owner then
        local mods = json.decode(result.mods)
        vehicle = {
            plate = result.plate,
            model = result.vehicle,
            mileage = result.mileage
        }
        activeTransfers[Player.PlayerData.source] = {
            plate = result.plate,
            model = result.vehicle,
            mileage = result.mileage,
            newOwner = false,
            newOwnerSign = false,
            currentOwner = Player.PlayerData.citizenid,
            currentOwnerSign = false
        }
    end
    return result and vehicle or false
end)

--https://overextended.dev/ox_lib/Modules/AddCommand/Server
lib.addCommand("cTransferVehicle", {
    help = "Transfer a vehicle to another player",
    params = {

    },
    restricted = 'group.user'
}, function(source, args, raw)
    TriggerClientEvent("communityVehicle:client:openUI", source)
end)
