local Database = {}

-- Detectar automáticamente qué framework está en uso
local function DetectFramework()
    if GetResourceState('es_extended') == 'started' then
        return 'es_extended'
    elseif GetResourceState('qbx_core') == 'started' then
        return 'qbx_core'
    elseif GetResourceState('qb-core') == 'started' then
        return 'qb_core'
    else
        error("No se detectó ningún framework compatible (es_extended, qb_core, qbx_core)")
    end
end

-- Cargar el módulo correspondiente según el framework detectado
local framework = DetectFramework()
local dbModule = require(('server.modules.database.%s'):format(framework))

-- API Unificada - Proxy hacia el módulo específico del framework
function Database.GetVehicleInformation(citizenid, plate)
    return dbModule.GetVehicleInformation(citizenid, plate)
end

function Database.GetAllVehicles(citizenid)
    return dbModule.GetAllVehicles(citizenid)
end

function Database.ChangeVehicleOwner(newCitizenId, plate)
    return dbModule.ChangeVehicleOwner(newCitizenId, plate)
end

function Database.GetPlayerData(identifier)
    return dbModule.GetPlayerData(identifier)
end

function Database.GetPlayerVehicles(identifier)
    return dbModule.GetPlayerVehicles(identifier)
end

-- Función para obtener información del framework actual
function Database.GetFramework()
    return framework
end

-- Información de debug
print(('[Database API] Framework detectado: %s'):format(framework))

return Database 