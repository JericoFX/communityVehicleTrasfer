---@author JericoFX
---@version 1.0.0

-- Load configuration
lib.locale()

-- Local variables
local isUIOpen = false
local currentContract = nil

--- Open/Close NUI with proper state management
---@param data table|nil Contract data
---@param show boolean Whether to show or hide UI
local function toggleNUI(data, show)
    if show and isUIOpen or IsNuiFocused() then
        return -- Prevent multiple UI instances
    end

    isUIOpen = show
    SetNuiFocus(show, show)

    SendNUIMessage({
        action = show and "open" or "close",
        data = {
            contract = data or nil
        }
    })

    if show then
        currentContract = data
    else
        currentContract = nil
    end
end

--- Get the closest vehicle to the player
---@return number|nil vehicleEntity
---@return number|nil vehicleNetId
---@return string|nil plate
local function getClosestVehicle()
    local playerCoords = GetEntityCoords(cache.ped)
    local vehicle = lib.getClosestVehicle(playerCoords, Config.maxVehicleDistance, true)

    if not vehicle then
        return nil, nil, nil
    end

    local vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle)
    local plate = GetVehicleNumberPlateText(vehicle):gsub("%s+", "") -- Remove spaces

    return vehicle, vehicleNetId, plate
end

--- Start a new vehicle transfer contract
---@param targetData table Target player data from ox_target
local function startNewContract(targetData)
    if isUIOpen then
        lib.notify({
            title = locale('error'),
            description = locale('contract_open'),
            type = "error",
            duration = Config.notifications.duration,
            position = Config.notifications.position
        })
        return
    end

    local vehicle, vehicleNetId, plate = getClosestVehicle()

    if not vehicle then
        lib.notify({
            title = locale('no_vehicle_found'),
            description = locale('no_vehicle_found_desc'),
            type = "error",
            duration = Config.notifications.duration,
            position = Config.notifications.position
        })
        return
    end

    if Config.items.requireContractItem then
        local hasItem = lib.callback.await("orderVehicleTransfer::server::hasItem", false, Config.items.blankContract, 1)
        if not hasItem then
            lib.notify({
                title = locale('item_required'),
                description = locale('item_required_desc'),
                type = "error",
                duration = Config.notifications.duration,
                position = Config.notifications.position
            })
            return
        end
    end

    local contractData = {
        newOwnerId = GetPlayerServerId(targetData.entity),
        plate = plate,
        vehicleNetId = vehicleNetId
    }

    local result, error = lib.callback.await("orderVehicleTransfer::server::startNewContract", false, contractData)

    if not result then
        lib.notify({
            title = locale('error'),
            description = error or locale('error_creating_contract'),
            type = "error",
            duration = Config.notifications.duration,
            position = Config.notifications.position
        })
        return
    end

    toggleNUI(result, true)
end

--- Handle new owner signing UI
---@param contractData table Contract data from server
local function openNewOwnerSignUI(contractData)
    if isUIOpen then
        toggleNUI(nil, false)
        Wait(100)
    end

    toggleNUI(contractData, true)
end

RegisterNUICallback("close", function(data, cb)
    toggleNUI(nil, false)
    cb("ok")
end)

RegisterNUICallback("CurrentOwnerSigned", function(data, cb)
    if not currentContract then
        cb("error")
        return
    end

    local success, error = lib.callback.await("orderVehicleTransfer::server::currentOwnerSigned", false, currentContract)

    if success then
        toggleNUI(nil, false)
        lib.notify({
            title = locale('contract_signed'),
            description = locale('contract_signed_success'),
            type = "success",
            duration = Config.notifications.duration,
            position = Config.notifications.position
        })
    else
        lib.notify({
            title = locale('error'),
            description = error or locale('error_signing_contract'),
            type = "error",
            duration = Config.notifications.duration,
            position = Config.notifications.position
        })
    end

    cb("ok")
end)

RegisterNUICallback("NewOwnerSigned", function(data, cb)
    if not currentContract then
        cb("error")
        return
    end

    local success, error = lib.callback.await("orderVehicleTransfer::server::newOwnerSigned", false, currentContract)

    if success then
        toggleNUI(nil, false)
        lib.notify({
            title = locale('transfer_complete'),
            description = locale('transfer_complete_desc'),
            type = "success",
            duration = Config.notifications.duration,
            position = Config.notifications.position
        })
    else
        lib.notify({
            title = locale('error'),
            description = error or locale('error_completing_transfer'),
            type = "error",
            duration = Config.notifications.duration,
            position = Config.notifications.position
        })
    end

    cb("ok")
end)

RegisterNUICallback("cancel", function(data, cb)
    if currentContract then
        lib.callback.await("orderVehicleTransfer::server::cancelContract", false, currentContract)
    end

    toggleNUI(nil, false)
    cb("ok")
end)

RegisterNUICallback("error", function(data, cb)
    lib.notify({
        title = locale('error'),
        description = data or locale('unknown_error'),
        type = "error",
        duration = Config.notifications.duration,
        position = Config.notifications.position
    })
    cb("ok")
end)

RegisterNetEvent("orderVehicleTransfer::client::signNewOwner", openNewOwnerSignUI)

CreateThread(function()
    exports.ox_target:addGlobalPed({
        name = 'vehicle_transfer_contract',
        icon = 'fa-solid fa-file-contract',
        label = locale('vehicle_transfer'),
        distance = 2.5,
        canInteract = function(entity, distance, coords, name)
            if not IsEntityAPed(entity) then return false end
            if IsPedDeadOrDying(entity, true) then return false end
            if IsPedInAnyVehicle(entity, false) then return false end
            if entity == cache.ped then return false end
            local vehicle, _, _ = getClosestVehicle()
            if not vehicle then return false end
            local hasItem = lib.callback.await("orderVehicleTransfer::server::hasItem", false,
                Config.items.requireContractItem, 1)
            return hasItem
        end,
        onSelect = function(data)
            startNewContract(data)
        end
    })
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    if isUIOpen then
        toggleNUI(nil, false)
    end
end)
