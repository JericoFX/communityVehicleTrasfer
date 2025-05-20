---@author JericoFX
---@version 0.1.0
---@
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
---@param data table
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
lib.callback.register(NAME .. "::server::newOwnerSigned", function(source, data)
    if not currentContracts[data.currentOwnerId] then
        return false, "No contract found."
    end
    local contract = currentContracts[data.currentOwnerId]
    -- MODIFY HERE THE VEHICLE OWNER IN THE DATABASE AND UPDATE THE KEYS
    local success = Framework:ChangeVehicleOwner(contract.newOwnerCitizenID, contract.vehicle.plate)
    if not success then
        return false, "Failed to change vehicle owner."
    end

    if success then
        print('Vehicle ownership transferred!')
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
    else
        print('Transfer failed.')
        TriggerClientEvent('ox_lib:notify', contract.currentOwnerId, {
            title = "Contract Error",
            description = "The new owner has not accepted the contract.",
            type = 'error', --'inform' or 'error' or 'success'or 'warning'
            duration = 3000
        })
    end
    contract = nil
    return true
end)
