local db = {}
local QUERY <const> = {
    GetVehicleInformation = "SELECT * FROM player_vehicles WHERE citizenid = ? AND plate = ?"
}
function db.GetVehicleInformation(citizenid, plate)
    local result = MySQL.single.await(QUERY.GetVehicleInformation, { citizenid, plate })
    if result then
        return result
    end
    return nil
end

return db
