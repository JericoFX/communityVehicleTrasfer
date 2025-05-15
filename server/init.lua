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
RegisterNetEvent("communityVehicle:server:signCurrentOwner", function(data)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then
        return lib.notify({
            title = "No Player Found",
            description = "No Player Found",
            type = "error"
        })
    end
    local vehicle = activeTransfers[Player.PlayerData.source]
    if vehicle then
        vehicle.currentOwnerSign = true
        activeTransfers[Player.PlayerData.source] = vehicle
        TriggerClientEvent("communityVehicle:client:signNewOwner", source, vehicle)
    else
        lib.notify({
            title = "No Vehicle Found",
            description = "You are not the owner of this vehicle.",
            type = "error"
        })
    end
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
