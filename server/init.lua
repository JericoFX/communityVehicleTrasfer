---@author JericoFX
---@version 0.1.0


--#region Class
---@class Contract
---@field source string The current owner's id (not in data table, passed separately)
---@field currentOwner string The current owner's name
---@field currentOwnerId string The current owner's ID
---@field currentOwnerName string The current owner's full name
---@field currentOwnerCitizenID string The current owner's citizen ID
---@field newOwner string The new owner's name
---@field newOwnerId string | number The new owner's ID
---@field newOwnerName string The new owner's full name
---@field newOwnerCitizenID string The new owner's citizen ID
---@field role string The role in the contract
---@field currenOwnerSign boolean Whether the current owner has signed
---@field newOwnerSign boolean Whether the new owner has signed
---@field vehicle table The vehicle information
---@field vehicle.brand string The vehicle's brand
---@field vehicle.model string The vehicle's model
---@field vehicle.plate string The vehicle's plate number
---@field vehicle.mileage number The vehicle's mileage
--#endregion



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

lib.callback.register(eventName("getVehicle"), function(source)
	return Framework:GetAllVehicles(source)
end)

--- This function is called when a player starts a new contract.
---@param source string
---@param data Contract
---@return boolean,string?
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
---@param source string
---@param data Contract
---@return boolean,string?
lib.callback.register(eventName("acceptContract"), function(source, data)
	if not currentContracts[data.currentOwnerId] then
		return false, "No contract found."
	end
	-- TODO Change the vehicle owner here
	TriggerClientEvent(eventName("acceptContract"), data.currentOwnerId, currentContracts[data.currentOwnerId])
	return true
end)
