local Bridge = exports.community_bridge:Bridge()

Bridge.Callback.Register("communityVehicleTransfer::server::setContractAsSigned",function(currentOwner,newOwner,signed,vehiclePlate)
 local Player = Bridge.GetPlayerById(currentOwner)
 local Target = Bridge.GetPlayerById(newOwner)
 if not Player or not Target then return false end
 local Vehicle = vehiclePlate
 local Item = Bridge.GetItem(source,"new_contract")
 if not Item then return false end
 TriggerClientEvent("communityVehicleTransfer::client::setContractAsSigned",)
end)