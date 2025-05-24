local Contract = lib.class("Contract")
local Contracts = {}

function Contract:constructor(source, data)
    self.source = source
    self.data = data
    self.currentOwner = data.currentOwner
    self.currentOwnerId = data.currentOwnerId
    self.currentOwnerCitizenID = data.currentOwnerCitizenID
    self.newOwner = data.newOwner
    self.newOwnerId = data.newOwnerId
    self.newOwnerCitizenID = data.newOwnerCitizenID
    self.role = "currentOwner"
    self.currentOwnerSign = false
    self.newOwnerSign = false
    self.vehicle = data.vehicle
    Contracts[source] = self
end

function Contract:CurrentOwnerSigned()
    if not Contracts[self.source] then
        return false, "No contract found."
    end
    local contract = Contracts[self.source]
    contract.role = "newOwner"
    contract.currentOwnerSign = true
    TriggerClientEvent('ox_lib:notify', contract.currentOwnerId, {
        title = "Contract Accepted",
        description = "You have Signed the contract.",
        type = "success"
    })
    TriggerClientEvent("orderVehicleTransfer::client::signNewOwner", contract.newOwnerId, contract)
    return true
end

function Contract:NewOwnerSigned()
    if not Contracts[self.source] then
        return false, "No contract found."
    end
    local contract = Contracts[self.source]
    contract.role = "completed"
    contract.newOwnerSign = true
    TriggerClientEvent("orderVehicleTransfer::client::closeUI", contract.currentOwnerId, contract)
    return true
end

function Contract:Get(source)
    return Contracts[source]
end

function Contract:Delete(source)
    if not Contracts[source] then
        return false, "No contract found."
    end
    Contracts[source] = nil
    return true
end

return Contract
