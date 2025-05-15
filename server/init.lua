local QBCore = exports["qb-core"]:GetCoreObject()
local currentContracts = {}

local function getVehicleMetadata(owner, plate)
	local Player = QBCore.Functions.GetPlayer(owner)
	if not Player then return end
	local vehicle = Mysql.single.await(
		"SELECT vehicle, JSON_EXTRACT(mods,'$.color1') as color1, JSON_EXTRACT(mods,'$.color2') as color2 FROM player_vehicles WHERE citizenid = ? AND plate = ?",
		{ Player.PlayerData.citizenid, plate })
	if vehicle then
		local color1 = vehicle.color1 and json.decode(vehicle.color1) or nil
		local color2 = vehicle.color2 and json.decode(vehicle.color2) or nil
		local veh = vehicle.vehicle
		return {
			color1 = color1,
			color2 = color2,
			vehicle = veh
		}
	end
end

lib.callback.register("communityVehicleTransfer::server::getCurrentContracts", function()
	return currentContracts
end)

lib.callback.register("communityVehicleTransfer::server::setNewOwnerContractAsSigned", function(source, data)
	if data.signed then
		local Player = QBCore.Functions.GetPlayer(source)
		local newOwner = QBCore.Functions.GetPlayerByCitizenId(data.newOwner)
		if not Player or not newOwner then
			return false
		end
		currentContracts[data.newOwner] = {
			currentOwner = data.currentOwner,
			ownerServerId = source,
			newOwner = data.newOwner,
			newOwnerServerId = newOwner.PlayerData.source,
			currentOwnerSigned = data.currentOwnerSigned,
			newOwnerSigned = false,
			vehiclePlate = data.vehiclePlate,
			mods = {}
		}
		TriggerClientEvent("communityVehicleTransfer::client::setClientContractData", newOwner.PlayerData.source,
			currentContracts[data.newOwner])
		return true
	end
	return false
end)
