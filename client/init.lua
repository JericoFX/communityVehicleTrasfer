lib.locale()
local NAME            = GetCurrentResourceName()
local currentContract = {}

local function openNUI(data, boolean)
    local contract = {}

    SetNuiFocus(boolean, boolean)
    SendNUIMessage({
        action = boolean and "open" or "close",
        data = {
            contract = data or nil,
            locale = config.language
        }
    })
end

local function newContract(_data)
    if IsNuiFocused() then
        return
    end
    local vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), 3.0, true)

    if not vehicle then
        lib.notify({
            title = "No vehicle found",
            description = "You need to be near a vehicle.",
            type = "error"
        })
        return
    end
    local temp = {

    }
    temp[cache.serverId] = {
        currentOwnerId = cache.serverId,
        newOwnerId = GetPlayerServerId(_data.entity),
        vehicle = vehicle,
        plate = GetVehicleNumberPlateText(vehicle),
    }
    local information, error = lib.callback.await(NAME .. "::server::startNewContract", false, temp)
    if not information then
        lib.notify({
            title = "Error",
            description = error,
            type = "error"
        })
        return
    end
    temp = {}
    openNUI(information, true)
end

local function setNewOwnerSign(data)
    openNUI(data, true)
end
--#region NUI Callbacks
RegisterNUICallback("close", function(data, cb)
    openNUI(nil, false)
    cb("ok")
end)

RegisterNUICallback("CurrentOwnerSigned", function(data, cb)
    local result = lib.callback.await(NAME .. "::server::currentOwnerSigned", false, data)
    openNUI(nil, false)
    cb("ok")
end)

RegisterNUICallback("NewOwnerSigned", function(data, cb)
    local result = lib.callback.await(NAME .. "::server::newOwnerSigned", false, data)
    if result then
        openNUI(nil, false)
    end
    cb("ok")
end)

RegisterNUICallback("cancel", function(data, cb)
    openNUI(nil, false)
    cb("ok")
end)

RegisterNUICallback("error", function(data, cb)
    --https://overextended.dev/ox_lib/Modules/Interface/Client/notify#libnotify
    lib.notify({
        title = "ERROR",
        description = data,
        type = 'error', --'inform' or 'error' or 'success'or 'warning'
        duration = 3000
    })
    cb("ok")
end)

--#endregion
RegisterNetEvent(NAME .. "::client::setNewOwnerSign", setNewOwnerSign)

CreateThread(function()
    exports.ox_target:addGlobalPed({
        name = 'vehicle_contract',
        icon = 'fa-solid fa-car-side',
        label = locale('toggle_front_driver_door'),
        distance = 2,
        canInteract = function(entity, distance, coords, name)
            return IsEntityAPed(entity) and not IsPedDeadOrDying(entity, true) and not IsPedInAnyVehicle(entity, false)
        end,
        onSelect = function(data)
            newContract(data)
        end
    })
end)
