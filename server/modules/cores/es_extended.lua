local Core = lib.class("es_extended")
local db = require "server.modules.database.es_extended"
local inventory = require "server.modules.inventory.init"

function Core:load()
    self.name = "es_extended"
    self.core = exports["es_extended"]:getSharedObject()
    self.private.db = db
    self.private.inventory = inventory
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



-- Funciones de inventario (usando sistema automático)
function Core:AddItem(source, item, amount, metadata, slot)
    return self.private.inventory.AddItem(source, item, amount, metadata, slot)
end

function Core:RemoveItem(source, item, amount, slot)
    return self.private.inventory.RemoveItem(source, item, amount, slot)
end

function Core:HasItem(source, item, amount)
    return self.private.inventory.HasItem(source, item, amount)
end



Core:load()
return Core
