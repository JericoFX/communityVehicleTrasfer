local Contract = lib.class("Contract")
local AntiExploit = require "server.modules.security.AntiExploit"

-- Load locale for localization
lib.locale()

-- Active contracts storage
local Contracts = {}
local antiExploit = AntiExploit:new()

-- Contract timeout management
local contractTimers = {}

function Contract:constructor(sourceId, contractData)
    -- Validate input data
    local isValid, error = antiExploit:validateContract(contractData)
    if not isValid then
        return nil, error
    end

    -- Security validations
    if not antiExploit:checkRateLimit(sourceId) then
        return nil, "Rate limit exceeded. Please wait before creating another contract."
    end

    if not antiExploit:validateBothPlayersOnline(contractData.currentOwnerId, contractData.newOwnerId) then
        return nil, "Both players must be online to create a contract."
    end

    if not antiExploit:preventSelfTransfer(contractData.currentOwnerId, contractData.newOwnerId) then
        return nil, "Cannot transfer vehicle to yourself."
    end

    if not antiExploit:validatePlayerDistance(contractData.currentOwnerId, contractData.newOwnerId) then
        return nil, "Players are too far apart for vehicle transfer."
    end

    if not antiExploit:validateVehicleOwnership(contractData.currentOwnerCitizenID, contractData.vehicle.plate) then
        return nil, "Vehicle ownership verification failed."
    end

    -- Initialize contract
    self.id = self:generateContractId()
    self.sourceId = sourceId
    self.createdAt = os.time()
    self.status = "pending_current_owner" -- pending_current_owner, pending_new_owner, completed, cancelled, expired

    -- Contract parties
    self.currentOwner = contractData.currentOwner
    self.currentOwnerId = contractData.currentOwnerId
    self.currentOwnerCitizenID = contractData.currentOwnerCitizenID
    self.newOwner = contractData.newOwner
    self.newOwnerId = contractData.newOwnerId
    self.newOwnerCitizenID = contractData.newOwnerCitizenID

    -- Signatures
    self.currentOwnerSigned = false
    self.newOwnerSigned = false
    self.currentOwnerSignedAt = nil
    self.newOwnerSignedAt = nil

    -- Vehicle information
    self.vehicle = contractData.vehicle
    self.vehicleNetId = contractData.vehicleNetId

    -- Security data
    self.securityHash = self:generateSecurityHash()
    self.lastModified = os.time()

    -- Store contract
    Contracts[self.id] = self

    -- Set timeout timer
    self:setTimeoutTimer()

    return self
end

function Contract:generateContractId()
    return ("%s-%s-%d"):format(
        self.currentOwnerCitizenID or "unknown",
        self.newOwnerCitizenID or "unknown",
        os.time()
    )
end

function Contract:generateSecurityHash()
    local dataToHash = table.concat({
        self.currentOwnerCitizenID,
        self.newOwnerCitizenID,
        self.vehicle.plate,
        tostring(self.createdAt)
    }, "|")

    local hash = 0
    for i = 1, #dataToHash do
        hash = hash + string.byte(dataToHash, i)
    end
    return tostring(hash)
end

function Contract:setTimeoutTimer()
    contractTimers[self.id] = SetTimeout(Config.contractTimeout, function()
        self:expire()
    end)
end

function Contract:clearTimeoutTimer()
    if contractTimers[self.id] then
        clearTimeout(contractTimers[self.id])
        contractTimers[self.id] = nil
    end
end

function Contract:validateSecurityHash()
    local currentHash = self:generateSecurityHash()
    return self.securityHash == currentHash
end

function Contract:getCurrentOwnerSign()
    -- Security validations
    if self.status ~= "pending_current_owner" then
        return false, "Contract is not in the correct state for current owner signing."
    end

    if not self:validateSecurityHash() then
        antiExploit:logSuspiciousActivity(self.currentOwnerId, "CONTRACT_HASH_MISMATCH", {
            contractId = self.id,
            expectedHash = self.securityHash
        })
        return false, "Contract security validation failed."
    end

    if not antiExploit:validateVehicleDistance(self.currentOwnerId, self.vehicleNetId) then
        return false, "You must be near the vehicle to sign the contract."
    end

    -- Process signature
    self.currentOwnerSigned = true
    self.currentOwnerSignedAt = os.time()
    self.status = "pending_new_owner"
    self.lastModified = os.time()

    -- Notify current owner
    TriggerClientEvent('ox_lib:notify', self.currentOwnerId, {
        title = locale('contract_signed'),
        description = locale('contract_signed_desc'),
        type = "success",
        duration = Config.notifications.duration,
        position = Config.notifications.position
    })

    -- Send contract to new owner
    TriggerClientEvent("orderVehicleTransfer::client::signNewOwner", self.newOwnerId, self:getClientData())

    -- Remove contract item if configured
    if Config.items.removeContractOnUse then
        Framework:RemoveItem(self.currentOwnerId, Config.items.blankContract, 1)
    end

    return true
end

function Contract:getNewOwnerSign()
    -- Security validations
    if self.status ~= "pending_new_owner" then
        return false, "Contract is not in the correct state for new owner signing."
    end

    if not self.currentOwnerSigned then
        return false, "Current owner must sign first."
    end

    if not self:validateSecurityHash() then
        antiExploit:logSuspiciousActivity(self.newOwnerId, "CONTRACT_HASH_MISMATCH", {
            contractId = self.id,
            expectedHash = self.securityHash
        })
        return false, "Contract security validation failed."
    end

    if not antiExploit:validatePlayerDistance(self.currentOwnerId, self.newOwnerId) then
        return false, "Players are too far apart to complete the transfer."
    end

    -- Process signature
    self.newOwnerSigned = true
    self.newOwnerSignedAt = os.time()
    self.status = "completed"
    self.lastModified = os.time()

    -- Execute vehicle transfer
    local success, error = self:executeVehicleTransfer()
    if not success then
        self.status = "failed"
        return false, error
    end

    -- Give signed contracts to both parties
    if Config.items.giveSignedContract then
        Framework:AddItem(self.currentOwnerId, Config.items.signedContract, 1, {
            contractId = self.id,
            role = "previous_owner",
            vehicle = self.vehicle.plate,
            plate = self.vehicle.plate,
            newOwner = self.newOwner,
            newOwnerCitizenID = self.newOwnerCitizenID,
            oldOwner = self.currentOwner,
            oldOwnerCitizenID = self.currentOwnerCitizenID,
            transferredTo = self.newOwner,
            date = os.date("%Y-%m-%d %H:%M:%S")
        })

        Framework:AddItem(self.newOwnerId, Config.items.signedContract, 1, {
            contractId = self.id,
            role = "new_owner",
            vehicle = self.vehicle.plate,
            plate = self.vehicle.plate,
            newOwner = self.newOwner,
            newOwnerCitizenID = self.newOwnerCitizenID,
            oldOwner = self.currentOwner,
            oldOwnerCitizenID = self.currentOwnerCitizenID,
            transferredFrom = self.currentOwner,
            date = os.date("%Y-%m-%d %H:%M:%S")
        })
    end

    -- Notify both parties
    self:notifyTransferComplete()

    -- Clean up
    self:cleanup()

    return true
end

function Contract:executeVehicleTransfer()
    local success = Framework:ChangeVehicleOwner(self.newOwnerCitizenID, self.vehicle.plate)
    if not success then
        antiExploit:logSuspiciousActivity(self.currentOwnerId, "VEHICLE_TRANSFER_FAILED", {
            contractId = self.id,
            plate = self.vehicle.plate,
            newOwnerCitizenId = self.newOwnerCitizenID
        })
        return false, "Failed to transfer vehicle ownership in database."
    end

    return true
end

function Contract:notifyTransferComplete()
    local notificationData = {
        title = locale('transfer_complete'),
        type = "success",
        duration = Config.notifications.duration,
        position = Config.notifications.position
    }

    -- Notify current owner
    TriggerClientEvent('ox_lib:notify', self.currentOwnerId, lib.table.merge(notificationData, {
        description = locale('transfer_complete_current_owner'):format(
            self.vehicle.plate, self.newOwner
        )
    }))

    -- Notify new owner
    TriggerClientEvent('ox_lib:notify', self.newOwnerId, lib.table.merge(notificationData, {
        description = locale('transfer_complete_new_owner'):format(
            self.vehicle.plate
        )
    }))
end

function Contract:cancel(reason)
    self.status = "cancelled"
    self.lastModified = os.time()

    -- Notify parties
    local notificationData = {
        title = locale('contract_cancelled'),
        description = reason or locale('contract_cancelled_desc'),
        type = "error",
        duration = Config.notifications.duration,
        position = Config.notifications.position
    }

    TriggerClientEvent('ox_lib:notify', self.currentOwnerId, notificationData)
    TriggerClientEvent('ox_lib:notify', self.newOwnerId, notificationData)

    self:cleanup()
end

function Contract:expire()
    self.status = "expired"
    self.lastModified = os.time()

    -- Notify parties
    local notificationData = {
        title = locale('contract_expired'),
        description = locale('contract_expired_desc'),
        type = "warning",
        duration = Config.notifications.duration,
        position = Config.notifications.position
    }

    TriggerClientEvent('ox_lib:notify', self.currentOwnerId, notificationData)
    TriggerClientEvent('ox_lib:notify', self.newOwnerId, notificationData)

    self:cleanup()
end

function Contract:cleanup()
    self:clearTimeoutTimer()
    Contracts[self.id] = nil
end

function Contract:getClientData()
    return {
        id = self.id,
        currentOwner = self.currentOwner,
        currentOwnerId = self.currentOwnerId,
        currentOwnerCitizenID = self.currentOwnerCitizenID,
        newOwner = self.newOwner,
        newOwnerId = self.newOwnerId,
        newOwnerCitizenID = self.newOwnerCitizenID,
        vehicle = self.vehicle,
        currentOwnerSigned = self.currentOwnerSigned,
        newOwnerSigned = self.newOwnerSigned,
        status = self.status,
        role = self.status == "pending_current_owner" and "currentOwner" or "newOwner"
    }
end

-- Static methods
function Contract.GetById(contractId)
    return Contracts[contractId]
end

function Contract.GetActiveContracts()
    return Contracts
end

function Contract.CleanupExpiredContracts()
    local currentTime = os.time()
    for id, contract in pairs(Contracts) do
        if currentTime - contract.createdAt > (Config.contractTimeout / 1000) then
            contract:expire()
        end
    end
end

-- Cleanup expired contracts every 5 minutes
CreateThread(function()
    while true do
        Wait(300000) -- 5 minutes
        Contract.CleanupExpiredContracts()
    end
end)

return Contract
