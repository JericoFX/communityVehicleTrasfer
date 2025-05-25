---@author JericoFX
---@version 1.0.0

-- Load configuration
lib.locale()

-- Load modules
local Contract = require "server.modules.contract.contract"
local AntiExploit = require "server.modules.security.AntiExploit"

-- Initialize unified framework system (auto-detects framework and inventory)
Framework = require "server.modules.cores.init"

-- Initialize security system
local antiExploit = AntiExploit:new()

print("^2[ORDER VEHICLE TRANSFER] ^7Successfully loaded with framework: " .. Framework.GetFramework())



-- Callback to check if player has an item
lib.callback.register("orderVehicleTransfer::server::hasItem", function(source, item, amount)
    return Framework.HasItem(source, item, amount or 1)
end)

--- Start a new vehicle transfer contract
---@param source number Player server ID
---@param contractData table Contract initialization data
---@return table|nil, string? Contract data or error message
lib.callback.register("orderVehicleTransfer::server::startNewContract", function(source, contractData)
    -- Check if player has required contract item
    if Config.items.requireContractItem then
        if not Framework.HasItem(source, Config.items.blankContract, 1) then
            return nil, locale('need_blank_contract')
        end
    end
    
    -- Get player information using unified API
    local currentOwnerInfo = Framework.GetPlayerInformation(source)
    local newOwnerInfo = Framework.GetPlayerInformation(contractData.newOwnerId)
    
    if not currentOwnerInfo or not newOwnerInfo then
        return nil, locale('players_offline')
    end
    
    -- Get vehicle information and verify ownership
    local vehicleInfo = Framework.GetVehicleInformation(
        currentOwnerInfo.citizenid, 
        contractData.plate
    )
    
    if not vehicleInfo then
        return nil, locale('vehicle_not_found')
    end
    
    -- Prepare contract data
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
    
    -- Create new contract
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
    -- Find the contract by ID
    local contract = Contract.GetById(contractData.id)
    
    if not contract then
        return false, locale('contract_not_found')
    end
    
    -- Verify the source matches the contract owner
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
    -- Find the contract by ID
    local contract = Contract.GetById(contractData.id)
    
    if not contract then
        return false, locale('contract_not_found')
    end
    
    -- Verify the source matches the new owner
    if contract.newOwnerId ~= source then
        antiExploit:logSuspiciousActivity(source, "UNAUTHORIZED_CONTRACT_SIGN", {
            contractId = contractData.id,
            expectedNewOwnerId = contract.newOwnerId
        })
        return false, locale('unauthorized_sign')
    end
    
    -- Process the signature and complete transfer
    local success, error = contract:getNewOwnerSign()
    
    if not success then
        return false, error
    end
    
    return true
end)

--- Cancel a contract
---@param source number Player server ID
---@param contractData table Contract data
---@return boolean Success status
lib.callback.register("orderVehicleTransfer::server::cancelContract", function(source, contractData)
    local contract = Contract.GetById(contractData.id)
    
    if not contract then
        return false, locale('contract_not_found')
    end
    
    -- Only contract parties can cancel
    if contract.currentOwnerId ~= source and contract.newOwnerId ~= source then
        return false, locale('unauthorized_cancel')
    end
    
    contract:cancel(locale('contract_cancelled_by_participant'))
    return true
end)
