local Core = lib.class("qbx_core")
local db = require "server.modules.database.qbx_core"

function Core:load()
    self.name = "qbx_core"
    self.core = exports.qbx_core
    self.private.db = db
end

function Core:GetPlayerInformation(source)
    local player = self.core:GetPlayer(source)
    if not player then return nil end

    local charinfo = player.PlayerData.charinfo
    if not charinfo then return nil end

    return {
        source = source,
        citizenid = player.PlayerData.citizenid,
        fullName = charinfo.firstname .. " " .. charinfo.lastname
    }
end

function Core:GetVehicleInformation(citizenid, plate)
    local information = db.GetVehicleInformation(citizenid, plate)
    return information
end

function Core:ChangeVehicleOwner(newOwnerCitizenId, plate)
    local success = db.ChangeVehicleOwner(newOwnerCitizenId, plate)
    if not success then
        return false, "Failed to change vehicle owner."
    end
    return true
end

function Core:GetPlayer(source)
    return self.core:GetPlayer(source)
end

Core:load()
return Core
