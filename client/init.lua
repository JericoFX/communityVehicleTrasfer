local Bridge = exports.community_bridge.Bridge()

local function setEventName(name)
	return string.format("communityVehicleTransfer::%s::%s", not IsDuplicityVersion() and "server" or "client", name)
end

local function getItemMetadata()

end

--- This will open the UI if is true
---@param bool boolean open or close the UI
---@param data {currentOwner:string,newOwner:string, signed:boolean,vehiclePlate:string} | nil
local function openUI(bool, data)
	if IsNuiFocused() then return end
	SetNuiFocus(bool, bool)
	SendNUIMessage({
		action = bool and "openUI" or "closeUI",
		data = bool and data or nil
	})
end
local function checkVehicleOwner(data)
	local plate = data.plate
	local isValid = lib.callback.await("communityVehicleTransfer::server::checkVehicleOwner", false, data.plate)
	return isValid
end

local function setCurrentOwnerContractAsSigned(data, cb)
	local currentOwner, newOwner, signed, vehiclePlate = data.currentOwner, data.newOwner, data.signed, data
		.vehiclePlate
	local isVehicleFromPlayer = checkVehicleOwner(data)
	if not isVehicleFromPlayer then
		lib.notify({
			title = 'Vehicle Transfer',
			description = 'You are not the owner of this vehicle',
			type = 'error'
		})
		return
	end
	if signed then
		local isSuccess = lib.callback.await("communityVehicleTransfer::server::setNewOwnerContractAsSigned", false, data)
		if isSuccess then
			lib.notify({
				title = 'Vehicle Transfer',
				description = 'You have successfully signed the contract',
				type = 'success'
			})
			openUI(false, nil)
		else
			lib.notify({
				title = 'Vehicle Transfer',
				description = 'You have not signed the contract',
				type = 'error'
			})
		end
	end
	cb("ok")
end


local function setNewOwnerContractAsSigned(data, cb)
	local signed = data.currentOwnerSigned and not data.newOwnerSigned

	local isSuccess = lib.callback.await("communityVehicleTransfer::server::setNewOwnerContractAsSigned", false, data)
	if isSuccess then
		lib.notify({
			title = 'Vehicle Transfer',
			description = 'You have successfully signed the contract',
			type = 'success'
		})
	end
end



RegisterNetEvent("communityVehicleTransfer::client::setClientContractData", function(data)
	openUI(true, data)
end)

RegisterNUICallback("newOwnerSigned", setNewOwnerContractAsSigned)
RegisterNUICallback("currentOwnerSigned", setCurrentOwnerContractAsSigned)
