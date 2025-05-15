local QBCore = exports["qb-core"]:GetCoreObject()

local function getClosestVehicle()
	local vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), 4.0, true)
	return vehicle
end

local function getVehiclePlate(vehicle)
	local plate = GetVehicleNumberPlateText(vehicle)
	return plate
end

local function openUI(bool, data)
	if bool then
		SetNuiFocus(true, true)
		SendNUIMessage({
			action = "openUI",
			data = data
		})
	else
		SetNuiFocus(false, false)
		SendNUIMessage({
			action = "closeUI"
		})
	end
end

AddEventHandler("communityVehicle:client:openUI", function()
	local vehicle = getClosestVehicle()
	if vehicle then
		local plate = getVehiclePlate(vehicle)
		local getOwner = lib.callback.await("communityVehicle:server:getOwner", 1000, plate)
		if not getOwner then
			lib.notify({
				title = "No Vehicle Found",
				description = "You are not the owner of this vehicle.",
				type = "error"
			})
			return
		end
		openUI(true, getOwner)
	else
		lib.notify({
			title = "No Vehicle Found",
			description = "You are not near a vehicle.",
			type = "error"
		})
		return
	end
end)

AddEventHandler("communityVehicle:client:signNewOwner", function(data)
	openUI(true, data)
end)

RegisterNUICallback("closeUI", function(data, cb)
	openUI(false)
	cb("ok")
end)

RegisterNUICallback("signCurrentOwner", function(data, cb)
	TriggerServerEvent("communityVehicle:server:signCurrentOwner", data)
	cb("ok")
end)

RegisterNUICallback("signNewOwner", function(data, cb)
	local result = lib.callback("communityVehicle:server:signNewOwner", false, data)
	cb("ok")
end)
