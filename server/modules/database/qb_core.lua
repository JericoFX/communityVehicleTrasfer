local db = {}
local QUERY <const> = {
    GetVehicleInformation = "SELECT * FROM player_vehicles WHERE citizenid = ? AND plate = ?",
    GetAllVehicles = "SELECT * FROM player_vehicles WHERE citizenid = ?",
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
    if result then
        return result
    end
    return nil
end

return db
