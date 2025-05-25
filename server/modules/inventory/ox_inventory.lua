local Inventory = {}

-- OX_Inventory Adapter
-- Requiere: ox_inventory resource

function Inventory.AddItem(source, item, amount, metadata, slot)
    local success = exports.ox_inventory:AddItem(source, item, amount or 1, metadata, slot)
    return success and true or false
end

function Inventory.RemoveItem(source, item, amount, slot)
    local success = exports.ox_inventory:RemoveItem(source, item, amount or 1, metadata, slot)
    return success and true or false
end

function Inventory.HasItem(source, item, amount)
    local itemData = exports.ox_inventory:GetItem(source, item, metadata, true)
    if not itemData then return false end
    return itemData.count >= (amount or 1)
end

function Inventory.GetItemCount(source, item)
    local itemData = exports.ox_inventory:GetItem(source, item, metadata, true)
    return itemData and itemData.count or 0
end

function Inventory.GetItem(source, item, metadata)
    return exports.ox_inventory:GetItem(source, item, metadata, true)
end

function Inventory.GetInventory(source)
    return exports.ox_inventory:GetInventory(source, false)
end

function Inventory.SetItemMetadata(source, item, slot, metadata)
    return exports.ox_inventory:SetMetadata(source, slot, metadata)
end

function Inventory.CanCarryItem(source, item, amount)
    return exports.ox_inventory:CanCarryItem(source, item, amount or 1)
end

function Inventory.GetWeight(source)
    local inventory = exports.ox_inventory:GetInventory(source, false)
    return inventory and inventory.weight or 0
end

function Inventory.GetMaxWeight(source)
    local inventory = exports.ox_inventory:GetInventory(source, false)
    return inventory and inventory.maxWeight or 0
end

-- Funciones específicas de OX_Inventory (extras)
function Inventory.Search(source, search, items)
    return exports.ox_inventory:Search(source, search, items)
end

function Inventory.ConfiscateInventory(source)
    return exports.ox_inventory:ConfiscateInventory(source)
end

function Inventory.ReturnInventory(source)
    return exports.ox_inventory:ReturnInventory(source)
end

function Inventory.ClearInventory(source, filterItems)
    return exports.ox_inventory:ClearInventory(source, filterItems)
end

function Inventory.SetMaxWeight(source, maxWeight)
    return exports.ox_inventory:SetMaxWeight(source, maxWeight)
end

-- Función para usar items
function Inventory.UseItem(source, item, slot)
    return exports.ox_inventory:UseItem(source, item, slot)
end

-- Funciones de shops/stashes (OX específicas)
function Inventory.CreateShop(data)
    return exports.ox_inventory:CreateShop(data)
end

function Inventory.RegisterShop(shopName, shopData)
    return exports.ox_inventory:RegisterShop(shopName, shopData)
end

function Inventory.RegisterStash(stashId, stashData)
    return exports.ox_inventory:RegisterStash(stashId, stashData)
end

return Inventory 