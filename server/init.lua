local Framework = GetResourceState('qb-core') == "started" and require "server.modules.qb_core" or
	GetResourceState('es_extended') == "started" and require "server.modules.es_extended" or nil
local currentContracts = {}
local NAME = ("%s::%s"):format(GetCurrentResourceName(), IsDuplicityVersion() and "server" or "client")

local function eventName(name)
	return ("%s:%s"):format(NAME, name)
end
if not Framework then
	print("Framework not found, please check if you have qb-core or es_extended installed.")
	return
end


lib.callback.register(eventName("getContracts"), function()
	return currentContracts
end)

--- This function is called when a player starts a new contract.
--- @param source any
--- @param data {currentOwner:string,currentOwnerId:string,currentOwnerName:string,currentOwnerCitizenID:string,newOwner:string,newOwnerId:string,newOwnerName:string,newOwnerCitizenID:string,role:string,currenOwnerSign:boolean,newOwnerSign:boolean,vehicle:{brand:string,model:string,plate:string,mileage:number}} -- OwnerID is the source
lib.callback.register(eventName("startNewContract"), function(source, data)
	--- Check the players here and the vehicle info
	if currentContracts[source] then
		return false, "You already have a contract."
	end
	currentContracts[source] = data
	currentContracts[source].role = "currentOwner"
	TriggerClientEvent(eventName("startNewContract"), data.newOwnerId, currentContracts[source])
	return true
end)

---Function Called with the new owner accepts the contract
---@param source any
---@param data {currentOwner:string,currentOwnerId:string,currentOwnerName:string,currentOwnerCitizenID:string,newOwner:string,newOwnerId:string,newOwnerName:string,newOwnerCitizenID:string,role:string,currenOwnerSign:boolean,newOwnerSign:boolean,vehicle:{brand:string,model:string,plate:string,mileage:number}} -- OwnerID is the source
---@return boolean, string?
lib.callback.register(eventName("acceptContract"), function(source, data)
	if not currentContracts[data.currentOwnerId] then
		return false, "No contract found."
	end
-- TODO Change the vehicle owner here
	TriggerClientEvent(eventName("acceptContract"), data.currentOwnerId, currentContracts[data.currentOwnerId])
	return true
end)
