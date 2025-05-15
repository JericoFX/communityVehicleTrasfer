local QBCore = exports["qb-core"]:GetCoreObject()
local currentContracts = {}

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
			newOwner = data.newOwner,
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
