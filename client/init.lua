local NAME = ("%s::%s"):format(GetCurrentResourceName(), not IsDuplicityVersion() and "server" or "client")

local function eventName(name)
    return ("%s:%s"):format(NAME, name)
end

local function startNewContract(data)
    local _data = next(data) --[[data]] --[[@as Contract]]
end

RegisterCommand("contract", function(source, args, rawCommand)
    local options = {}
    if IsNuiFocused() then
        return
    end
    local vehicle = lib.callback.await(eventName("getVehicle"), false)
    if not vehicle then
        return
    end
    if next(vehicle) == nil then
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
            description = ("Plate: %s \n Mileage: %s \n Brand: %s \n Model: %s"):format(v.plate, v.mileage, v.brand, v.model),
            icon = "fa car",
            args = {
                id = v.id,
                plate = v.plate,
                mileage = v.mileage,
                brand = v.brand,
                model = v.model
            },
            onSelect = function(data, cb)
                local vehicle = data.args
                
            end
        }
    end
    lib.registerContext({
        id = "_Vehicle_Contract_",
        title = "Vehicle Contract",
        options = options
    })
    lib.showContext("_Vehicle_Contract_")
end, false)



RegisterNetEvent(eventName("startNewContract"), startNewContract)
