local Core = lib.class("qb-core")
local db = require "server.modules.database.qb_core"
function Core:constructor()
    self.name = "qb-core"
    self.core = exports["qb-core"]:GetCoreObject()
    self.private.db = db
end

function Core:GetPlayerData(source, key)
    local player = self.core.Functions.GetPlayer(source)
    if player.PlayerData[key] then
        return player.PlayerData[key]
    end
    return player
end

function Core:GetPlayerInformation(source)
    return {
        source = source,
        citizenid = self.GetPlayerData(source, "citizenid"),
        fullName = self.GetPlayerData(source, "charinfo").firstname ..
            " " .. self.GetPlayerData(source, "charinfo").lastname
    }
end

function Core:GetPlayerById(id)
    return self.core.Functions.GetPlayerByCitizenId(id)
end

function Core:GetVehicleInformation(source, plate)
    local player = self.GetPlayerData(source, "citizenid")
    local information = db.GetVehicleInformation(player, plate)
    return information
end

function Core:GetAllVehicles(source)
    local player = self.GetPlayerData(source, "citizenid")
    local vehicles = db.GetAllVehicles(player)
    return vehicles
end

return Core
