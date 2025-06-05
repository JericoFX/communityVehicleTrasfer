-- ============================================================================
-- ITEMS EXAMPLE FOR QBCORE
-- ============================================================================
-- Add these items to your qb-core/shared/items.lua file

['vehicle_contract_blank'] = {
    ['name'] = 'vehicle_contract_blank',
    ['label'] = 'Contrato de Vehículo (Vacío)',
    ['weight'] = 100,
    ['type'] = 'item',
    ['image'] = 'contract_blank.png',
    ['unique'] = false,
    ['useable'] = false,
    ['shouldClose'] = false,
    ['combinable'] = nil,
    ['description'] = 'Un contrato en blanco para transferir vehículos entre jugadores'
},

['vehicle_contract_signed'] = {
    ['name'] = 'vehicle_contract_signed',
    ['label'] = 'Contrato de Vehículo (Firmado)',
    ['weight'] = 100,
    ['type'] = 'item',
    ['image'] = 'contract_signed.png',
    ['unique'] = true,
    ['useable'] = false,
    ['shouldClose'] = false,
    ['combinable'] = nil,
    ['description'] = 'Un contrato de transferencia de vehículo firmado por ambas partes'
},

-- ============================================================================
-- ITEMS EXAMPLE FOR ESX
-- ============================================================================
-- Add these items to your es_extended/shared/items.lua file or your database

INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
('vehicle_contract_blank', 'Contrato de Vehículo (Vacío)', 1, 0, 1),
('vehicle_contract_signed', 'Contrato de Vehículo (Firmado)', 1, 0, 1);

-- ============================================================================
-- IMAGES
-- ============================================================================
-- You'll need to add these images to your inventory resource:
-- - contract_blank.png (for blank contracts)
-- - contract_signed.png (for signed contracts)
-- 
-- Recommended size: 64x64 pixels
-- Place them in your inventory resource's images folder
-- (e.g., qb-inventory/html/images/ or ox_inventory/web/images/)

-- ============================================================================
-- SHOP CONFIGURATION (OPTIONAL)
-- ============================================================================
-- If you want to sell blank contracts in shops, add this to your shop config:

-- For QBCore shops:
['vehicle_contract_blank'] = {
    name = 'vehicle_contract_blank',
    price = 50,
    amount = 10,
    info = {},
    type = 'item',
    slot = 1,
},

-- For ESX shops:
{
    item = 'vehicle_contract_blank',
    label = 'Contrato de Vehículo (Vacío)',
    price = 50
} 