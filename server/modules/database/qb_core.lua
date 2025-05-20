local db = {}
local QUERY <const> = {
    GetVehicleInformation = "SELECT plate,vehicle FROM player_vehicles WHERE citizenid = ? AND plate = ?",
    GetAllVehicles = "SELECT * FROM player_vehicles WHERE citizenid = ?",
    ChangeVehicleOwner = "UPDATE player_vehicles SET citizenid = ? WHERE plate = ?",
}
function db.GetVehicleInformation(citizenid, plate)
    local result = MySQL.single.await(QUERY.GetVehicleInformation, { citizenid, plate })
    if result then
        return result
    end
    return nil
end

function db.ChangeVehicleOwner(newCitizenId, plate)
    local result = MySQL.update.await(QUERY.ChangeVehicleOwner, { newCitizenId, plate })
    return result and result > 0 -- returns true if at least one row was updated
end

return db
