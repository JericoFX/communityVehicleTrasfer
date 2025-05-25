local Core = lib.class("qbx_core")
local db = require "server.modules.database.qbx_core"
local inventory = require "server.modules.inventory.init"

function Core:load()
    self.name = "qbx_core"
    self.core = exports.qbx_core
    self.private.db = db
    self.private.inventory = inventory
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
