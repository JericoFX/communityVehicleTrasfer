lib.locale()
local NAME            = GetCurrentResourceName()
local currentContract = {}

local function openNUI(data, boolean)
    local contract = {}
    if data then
        contract = {
            currentOwnerId = data.currentOwnerId,
            newOwnerId = data.newOwnerId,
            vehicle = data.vehicle
        }
        currentContract = contract
        contract = nil
    end
    SetNuiFocus(boolean, boolean)
    SendNUIMessage({
        action = boolean and "open" or "close",
        data = {
            contract = currentContract or nil,
            locale = config.language
        }
    })
end

local function newContract(_data)
    local options = {}
    if IsNuiFocused() then
        return
    end
    local temp    = {
        currentOwnerId = cache.serverId,
        newOwnerId = GetPlayerServerId(_data.entity),
        role = "currentOwner"
    }
    local vehicle = lib.callback.await(NAME .. "::server::startNewContract", false, temp)
    if not next(vehicle) or not vehicle then
        lib.notify({
            title = "No vehicles found",
            description = "You don't have any vehicles.",
            type = "error"
        })
        return
    end
    for k, v in pairs(vehicle) do
        options[#options + 1] = {
            title = ("%s %s"):format(v.brand, v.model),
            description = locale("Plate: %s \n Mileage: %s \n Brand: %s \n Model: %s", v.plate, v.mileage, v.brand,
                v.model),
            icon = "fa car",
            args = {
                --añadir datos de los 2 jugadores
                id = v.id,
                vehicle = {
                    plate = v.plate,
                    mileage = v.mileage,
                    brand = v.brand,
                    model = v.model
                }
            },
            onSelect = function(data, cb)
                local _vehicle = data.args.vehicle
                currentContract = {
                    currentOwnerId = GetPlayerServerId(PlayerId()),
                    newOwnerId = GetPlayerServerId(_data.entity),
                    vehicle = _vehicle,
                    role = "currentOwner"
                }
                openNUI(currentContract, true)
            end
        }
    end
    lib.registerContext({
        id = "_Vehicle_Contract_",
        title = "Vehicle Contract",
        options = options
    })
    lib.showContext("_Vehicle_Contract_")
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
