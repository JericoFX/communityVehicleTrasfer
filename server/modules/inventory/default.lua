local Inventory = {}

-- Default Inventory Adapter
-- Usa las funciones nativas del framework cuando no hay sistema de inventario específico

-- Detectar framework para usar las funciones correctas
local function GetFramework()
    if GetResourceState('es_extended') == 'started' then
        return 'es_extended', exports["es_extended"]:getSharedObject()
    elseif GetResourceState('qbx_core') == 'started' then
        return 'qbx_core', exports.qbx_core
    elseif GetResourceState('qb-core') == 'started' then
        return 'qb_core', exports["qb-core"]:GetCoreObject()
    else
        error("No se detectó ningún framework compatible")
    end
end

local framework, coreObj = GetFramework()

-- Funciones comunes independientemente del framework
function Inventory.AddItem(source, item, amount, metadata, slot)
    if framework == 'es_extended' then
        local xPlayer = coreObj.GetPlayerFromId(source)
        if not xPlayer then return false end
        xPlayer.addInventoryItem(item, amount or 1, metadata)
        return true
        
    elseif framework == 'qb_core' or framework == 'qbx_core' then
        local Player = coreObj.Functions.GetPlayer(source)
        if not Player then return false end
        return Player.Functions.AddItem(item, amount or 1, slot, metadata)
    end
    
    return false
end

function Inventory.RemoveItem(source, item, amount, slot)
    if framework == 'es_extended' then
        local xPlayer = coreObj.GetPlayerFromId(source)
        if not xPlayer then return false end
        xPlayer.removeInventoryItem(item, amount or 1)
        return true
        
    elseif framework == 'qb_core' or framework == 'qbx_core' then
        local Player = coreObj.Functions.GetPlayer(source)
        if not Player then return false end
        return Player.Functions.RemoveItem(item, amount or 1, slot)
    end
    
    return false
end

function Inventory.HasItem(source, item, amount)
    if framework == 'es_extended' then
        local xPlayer = coreObj.GetPlayerFromId(source)
        if not xPlayer then return false end
        local hasItem = xPlayer.getInventoryItem(item)
        return hasItem and hasItem.count >= (amount or 1)
        
    elseif framework == 'qb_core' or framework == 'qbx_core' then
        local Player = coreObj.Functions.GetPlayer(source)
        if not Player then return false end
        local hasItem = Player.Functions.GetItemByName(item)
        return hasItem and hasItem.amount >= (amount or 1)
    end
    
    return false
end

function Inventory.GetItemCount(source, item)
    if framework == 'es_extended' then
        local xPlayer = coreObj.GetPlayerFromId(source)
        if not xPlayer then return 0 end
        local hasItem = xPlayer.getInventoryItem(item)
        return hasItem and hasItem.count or 0
        
    elseif framework == 'qb_core' or framework == 'qbx_core' then
        local Player = coreObj.Functions.GetPlayer(source)
        if not Player then return 0 end
        local hasItem = Player.Functions.GetItemByName(item)
        return hasItem and hasItem.amount or 0
    end
    
    return 0
end

function Inventory.GetItem(source, item, metadata)
    if framework == 'es_extended' then
        local xPlayer = coreObj.GetPlayerFromId(source)
        if not xPlayer then return nil end
        return xPlayer.getInventoryItem(item)
        
    elseif framework == 'qb_core' or framework == 'qbx_core' then
        local Player = coreObj.Functions.GetPlayer(source)
        if not Player then return nil end
        
        -- Si se especifica metadata, buscar específico
        if metadata then
            for _, itemData in pairs(Player.PlayerData.items) do
                if itemData and itemData.name == item and itemData.info == metadata then
                    return itemData
                end
            end
            return nil
        end
        
        return Player.Functions.GetItemByName(item)
    end
    
    return nil
end

function Inventory.GetInventory(source)
    if framework == 'es_extended' then
        local xPlayer = coreObj.GetPlayerFromId(source)
        if not xPlayer then return {} end
        return xPlayer.getInventory()
        
    elseif framework == 'qb_core' or framework == 'qbx_core' then
        local Player = coreObj.Functions.GetPlayer(source)
        if not Player then return {} end
        return Player.PlayerData.items
    end
    
    return {}
end

function Inventory.SetItemMetadata(source, item, slot, metadata)
    -- Los frameworks básicos no suelen soportar esto directamente
    -- Requerirá remove/add en la mayoría de casos
    if framework == 'qb_core' or framework == 'qbx_core' then
        local Player = coreObj.Functions.GetPlayer(source)
        if not Player then return false end
        
        if Player.PlayerData.items[slot] then
            Player.PlayerData.items[slot].info = metadata
            Player.Functions.SetPlayerData('items', Player.PlayerData.items)
            return true
        end
    end
    
    return false
end

function Inventory.CanCarryItem(source, item, amount)
    if framework == 'es_extended' then
        local xPlayer = coreObj.GetPlayerFromId(source)
        if not xPlayer then return false end
        return xPlayer.canCarryItem(item, amount or 1)
        
    elseif framework == 'qb_core' or framework == 'qbx_core' then
        local Player = coreObj.Functions.GetPlayer(source)
        if not Player then return false end
        
        -- Verificar slots libres básico
        local emptySlots = 0
        local maxSlots = coreObj.Config and coreObj.Config.Player and coreObj.Config.Player.MaxInvSlots or 41
        
        for i = 1, maxSlots do
            if not Player.PlayerData.items[i] then
                emptySlots = emptySlots + 1
            end
        end
        
        return emptySlots > 0
    end
    
    return false
end

function Inventory.GetWeight(source)
    if framework == 'es_extended' then
        -- ESX básico no maneja peso por defecto
        return 0
        
    elseif framework == 'qb_core' or framework == 'qbx_core' then
        local Player = coreObj.Functions.GetPlayer(source)
        if not Player then return 0 end
        
        -- Calcular peso manualmente
        local weight = 0
        for _, item in pairs(Player.PlayerData.items) do
            if item then
                local itemInfo = coreObj.Shared.Items[item.name]
                if itemInfo then
                    weight = weight + (itemInfo.weight or 0) * item.amount
                end
            end
        end
        return weight
    end
    
    return 0
end

function Inventory.GetMaxWeight(source)
    if framework == 'es_extended' then
        -- ESX básico no maneja peso por defecto
        return 999999
        
    elseif framework == 'qb_core' or framework == 'qbx_core' then
        return coreObj.Config and coreObj.Config.Player and coreObj.Config.Player.MaxWeight or 120000
    end
    
    return 999999
end

function Inventory.ClearInventory(source)
    if framework == 'es_extended' then
        local xPlayer = coreObj.GetPlayerFromId(source)
        if not xPlayer then return false end
        
        -- Remover todos los items uno por uno
        for _, item in pairs(xPlayer.getInventory()) do
            if item.count > 0 then
                xPlayer.setInventoryItem(item.name, 0)
            end
        end
        return true
        
    elseif framework == 'qb_core' or framework == 'qbx_core' then
        local Player = coreObj.Functions.GetPlayer(source)
        if not Player then return false end
        
        Player.Functions.SetPlayerData('items', {})
        return true
    end
    
    return false
end

-- Funciones de compatibilidad que no están disponibles en framework básico
function Inventory.Search(source, search, items)
    return {}
end

function Inventory.ConfiscateInventory(source)
    return false
end

function Inventory.ReturnInventory(source)
    return false
end

function Inventory.CreateShop(data)
    return false
end

function Inventory.RegisterStash(stashId, stashData)
    return false
end

function Inventory.UseItem(source, item, slot)
    return false
end

return Inventory 