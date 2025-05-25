local Core = {}

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
local coreModule = require(('server.modules.cores.%s'):format(framework))

-- API Unificada - Proxy hacia el módulo específico del framework

-- Funciones de Jugador
function Core.GetPlayerInformation(source)
    return coreModule:GetPlayerInformation(source)
end

function Core.GetPlayer(source)
    return coreModule:GetPlayer(source)
end

-- Funciones de Vehículo
function Core.GetVehicleInformation(identifier, plate)
    return coreModule:GetVehicleInformation(identifier, plate)
end

function Core.ChangeVehicleOwner(newOwnerId, plate)
    return coreModule:ChangeVehicleOwner(newOwnerId, plate)
end

-- Funciones de Inventario (ahora integradas automáticamente)
function Core.AddItem(source, item, amount, metadata, slot)
    return coreModule:AddItem(source, item, amount, metadata, slot)
end

function Core.RemoveItem(source, item, amount, slot)
    return coreModule:RemoveItem(source, item, amount, slot)
end

function Core.HasItem(source, item, amount)
    return coreModule:HasItem(source, item, amount)
end





-- Funciones de Utilidad
function Core.GetFramework()
    return framework
end



-- Información de debug
print(('[Core API] Framework detectado: %s'):format(framework))
print(('[Core API] Inventario integrado automáticamente'))

return Core 