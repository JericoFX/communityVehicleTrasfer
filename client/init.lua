local Bridge = exports.community_bridge.Bridge()

local function setEventName(name)
	return string.format("communityVehicleTransfer::%s::%s", not IsDuplicityVersion() and "server" or "client", name)
end

local function getClosestVehicle()
	local vehicle, vehicleCoords = lib.getClosestVehicle(GetEntityCoords(cache.ped), 5.0, true)
	return vehicle
end
local function getVehiclePlate()
	local vehicle = getClosestVehicle()
	if vehicle then
		return GetVehicleNumberPlateText(vehicle)
	end
	return nil
end

local function getVehicleOwner()
	local vehicle = getClosestVehicle()
	if not vehicle then
		lib.lib.notify({
			title = 'Vehicle Transfer',
			description = 'No vehicle found nearby.',
			type = 'error'
		})
		return nil
	end
	local isOwner = lib.callback.await(setEventName("getVehicleOwner"), false, getVehiclePlate())
	return isOwner
end

local function getClosestPlayer()
	local player, playerCoords = lib.getClosestPlayer(GetEntityCoords(cache.ped), 5.0, true)
	if player then
		return { player = player, GetPlayerServerId = GetPlayerServerId(player) }
	end
	return nil
end

--- This will open the UI if is true
---@param bool boolean open or close the UI
---@param data {currentOwner:string,newOwner:string, signed:boolean,vehiclePlate:string}
local function openUI(bool, data)
	SetNuiFocus(bool, bool)
	SendNUIMessage({
		action = bool and "openUI" or "closeUI",
		data = bool and data or nil
	})
end


local function setCurrentOwnerContractAsSigned(data, cb)
	local currentOwner, newOwner, signed, vehiclePlate = data.currentOwner, data.newOwner, data.signed, data
		.vehiclePlate
	Bridge.Callback.Trigger(setEventName("setContractAsSigned"), currentOwner, newOwner, signed, vehiclePlate)
	cb("ok")
end

local function updateItemMetadata(data, cb)

end

local function setNewOwnerContractAsSigned(data)
	--NEW OWNER ALREADY SIGNED SO IS SAFE TO TRANSFER THE VEHICLE TO THE OTHER OWNER
	local signed = data.signed
	Bridge.Callback.Trigger(setEventName("setNewOwnerContractAsSigned"), signed)
end

local function checkVehicleOwner(data, cb)
	local plate = data.plate
	local isValid = Bridge.Callback.Trigger(setEventName("checkVehicleOwner"), plate)
	cb(isValid)
end

RegisterNetEvent("communityVehicleTransfer::client::setClientContractData", function(data)
	openUI(true, data)
end)
