-- Sistema de inventarios unificado
-- Este archivo se carga automáticamente en cada core

-- Configuración de inventarios disponibles y prioridad de detección
local INVENTORY_SYSTEMS = {
    { name = 'ox_inventory', resource = 'ox_inventory' },
    { name = 'qs_inventory', resource = 'qs-inventory' },
    { name = 'qb_inventory', resource = 'qb-inventory' },
    { name = 'core_inventory', resource = 'core_inventory' },
    { name = 'default', resource = nil } -- Fallback al framework
}

-- Configuración manual (opcional) - puedes forzar un inventario específico
local FORCE_INVENTORY = nil -- Cambiar a 'ox_inventory', 'qs_inventory', etc. para forzar

-- Detectar automáticamente qué sistema de inventario está en uso
local function DetectInventorySystem()
    -- Si hay configuración forzada, usarla
    if FORCE_INVENTORY then
        print(('[Inventory] Sistema forzado: %s'):format(FORCE_INVENTORY))
        return FORCE_INVENTORY
    end
    
    -- Detectar automáticamente basado en recursos activos
    for _, system in ipairs(INVENTORY_SYSTEMS) do
        if system.resource == nil then
            -- Sistema por defecto (framework)
            return system.name
        elseif GetResourceState(system.resource) == 'started' then
            print(('[Inventory] Sistema detectado: %s'):format(system.name))
            return system.name
        end
    end
    
    -- Fallback al sistema por defecto
    print('[Inventory] No se detectó sistema específico, usando default')
    return 'default'
end

-- Cargar el módulo correspondiente según el inventario detectado
local inventorySystem = DetectInventorySystem()
local inventoryModule = require(('server.modules.inventory.%s'):format(inventorySystem))

-- Información de debug
print(('[Inventory] Sistema cargado: %s'):format(inventorySystem))

-- Retornar el módulo cargado
return inventoryModule 