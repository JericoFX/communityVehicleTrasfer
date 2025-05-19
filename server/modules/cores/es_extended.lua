local Core = lib.class("es_extended")
local db = require "server.modules.database.es_extended"
function Core:load()
    self.name = "es_extended"
    self.core = exports["es_extended"]:getSharedObject()
    self.private.db = db
end

function Core:GetPlayerData(source, key)
    local player = self.core.GetPlayerFromId(source)
    return player.get(key)
end

function Core:GetPlayerInformation(source)
    return {
        source = source,
        citizenid = self.GetPlayerData(source, "identifier"),
        fullName = self.GetPlayerData(source, "firstName") .. " " .. self.GetPlayerData(source, "lastName")
    }
end

function Core:GetVehicleInformation(source, plate)
    local player = self.GetPlayerData(source, "identifier")
    local information = db.GetVehicleInformation(player, plate)
    return information
end

Core:load()
return Core
