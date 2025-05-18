local Framework = GetResourceState('qb-core') == "started" and require "server.modules.qb_core" or
	GetResourceState('es_extended') == "started" and require "server.modules.es_extended" or nil
local currentContracts = {}

if not Framework then
	print("Framework not found, please check if you have qb-core or es_extended installed.")
	return
end
