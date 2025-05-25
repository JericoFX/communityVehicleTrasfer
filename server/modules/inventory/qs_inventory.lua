local Inventory = {}

-- QS_Inventory Adapter
-- Requiere: qs-inventory resource

function Inventory.AddItem(source, item, amount, metadata, slot)
    local success = exports['qs-inventory']:AddItem(source, item, amount or 1, slot, metadata)
    return success
end

function Inventory.RemoveItem(source, item, amount, slot)
    local success = exports['qs-inventory']:RemoveItem(source, item, amount or 1, slot)
    return success
end

function Inventory.HasItem(source, item, amount)
    local itemData = exports['qs-inventory']:GetItemTotalAmount(source, item)
    return itemData >= (amount or 1)
end

function Inventory.GetItemCount(source, item)
    return exports['qs-inventory']:GetItemTotalAmount(source, item) or 0
end

function Inventory.GetItem(source, item, metadata)
    return exports['qs-inventory']:GetItem(source, item, metadata)
end

function Inventory.GetInventory(source)
    return exports['qs-inventory']:GetInventory(source)
end

function Inventory.SetItemMetadata(source, item, slot, metadata)
    -- QS maneja metadata diferente, puede requerir remove/add
    local success = exports['qs-inventory']:SetItemMetadata(source, slot, metadata)
    return success or false
end

function Inventory.CanCarryItem(source, item, amount)
    return exports['qs-inventory']:CanCarryItem(source, item, amount or 1)
end

function Inventory.GetWeight(source)
    local inventory = exports['qs-inventory']:GetInventory(source)
    return inventory and inventory.weight or 0
end

function Inventory.GetMaxWeight(source)
    local inventory = exports['qs-inventory']:GetInventory(source)
    return inventory and inventory.maxweight or 0
end

-- Funciones específicas de QS_Inventory (extras)
function Inventory.GetFirstSlotByItem(source, item)
    return exports['qs-inventory']:GetFirstSlotByItem(source, item)
end

function Inventory.GetItemBySlot(source, slot)
    return exports['qs-inventory']:GetItemBySlot(source, slot)
end

function Inventory.GetSlotsByItem(source, item)
    return exports['qs-inventory']:GetSlotsByItem(source, item)
end

function Inventory.ClearInventory(source)
    return exports['qs-inventory']:ClearInventory(source)
end

function Inventory.SetInventory(source, items)
    return exports['qs-inventory']:SetInventory(source, items)
end

-- Funciones de stash/drop
function Inventory.CreateDrop(coords, slots, maxWeight, label, id)
    return exports['qs-inventory']:CreateDrop(coords, slots, maxWeight, label, id)
end

function Inventory.RemoveDrop(id)
    return exports['qs-inventory']:RemoveDrop(id)
end

function Inventory.CreateStash(id, label, slots, maxWeight, owner, groups, coords)
    return exports['qs-inventory']:CreateStash(id, label, slots, maxWeight, owner, groups, coords)
end

function Inventory.RemoveStash(id)
    return exports['qs-inventory']:RemoveStash(id)
end

-- Funciones de shops
function Inventory.CreateShop(data)
    return exports['qs-inventory']:CreateShop(data)
end

function Inventory.GetShops()
    return exports['qs-inventory']:GetShops()
end

-- Funciones de crafteo (si QS lo soporta)
function Inventory.CreateCraftingTable(data)
    return exports['qs-inventory']:CreateCraftingTable(data)
end

return Inventory 