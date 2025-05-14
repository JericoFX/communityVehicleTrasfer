local Bridge = exports.community_bridge:Bridge()
local currentContracts = {}


Bridge.Callback.Register("communityVehicleTransfer::server::setContractAsSigned",function(currentOwner,newOwner,signed,vehiclePlate)
 local Player = Bridge.GetPlayerById(currentOwner)
 local Target = Bridge.GetPlayerById(newOwner)
 if not Player or not Target then return false end
 local Vehicle = vehiclePlate
 local Item = Bridge.GetItem(source,"new_contract")
 if not Item then return false end
 currentContracts[Target] = {
 	currentOwner = currentOwner,
 	newOwner = newOwner,
 	signed = signed,
 	vehiclePlate = vehiclePlate,
 	mods = {}
 }

-- llenar los datos de la tabla con los colores
 TriggerClientEvent("communityVehicleTransfer::client::setClientContractData",target.source,currentContracts[Target])
end)

Bridge.Callback.Register("communityVehicleTransfer::server::finishContract",function ()
	
end)