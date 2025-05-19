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
    local Player, Target = Framework:GetPlayer(source), Framework:GetPlayer(data.newOwnerId)
    if not Player or not Target then
        return false, "Player not found."
    end
    local checkVehicleForPlate = Framework:GetVehicleInformation(Player.PlayerData.citizenid, data.plate)
    if not checkVehicleForPlate then
        return false, "Vehicle not found."
    end

    currentContracts[source] = {
        source = source,
        currentOwner = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname,
        currentOwnerId = Player.PlayerData.citizenid,
        currentOwnerName = Player.PlayerData.name,
        currentOwnerCitizenID = Player.PlayerData.citizenid,
        newOwner = Target.PlayerData.charinfo.firstname .. " " .. Target.PlayerData.charinfo.lastname,
        newOwnerId = Target.PlayerData.source,
        newOwnerName = Target.PlayerData.name,
        newOwnerCitizenID = Target.PlayerData.citizenid,
        role = "currentOwner",
        currenOwnerSign = false,
        newOwnerSign = false,
        vehicle = checkVehicleForPlate
    }

    -- CHECK INFO OF BOTH PLAYERS, FILL THE CURRENTCONTRACT TABLE, CHECK THE VEHICLES AND SEND BACK TO LUA
    --TriggerClientEvent(NAME .. "::client::startNewContract", data.newOwnerId, currentContracts[source])
    return currentContracts[source]
end)


lib.callback.register(NAME .. "::server::currentOwnerSigned", function(source, data)
    if not currentContracts[source] then
        return false, "No contract found."
    end
    local contract = currentContracts[source]
    contract.role = "newOwner"
    contract.currenOwnerSign = true
    TriggerClientEvent('ox_lib:notify', contract.currentOwnerId, {
        title = "Contract Accepted",
        description = "You have accepted the contract.",
        type = 'success', --'inform' or 'error' or 'success'or 'warning'
        duration = 3000
    })
    return contract
end)

---Function Called with the new owner accepts the contract
---@param source string
---@param data Contract
---@return boolean,string?
RegisterNetEvent(NAME .. "::server::newOwnerSigned", function(source, data)
    if not currentContracts[data.currentOwnerId] then
        return
    end
    local contract = currentContracts[data.currentOwnerId]
    -- MODIFY HERE THE VEHICLE OWNER IN THE DATABASE AND UPDATE THE KEYS
    TriggerClientEvent('ox_lib:notify', contract.currentOwnerId, {
        title = "Contract Accepted",
        description = "The new owner has accepted the contract.",
        type = 'success', --'inform' or 'error' or 'success'or 'warning'
        duration = 3000
    })
    TriggerClientEvent('ox_lib:notify', contract.newOwnerId, {
        title = "Contract Accepted",
        description = "You are now the owner of the vehicle.",
        type = 'success', --'inform' or 'error' or 'success'or 'warning'
        duration = 3000
    })
    contract = nil
end)
