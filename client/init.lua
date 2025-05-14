local Bridge = exports.community_bridge.Bridge()

local function setEventName(name)
return string.format("communityVehicleTransfer::%s::%s",not IsDuplicityVersion() and "server" or "client",name)
end

local function getItemMetadata()

end

--- This will open the UI if is true
---@param bool boolean open or close the UI
---@param data {currentOwner:string,newOwner:string, signed:boolean,vehiclePlate:string}
local function openUI(bool,data)
	SetNuiFocus(bool,bool)
	SendNUIMessage({
		action = bool and "openUI" or "closeUI",
		data = bool and data or nil
	})
end


local function setCurrentOwnerContractAsSigned(data,cb)
	local currentOwner, newOwner, signed, vehiclePlate = data.currentOwner,data.newOwner,data.signed,data.vehiclePlate
	Bridge.Callback.Trigger(setEventName("setContractAsSigned"),currentOwner,newOwner,signed,vehiclePlate)
	cb("ok")
end

local function updateItemMetadata(data,cb)

end

local function setNewOwnerContractAsSigned(data)
	--NEW OWNER ALREADY SIGNED SO IS SAFE TO TRANSFER THE VEHICLE TO THE OTHER OWNER
	local signed = data.signed
	Bridge.Callback.Trigger(setEventName("setNewOwnerContractAsSigned"),signed)
end

local function checkVehicleOwner(data,cb) 
	local plate = data.plate
	local isValid = Bridge.Callback.Trigger(setEventName("checkVehicleOwner"),plate)
	cb(isValid)
end

RegisterNetEvent("communityVehicleTransfer::client::setClientContractData",function(data)
	openUI(true,data)
end)

