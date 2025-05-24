---@author JericoFX
---@version 0.1.0
local function LoadFramework()
    local hasQBCore = GetResourceState('qb-core') == "started"
    -- local hasQBXCore = GetResourceState('qbx_core') == "started"
    -- local hasESExtended = GetResourceState('es_extended') == "started"

    -- -- Si qbx_core está activo y qb-core NO está activo, es qbx_core
    -- if hasQBXCore and not hasQBCore then
    --     return require "server.modules.qbx_core"
    -- elseif hasQBCore then
    --     return require "server.modules.qb_core"
    -- elseif hasESExtended then
    --     return require "server.modules.es_extended"
    -- else
    --     return nil
    -- end
    return require "server.modules.qb_core"
end

local Contract = require "server.modules.contract.contract"

Framework = LoadFramework()
local currentContracts = {}



if not Framework then
    print("Framework not found, please check if you have qb-core,qbx_core or es_extended installed.")
    return
end

lib.callback.register("orderVehicleTransfer::server::getVehicle", function(source)
    return Framework:GetAllVehicles(source)
end)

--- This function is called when a player starts a new contract.
---@param source string
---@param data table
---@return boolean,string?
lib.callback.register("orderVehicleTransfer::server::startNewContract", function(source, data)
    local Player, Target = Framework:GetPlayer(source), Framework:GetPlayer(data.newOwnerId)
    if not Player or not Target then
        return false, "Player not found."
    end
    local checkVehicleForPlate = Framework:GetVehicleInformation(Player.PlayerData.citizenid, data.plate)
    if not checkVehicleForPlate then
        return false, "Vehicle not found."
    end
    currentContracts[source] = Contract:New(source, {
        currentOwner = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname,
        currentOwnerId = Player.PlayerData.source,
        currentOwnerCitizenID = Player.PlayerData.citizenid,
        newOwner = Target.PlayerData.charinfo.firstname .. " " .. Target.PlayerData.charinfo.lastname,
        newOwnerId = Target.PlayerData.source,
        newOwnerCitizenID = Target.PlayerData.citizenid,
        role = "currentOwner",
        currenOwnerSign = false,
        newOwnerSign = false,
        vehicle = checkVehicleForPlate
    })
    return currentContracts[source]
end)


lib.callback.register("orderVehicleTransfer::server::currentOwnerSigned", function(source, data)
    if not currentContracts[source] then
        return false, "No contract found."
    end
    local contract = currentContracts[source]
    contract:CurrentOwnerSigned()
    return contract
end)

---Function Called with the new owner accepts the contract
---@param source string
---@param data table
---@return boolean,string?
lib.callback.register("orderVehicleTransfer::server::newOwnerSigned", function(source, data)
    local contract = currentContracts[data.currentOwnerId]
    if not ValidateContract(contract, data) then
        return false, GetValidationError(contract, data)
    end

    local success = Framework:ChangeVehicleOwner(contract.newOwnerCitizenID, contract.vehicle.plate)
    if not success then
        return false, "Failed to change vehicle owner."
    end

    NotifyParties(contract, success)

    contract:Delete(data.currentOwnerId)
    currentContracts[data.currentOwnerId] = nil
    contract = nil

    return true
end)

-- Helper functions
function ValidateContract(contract, data)
    if not contract then return false end
    if not contract.newOwnerSign then return false end
    if contract.role ~= "newOwner" then return false end
    if contract.currentOwnerCitizenID ~= data.currentOwnerCitizenID then return false end
    if contract.newOwnerCitizenID ~= data.newOwnerCitizenID then return false end
    if contract.vehicle.plate ~= data.vehicle.plate then return false end
    if not contract:NewOwnerSigned() then return false end
    return true
end

function GetValidationError(contract, data)
    if not contract then return "No contract found." end
    if not contract.newOwnerSign then return "New owner has not signed the contract yet." end
    if contract.role ~= "newOwner" then return "You are not the new owner." end
    if contract.currentOwnerCitizenID ~= data.currentOwnerCitizenID then
        return
        "Current owner citizen ID does not match."
    end
    if contract.newOwnerCitizenID ~= data.newOwnerCitizenID then return "New owner citizen ID does not match." end
    if contract.vehicle.plate ~= data.vehicle.plate then return "Vehicle plate does not match." end
    if not contract:NewOwnerSigned() then return "New owner has not signed the contract." end
    return "Unknown error occurred."
end

function NotifyParties(contract, success)
    if success then
        NotifySuccess(contract)
    else
        NotifyError(contract)
        print('Transfer failed.')
    end
end

function NotifySuccess(contract)
    TriggerClientEvent('ox_lib:notify', contract.currentOwnerId, {
        title = "Contract Accepted",
        description = "The new owner has accepted the contract.",
        type = 'success',
        duration = 3000
    })

    TriggerClientEvent('ox_lib:notify', contract.newOwnerId, {
        title = "Contract Accepted",
        description = "You are now the owner of the vehicle.",
        type = 'success',
        duration = 3000
    })
end

function NotifyError(contract)
    TriggerClientEvent('ox_lib:notify', contract.currentOwnerId, {
        title = "Contract Error",
        description = "The new owner has not accepted the contract.",
        type = 'error',
        duration = 3000
    })
end
