---@author JericoFX
---@version 0.1.0


--#region Class
---@class Contract
---@field source string The current owner's id (not in data table, passed separately)
---@field currentOwner string The current owner's name
---@field currentOwnerId string The current owner's ID
---@field currentOwnerName string The current owner's full name
---@field currentOwnerCitizenID string The current owner's citizen ID
---@field newOwner string The new owner's name
---@field newOwnerId string | number The new owner's ID
---@field newOwnerName string The new owner's full name
---@field newOwnerCitizenID string The new owner's citizen ID
---@field role string The role in the contract
---@field currenOwnerSign boolean Whether the current owner has signed
---@field newOwnerSign boolean Whether the new owner has signed
---@field vehicle table The vehicle information
---@field vehicle.brand string The vehicle's brand
---@field vehicle.model string The vehicle's model
---@field vehicle.plate string The vehicle's plate number
---@field vehicle.mileage number The vehicle's mileage
--#endregion



local Framework = GetResourceState('qb-core') == "started" and require "server.modules.qb_core" or
    GetResourceState('es_extended') == "started" and require "server.modules.es_extended" or nil
local currentContracts = {}
local NAME = ("%s::"):format(GetCurrentResourceName())


if not Framework then
    print("Framework not found, please check if you have qb-core or es_extended installed.")
    return
end


lib.callback.register(NAME .. "::server::getContracts", function()
    return currentContracts
end)

lib.callback.register(NAME .. "::server::getVehicle", function(source)
    return Framework:GetAllVehicles(source)
end)

--- This function is called when a player starts a new contract.
---@param source string
---@param data Contract
---@return boolean,string?
lib.callback.register(NAME .. "::server::startNewContract", function(source, data)
    --- Check the players here and the vehicle info
    if not data.currentOwnerId or not data.newOwnerId then
        return false, "Invalid contract data."
    end

    if currentContracts[source] then
        return false, "You already have a contract."
    end
    if currentContracts[data.newOwnerId] then
        return false, "The new owner already has a contract."
    end
    local vehicles = Framework:GetAllVehicles(source)
    if not vehicles then
        return false, "You don't have any vehicles."
    end
    currentContracts[source] = data
    currentContracts[source].role = "currentOwner"
    currentContracts[data.newOwnerId] = data
    currentContracts[data.newOwnerId].role = "newOwner"
    TriggerClientEvent(NAME .. "::client::startNewContract", data.newOwnerId, currentContracts[source])
    return true
end)

---Function Called with the new owner accepts the contract
---@param source string
---@param data Contract
---@return boolean,string?
lib.callback.register(NAME .. "::server::newOwnerSigned", function(source, data)
    if not currentContracts[data.currentOwnerId] then
        return false, "No contract found."
    end
    local contract = currentContracts[data.currentOwnerId]
    TriggerClientEvent('ox_lib:notify', contract.currentOwnerId, {
        title = "Contract Accepted",
        description = "The new owner has accepted the contract.",
        type = 'success', --'inform' or 'error' or 'success'or 'warning'
        duration = 3000
    })
    --https://overextended.dev/ox_lib/Modules/Interface/Client/notify#libnotify
    TriggerClientEvent('ox_lib:notify', contract.newOwnerId, {
        title = "Contract Accepted",
        description = "You are now the owner of the vehicle.",
        type = 'success', --'inform' or 'error' or 'success'or 'warning'
        duration = 3000
    })
    contract = nil

    return true
end)
