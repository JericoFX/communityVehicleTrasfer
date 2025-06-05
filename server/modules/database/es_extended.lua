local db = {}
local QUERY <const> = {
    GetVehicleInformation = "SELECT plate, vehicle FROM owned_vehicles WHERE owner = ? AND plate = ?",
    GetAllVehicles = "SELECT * FROM owned_vehicles WHERE owner = ?",
    ChangeVehicleOwner = "UPDATE owned_vehicles SET owner = ? WHERE plate = ?",
    GetPlayerData = "SELECT * FROM users WHERE identifier = ?",
    GetPlayerVehicles = "SELECT * FROM owned_vehicles WHERE owner = ?",
}

function db.GetVehicleInformation(identifier, plate)
    local result = MySQL.single.await(QUERY.GetVehicleInformation, { identifier, plate })
    if result then
        return result
    end
    return nil
end

function db.GetAllVehicles(identifier)
    local result = MySQL.query.await(QUERY.GetAllVehicles, { identifier })
    return result or {}
end

function db.ChangeVehicleOwner(newIdentifier, plate)
    local result = MySQL.update.await(QUERY.ChangeVehicleOwner, { newIdentifier, plate })
    return result and result > 0 -- returns true if at least one row was updated
end

function db.GetPlayerData(identifier)
    local result = MySQL.single.await(QUERY.GetPlayerData, { identifier })
    if result then
        return result
    end
    return nil
end

function db.GetPlayerVehicles(identifier)
    local result = MySQL.query.await(QUERY.GetPlayerVehicles, { identifier })
    return result or {}
end

return db
