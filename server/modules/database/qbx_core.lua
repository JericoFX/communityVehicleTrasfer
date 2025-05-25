local db = {}
local QUERY <const> = {
    GetVehicleInformation = "SELECT plate, vehicle FROM player_vehicles WHERE citizenid = ? AND plate = ?",
    GetAllVehicles = "SELECT * FROM player_vehicles WHERE citizenid = ?",
    ChangeVehicleOwner = "UPDATE player_vehicles SET citizenid = ? WHERE plate = ?",
    GetPlayerData = "SELECT * FROM players WHERE citizenid = ?",
    GetPlayerVehicles = "SELECT * FROM player_vehicles WHERE citizenid = ?",
}

function db.GetVehicleInformation(citizenid, plate)
    local result = MySQL.single.await(QUERY.GetVehicleInformation, { citizenid, plate })
    if result then
        return result
    end
    return nil
end

function db.GetAllVehicles(citizenid)
    local result = MySQL.query.await(QUERY.GetAllVehicles, { citizenid })
    return result or {}
end

function db.ChangeVehicleOwner(newCitizenId, plate)
    local result = MySQL.update.await(QUERY.ChangeVehicleOwner, { newCitizenId, plate })
    return result and result > 0 -- returns true if at least one row was updated
end

function db.GetPlayerData(citizenid)
    local result = MySQL.single.await(QUERY.GetPlayerData, { citizenid })
    if result then
        return result
    end
    return nil
end

function db.GetPlayerVehicles(citizenid)
    local result = MySQL.query.await(QUERY.GetPlayerVehicles, { citizenid })
    return result or {}
end

return db
