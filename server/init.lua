---@author JericoFX
---@version 1.0.0

lib.locale()

local Contract = require "server.modules.contract.contract"
local AntiExploit = require "server.modules.security.AntiExploit"
local Framework = require "server.modules.cores.init"
local antiExploit = AntiExploit:new()

print("^2[ORDER VEHICLE TRANSFER] ^7Successfully loaded with framework: " .. Framework.GetFramework())

lib.callback.register("orderVehicleTransfer::server::hasItem", function(source, item, amount)
    return Framework.HasItem(source, item, amount or 1)
end)

--- Start a new vehicle transfer contract
---@param source number Player server ID
---@param contractData table Contract initialization data
---@return table|nil, string? Contract data or error message
lib.callback.register("orderVehicleTransfer::server::startNewContract", function(source, contractData)
    if Config.items.requireContractItem then
        if not Framework.HasItem(source, Config.items.blankContract, 1) then
            return nil, locale('need_blank_contract')
        end
    end

    local currentOwnerInfo = Framework.GetPlayerInformation(source)
    local newOwnerInfo = Framework.GetPlayerInformation(contractData.newOwnerId)

    if not currentOwnerInfo or not newOwnerInfo then
        return nil, locale('players_offline')
    end

    local vehicleInfo = Framework.GetVehicleInformation(
        currentOwnerInfo.citizenid,
        contractData.plate
    )

    if not vehicleInfo then
        return nil, locale('vehicle_not_found')
    end

    local newContractData = {
        currentOwner = currentOwnerInfo.fullName,
        currentOwnerId = source,
        currentOwnerCitizenID = currentOwnerInfo.citizenid,
        newOwner = newOwnerInfo.fullName,
        newOwnerId = contractData.newOwnerId,
        newOwnerCitizenID = newOwnerInfo.citizenid,
        vehicle = vehicleInfo,
        vehicleNetId = contractData.vehicleNetId
    }

    local contract = Contract:new(source, newContractData)

    if not contract then
        return nil, locale('contract_creation_error')
    end

    return contract:getClientData()
end)


--- Handle current owner signing the contract
---@param source number Player server ID
---@param contractData table Contract data from client
---@return boolean Success status
lib.callback.register("orderVehicleTransfer::server::currentOwnerSigned", function(source, contractData)
    local contract = Contract.GetById(contractData.id)

    if not contract then
        return false, locale('contract_not_found')
    end

    if contract.currentOwnerId ~= source then
        antiExploit:logSuspiciousActivity(source, "UNAUTHORIZED_CONTRACT_SIGN", {
            contractId = contractData.id,
            expectedOwnerId = contract.currentOwnerId
        })
        return false, locale('unauthorized_sign')
    end

    -- Process the signature
    local success, error = contract:getCurrentOwnerSign()

    if not success then
        return false, error
    end

    return true
end)

--- Handle new owner signing the contract
---@param source number Player server ID
---@param contractData table Contract data from client
---@return boolean Success status
lib.callback.register("orderVehicleTransfer::server::newOwnerSigned", function(source, contractData)
    local contract = Contract.GetById(contractData.id)

    if not contract then
        return false, locale('contract_not_found')
    end

    if contract.newOwnerId ~= source then
        antiExploit:logSuspiciousActivity(source, "UNAUTHORIZED_CONTRACT_SIGN", {
            contractId = contractData.id,
            expectedNewOwnerId = contract.newOwnerId
        })
        return false, locale('unauthorized_sign')
    end

    local success, error = contract:getNewOwnerSign()

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
        Config.VehicleKeys(contract.vehicle.plate)
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
