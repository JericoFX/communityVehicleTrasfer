# API Unificada de Core

Esta API proporciona una interfaz unificada para trabajar con las funciones principales de diferentes frameworks de FiveM (ES_Extended, QB_Core, QBX_Core).

## Características

- **Detección automática de framework**: La API detecta automáticamente qué framework está en uso
- **Sistema de inventarios modular**: Soporte para ox_inventory, qs_inventory, qb_inventory y más
- **Interfaz unificada**: Las mismas funciones funcionan independientemente del framework/inventario
- **Soporte completo**: Compatible con ES_Extended, QB_Core y QBX_Core
- **Funciones completas**: Jugadores, inventario avanzado, dinero, trabajos, vehículos

## Uso

```lua
-- Importar la API
local Core = require('server.modules.cores.init')

-- Las funciones funcionan igual sin importar el framework
local player = Core.GetPlayer(source)
local hasItem = Core.HasItem(source, 'bread', 5)
local money = Core.GetMoney(source, 'cash')

-- Sistema de inventarios automático
print('Framework:', Core.GetFramework())
print('Inventario:', Core.GetInventorySystem())
```

## Funciones Disponibles

### **Funciones de Jugador**

#### `Core.GetPlayer(source)`
Obtiene el objeto jugador desde el source.

**Parámetros:**
- `source`: ID del jugador conectado

**Retorna:** Objeto jugador del framework correspondiente

#### `Core.GetPlayerData(source, key)`
Obtiene datos específicos del jugador.

**Parámetros:**
- `source`: ID del jugador
- `key`: Clave de datos a obtener

**Retorna:** Valor correspondiente a la clave o el objeto jugador completo

#### `Core.GetPlayerInformation(source)`
Obtiene información básica del jugador en formato unificado.

**Parámetros:**
- `source`: ID del jugador

**Retorna:** Table con `source`, `citizenid`, `fullName`

#### `Core.GetPlayerById(id)`
Obtiene un jugador por su ID único (citizenid/identifier).

**Parámetros:**
- `id`: citizenid (QB/QBX) o identifier (ESX)

**Retorna:** Objeto jugador o nil si no existe

#### `Core.GetPlayerByCitizenId(citizenId)`
Alias unificado para obtener jugador por ID (maneja automáticamente la diferencia entre frameworks).

### **Funciones de Inventario**

#### `Core.AddItem(source, item, amount, metadata)`
Añade un item al inventario del jugador.

**Parámetros:**
- `source`: ID del jugador
- `item`: Nombre del item
- `amount`: Cantidad (opcional, default: 1)
- `metadata`: Metadata del item (opcional)

**Retorna:** boolean (true si se añadió correctamente)

#### `Core.RemoveItem(source, item, amount)`
Remueve un item del inventario del jugador.

**Parámetros:**
- `source`: ID del jugador
- `item`: Nombre del item
- `amount`: Cantidad (opcional, default: 1)

**Retorna:** boolean (true si se removió correctamente)

#### `Core.HasItem(source, item, amount)`
Verifica si el jugador tiene suficiente cantidad de un item.

**Parámetros:**
- `source`: ID del jugador
- `item`: Nombre del item
- `amount`: Cantidad mínima (opcional, default: 1)

**Retorna:** boolean (true si tiene suficiente cantidad)

### **Funciones de Dinero**

#### `Core.AddMoney(source, account, amount)`
Añade dinero a una cuenta del jugador.

**Parámetros:**
- `source`: ID del jugador
- `account`: Tipo de cuenta ('cash', 'bank', 'money', etc.)
- `amount`: Cantidad a añadir

**Retorna:** boolean (true si se añadió correctamente)

#### `Core.RemoveMoney(source, account, amount)`
Remueve dinero de una cuenta del jugador.

**Parámetros:**
- `source`: ID del jugador
- `account`: Tipo de cuenta
- `amount`: Cantidad a remover

**Retorna:** boolean (true si se removió correctamente)

#### `Core.GetMoney(source, account)`
Obtiene la cantidad de dinero en una cuenta.

**Parámetros:**
- `source`: ID del jugador
- `account`: Tipo de cuenta (opcional, default: 'cash'/'money')

**Retorna:** number (cantidad de dinero)

### **Funciones de Trabajo**

#### `Core.SetJob(source, job, grade)`
Establece el trabajo del jugador.

**Parámetros:**
- `source`: ID del jugador
- `job`: Nombre del trabajo
- `grade`: Grado del trabajo (opcional, default: 0)

**Retorna:** boolean (true si se estableció correctamente)

#### `Core.GetJob(source)`
Obtiene el trabajo actual del jugador.

**Parámetros:**
- `source`: ID del jugador

**Retorna:** Table con información del trabajo

### **Funciones de Vehículo**

#### `Core.GetVehicleInformation(identifier, plate)`
Obtiene información de un vehículo específico.

**Parámetros:**
- `identifier`: citizenid (QB/QBX) o identifier (ESX)
- `plate`: matrícula del vehículo

**Retorna:** Table con información del vehículo o nil

#### `Core.ChangeVehicleOwner(newOwnerId, plate)`
Cambia el propietario de un vehículo.

**Parámetros:**
- `newOwnerId`: nuevo ciudenid/identifier del propietario
- `plate`: matrícula del vehículo

**Retorna:** boolean, string (success, error message)

### **Funciones de Utilidad**

#### `Core.GetFramework()`
Obtiene el nombre del framework actual detectado.

**Retorna:** string ('es_extended', 'qb_core', o 'qbx_core')

#### `Core.GetInventorySystem()`
Obtiene el nombre del sistema de inventario actual detectado.

**Retorna:** string ('ox_inventory', 'qs_inventory', 'qb_inventory', o 'default')

#### `Core.GetCoreModule()`
Obtiene el módulo core específico del framework para funciones avanzadas.

**Retorna:** Objeto del módulo core específico

#### `Core.GetInventoryModule()`
Obtiene el módulo de inventario específico para funciones avanzadas.

**Retorna:** Objeto del módulo de inventario específico

#### `Core.ShowNotification(source, message, type)`
Muestra una notificación al jugador (unificada para todos los frameworks).

**Parámetros:**
- `source`: ID del jugador
- `message`: Mensaje a mostrar
- `type`: Tipo de notificación (opcional)

## Diferencias por Framework

### ES_Extended
- Usa `identifier` como ID único
- Funciones de dinero usan `addAccountMoney`/`removeAccountMoney`
- Items usan `addInventoryItem`/`removeInventoryItem`

### QB_Core / QBX_Core
- Usa `citizenid` como ID único
- Funciones de dinero usan `AddMoney`/`RemoveMoney`
- Items usan `AddItem`/`RemoveItem`

## Ejemplo de Uso Completo

```lua
local Core = require('server.modules.cores.init')

RegisterCommand('givemoney', function(source, args)
    if #args < 2 then
        Core.ShowNotification(source, 'Uso: /givemoney [amount] [account]', 'error')
        return
    end
    
    local amount = tonumber(args[1])
    local account = args[2] or 'cash'
    
    -- Verificar si tiene suficiente dinero
    local currentMoney = Core.GetMoney(source, account)
    if currentMoney < amount then
        Core.ShowNotification(source, 'No tienes suficiente dinero', 'error')
        return
    end
    
    -- Dar dinero
    local success = Core.AddMoney(source, account, amount)
    if success then
        Core.ShowNotification(source, ('Has recibido $%d en %s'):format(amount, account), 'success')
    else
        Core.ShowNotification(source, 'Error al dar dinero', 'error')
    end
end)

-- Ejemplo con items
RegisterCommand('giveitem', function(source, args)
    if #args < 2 then return end
    
    local item = args[1]
    local amount = tonumber(args[2]) or 1
    
    -- Verificar si el jugador puede recibir el item
    local success = Core.AddItem(source, item, amount)
    if success then
        Core.ShowNotification(source, ('Has recibido %dx %s'):format(amount, item), 'success')
    else
        Core.ShowNotification(source, 'Error al dar item', 'error')
    end
end)

-- Ejemplo con trabajos
RegisterCommand('setjob', function(source, args)
    if #args < 1 then return end
    
    local job = args[1]
    local grade = tonumber(args[2]) or 0
    
    local success = Core.SetJob(source, job, grade)
    if success then
        Core.ShowNotification(source, ('Trabajo cambiado a %s grado %d'):format(job, grade), 'success')
    end
end)
```

## Estructura de Archivos

```
server/modules/
├── cores/
│   ├── init.lua          # API principal con detección automática
│   ├── es_extended.lua   # Implementación para ESX
│   ├── qb_core.lua       # Implementación para QB-Core
│   ├── qbx_core.lua      # Implementación para QBX-Core
│   └── README.md         # Esta documentación
├── inventory/
│   ├── init.lua          # API de inventarios unificada
│   ├── ox_inventory.lua  # Adapter para OX_Inventory
│   ├── qs_inventory.lua  # Adapter para QS_Inventory  
│   ├── qb_inventory.lua  # Adapter para QB_Inventory
│   ├── default.lua       # Fallback al framework nativo
│   └── README.md         # Documentación de inventarios
└── database/
    ├── init.lua          # API de base de datos
    └── ...               # Implementaciones por framework
```

## Inventarios Soportados

Este sistema incluye soporte automático para diferentes inventarios:

- **ox_inventory** - Sistema moderno con funciones avanzadas
- **qs_inventory** - Inventario QS con stashes y shops
- **qb_inventory** - Inventario clásico de QB-Core
- **default** - Inventario nativo del framework (fallback)

Ver `server/modules/inventory/README.md` para configuración detallada.

## Notas

- La API detecta automáticamente el framework e inventario al inicializar
- No es necesario cambiar código al migrar entre frameworks o inventarios
- Todas las funciones manejan errores internamente
- Se recomienda usar esta API en lugar de acceder directamente a los frameworks
- Para funciones específicas del framework, puedes usar `Core.GetCoreModule()`
- Para funciones específicas del inventario, puedes usar `Core.GetInventoryModule()`

# Sistema de Cores Unificado

## 🔧 Mapeo de Identificadores

El sistema unifica automáticamente los diferentes tipos de identificadores de los frameworks:

### **ESX Extended**
- **Nativo:** `identifier` (ejemplo: `char1:steam:110000123456789`)
- **Unificado:** Mapeado a `citizenid` en la API

### **QB-Core / QBX-Core**  
- **Nativo:** `citizenid` (ejemplo: `ABC12345`)
- **Unificado:** Mantiene `citizenid`

## 📋 API Unificada

```lua
local Core = require('server.modules.cores.init')

-- Esta función SIEMPRE devuelve:
local playerInfo = Core.GetPlayerInformation(source)
-- {
--   source = 1,
--   citizenid = "ABC12345",        -- ESX: identifier → citizenid
--   fullName = "John Doe"          -- ESX: getName() | QB: firstname + lastname  
-- }
```

## ✅ Garantías del Sistema

1. **Compatibilidad Total:** `citizenid` funciona en todos los frameworks
2. **Transparencia:** No necesitas saber qué framework está en uso
3. **Robustez:** Manejo de errores incluido (jugador offline, datos faltantes)
4. **Consistencia:** Misma estructura de respuesta siempre

## 🎯 Ejemplo de Uso

```lua
-- Funciona igual en ESX, QB-Core y QBX-Core
local ownerInfo = Framework.GetPlayerInformation(source)
local vehicleInfo = Framework.GetVehicleInformation(ownerInfo.citizenid, plate)

-- ownerInfo.citizenid será:
-- ESX: "char1:steam:110000123456789" (identifier)
-- QB:  "ABC12345" (citizenid)
-- QBX: "ABC12345" (citizenid)
```

El sistema maneja automáticamente las diferencias internas. ¡Solo usa la API unificada! 🚀 