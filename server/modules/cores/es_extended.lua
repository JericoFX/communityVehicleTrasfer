local Core = lib.class("es_extended")
local db = require "server.modules.database.es_extended"

function Core:load()
    self.name = "es_extended"
    self.core = exports["es_extended"]:getSharedObject()
    self.private.db = db
end

function Core:GetPlayerInformation(source)
    local player = self.core.GetPlayerFromId(source)
    if not player then return nil end

    return {
        source = source,
        citizenid = player.identifier, -- ESX identifier mapeado a citizenid para compatibilidad
        fullName = player.getName()    -- ESX getName() función
    }
end

function Core:GetVehicleInformation(identifier, plate)
    local information = db.GetVehicleInformation(identifier, plate)
    return information
end

function Core:ChangeVehicleOwner(newOwnerIdentifier, plate)
    local success = db.ChangeVehicleOwner(newOwnerIdentifier, plate)
    if not success then
        return false, "Failed to change vehicle owner."
    end
    return true
end

function Core:GetPlayer(source)
    return self.core.GetPlayerFromId(source)
end

Core:load()
return Core
