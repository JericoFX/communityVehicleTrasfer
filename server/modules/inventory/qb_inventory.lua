local Inventory = {}

-- QB_Inventory Adapter
-- Requiere: qb-inventory resource y QBCore

-- Obtener QBCore dependiendo del framework
local QBCore = exports['qb-core']:GetCoreObject()

function Inventory.AddItem(source, item, amount, metadata, slot)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    local success = Player.Functions.AddItem(item, amount or 1, slot, metadata)
    return success
end

function Inventory.RemoveItem(source, item, amount, slot)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    local success = Player.Functions.RemoveItem(item, amount or 1, slot)
    return success
end

function Inventory.HasItem(source, item, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    local hasItem = Player.Functions.GetItemByName(item)
    if not hasItem then return false end
    
    return hasItem.amount >= (amount or 1)
end

function Inventory.GetItemCount(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return 0 end
    
    local hasItem = Player.Functions.GetItemByName(item)
    return hasItem and hasItem.amount or 0
end

function Inventory.GetItem(source, item, metadata)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return nil end
    
    -- Si se especifica metadata, buscar item específico
    if metadata then
        for _, itemData in pairs(Player.PlayerData.items) do
            if itemData.name == item and itemData.info and itemData.info == metadata then
                return itemData
            end
        end
        return nil
    end
    
    return Player.Functions.GetItemByName(item)
end

function Inventory.GetInventory(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return {} end
    
    return Player.PlayerData.items
end

function Inventory.SetItemMetadata(source, item, slot, metadata)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    -- QB-Inventory maneja metadata como "info"
    if Player.PlayerData.items[slot] then
        Player.PlayerData.items[slot].info = metadata
        Player.Functions.SetPlayerData('items', Player.PlayerData.items)
        return true
    end
    return false
end

function Inventory.CanCarryItem(source, item, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    -- Verificar peso si QB-Inventory maneja peso
    if exports['qb-inventory'] and exports['qb-inventory']['CanAddItem'] then
        return exports['qb-inventory']:CanAddItem(source, item, amount or 1)
    end
    
    -- Fallback - verificar slots libres
    local emptySlots = 0
    for i = 1, QBCore.Config.Player.MaxInvSlots do
        if not Player.PlayerData.items[i] then
            emptySlots = emptySlots + 1
        end
    end
    
    return emptySlots > 0
end

function Inventory.GetWeight(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return 0 end
    
    -- Si QB-Inventory tiene función de peso
    if exports['qb-inventory'] and exports['qb-inventory']['GetTotalWeight'] then
        return exports['qb-inventory']:GetTotalWeight(Player.PlayerData.items)
    end
    
    -- Calcular peso manualmente
    local weight = 0
    for _, item in pairs(Player.PlayerData.items) do
        if item then
            local itemInfo = QBCore.Shared.Items[item.name]
            if itemInfo then
                weight = weight + (itemInfo.weight or 0) * item.amount
            end
        end
    end
    return weight
end

function Inventory.GetMaxWeight(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return 0 end
    
    -- Si QB-Inventory tiene configuración de peso máximo
    if QBCore.Config and QBCore.Config.Player and QBCore.Config.Player.MaxWeight then
        return QBCore.Config.Player.MaxWeight
    end
    
    return 120000 -- Peso por defecto en QB
end

-- Funciones específicas de QB-Inventory (extras)
function Inventory.GetItemsByName(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return {} end
    
    local items = {}
    for _, itemData in pairs(Player.PlayerData.items) do
        if itemData and itemData.name == item then
            table.insert(items, itemData)
        end
    end
    return items
end

function Inventory.GetSlotsByItem(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return {} end
    
    local slots = {}
    for slot, itemData in pairs(Player.PlayerData.items) do
        if itemData and itemData.name == item then
            table.insert(slots, slot)
        end
    end
    return slots
end

function Inventory.GetFirstSlotByItem(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return nil end
    
    for slot, itemData in pairs(Player.PlayerData.items) do
        if itemData and itemData.name == item then
            return slot
        end
    end
    return nil
end

function Inventory.ClearInventory(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    Player.Functions.SetPlayerData('items', {})
    return true
end

-- Funciones de stash (si QB-Inventory las soporta)
function Inventory.OpenStash(source, stashId)
    if exports['qb-inventory'] and exports['qb-inventory']['OpenInventory'] then
        exports['qb-inventory']:OpenInventory(source, 'stash', stashId)
        return true
    end
    return false
end

function Inventory.CreateStash(stashId, label, slots, maxWeight)
    -- Esta función varía según la versión de QB-Inventory
    if exports['qb-inventory'] and exports['qb-inventory']['CreateStash'] then
        return exports['qb-inventory']:CreateStash(stashId, label, slots, maxWeight)
    end
    return false
end

return Inventory 