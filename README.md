# Order Vehicle Transfer Contract

Un sistema seguro y robusto para la transferencia de vehículos entre jugadores en FiveM, desarrollado con ox_lib y diseñado con múltiples capas de seguridad anti-exploit.

## 🚀 Características

### ✨ Funcionalidades Principales
- **Transferencia segura de vehículos** entre jugadores
- **Sistema de contratos** con firmas digitales
- **Interfaz de usuario moderna** y responsive
- **Validaciones de seguridad** en tiempo real
- **Sistema de items** (contratos en blanco y firmados)
- **Soporte multiidioma** (Español e Inglés)
- **Integración con ox_target** para interacciones intuitivas

### 🔒 Seguridad Anti-Exploit
- **Rate limiting** para prevenir spam
- **Validación de distancia** entre jugadores y vehículos
- **Verificación de propiedad** de vehículos
- **Prevención de auto-transferencia**
- **Validación de jugadores online**
- **Hash de seguridad** para contratos
- **Logging de actividad sospechosa**
- **Timeouts automáticos** para contratos

### 🎯 Compatibilidad
- **QBCore** ✅
- **QBX Core** ✅ (preparado)
- **ESX** ✅ (preparado)

## 📋 Requisitos

### Dependencias Obligatorias
- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_target](https://github.com/overextended/ox_target)
- [oxmysql](https://github.com/overextended/oxmysql)

### Framework Compatible
- QBCore / QBX Core / ESX

## 🛠️ Instalación

1. **Descarga** el resource y colócalo en tu carpeta `resources`

2. **Configura** el archivo `config/init.lua` según tus necesidades:
```lua
Config = {
    framework = "qb-core", -- qb-core, qbx-core, es_extended
    language = "es", -- es, en
    
    -- Items configuration
    items = {
        blankContract = "vehicle_contract_blank",
        signedContract = "vehicle_contract_signed",
        requireContractItem = true,
        removeContractOnUse = true,
        giveSignedContract = true,
    },
    
    -- Security settings
    maxTransactionDistance = 10.0,
    maxVehicleDistance = 5.0,
    contractTimeout = 300000, -- 5 minutos
    
    -- Exploit protection
    exploitProtection = {
        enableRateLimiting = true,
        maxAttemptsPerMinute = 3,
        checkPlayerDistance = true,
        validateVehicleOwnership = true,
        preventSelfTransfer = true,
        requireBothPlayersOnline = true,
        logSuspiciousActivity = true
    }
}
```

3. **Agrega los items** a tu inventario (QBCore ejemplo):
```lua
-- En qb-core/shared/items.lua
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
    ['description'] = 'Un contrato en blanco para transferir vehículos'
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
    ['description'] = 'Un contrato de transferencia de vehículo firmado'
}
```

4. **Inicia** el resource:
```
ensure orderVehicleTransfer
```

## 🎮 Uso

### Para el Propietario Actual:
1. **Acércate** al vehículo que deseas transferir
2. **Usa ox_target** en el jugador al que quieres transferir el vehículo
3. **Selecciona** "Transferir Vehículo"
4. **Firma** el contrato en la interfaz
5. **Espera** a que el nuevo propietario firme

### Para el Nuevo Propietario:
1. **Recibe** la notificación del contrato
2. **Revisa** los detalles del vehículo
3. **Firma** el contrato para completar la transferencia

## ⚙️ Configuración Avanzada

### Seguridad
```lua
Config.exploitProtection = {
    enableRateLimiting = true,        -- Limitar intentos por minuto
    maxAttemptsPerMinute = 3,         -- Máximo 3 intentos por minuto
    checkPlayerDistance = true,       -- Verificar distancia entre jugadores
    validateVehicleOwnership = true,  -- Verificar propiedad del vehículo
    preventSelfTransfer = true,       -- Prevenir auto-transferencia
    requireBothPlayersOnline = true,  -- Ambos jugadores deben estar online
    logSuspiciousActivity = true      -- Registrar actividad sospechosa
}
```

### Base de Datos
```lua
Config.database = {
    vehicleTable = "player_vehicles",    -- Tabla de vehículos
    citizenIdColumn = "citizenid",       -- Columna de citizen ID
    plateColumn = "plate",               -- Columna de placa
    vehicleColumn = "vehicle"            -- Columna de modelo de vehículo
}
```

### Notificaciones
```lua
Config.notifications = {
    duration = 5000,    -- Duración en milisegundos
    position = "top"    -- Posición de las notificaciones
}
```

## 🔧 API

### Eventos del Cliente
```lua
-- Abrir UI para nuevo propietario
TriggerClientEvent("orderVehicleTransfer::client::signNewOwner", playerId, contractData)
```

### Callbacks del Servidor
```lua
-- Verificar si el jugador tiene un item
local hasItem = lib.callback.await("orderVehicleTransfer::server::hasItem", false, itemName, amount)

-- Iniciar nuevo contrato
local contract = lib.callback.await("orderVehicleTransfer::server::startNewContract", false, contractData)

-- Firmar como propietario actual
local success = lib.callback.await("orderVehicleTransfer::server::currentOwnerSigned", false, contractData)

-- Firmar como nuevo propietario
local success = lib.callback.await("orderVehicleTransfer::server::newOwnerSigned", false, contractData)

-- Cancelar contrato
local success = lib.callback.await("orderVehicleTransfer::server::cancelContract", false, contractData)
```

## 🐛 Solución de Problemas

### Problemas Comunes

**Error: "Framework not found"**
- Verifica que tengas QBCore, QBX Core o ESX instalado
- Asegúrate de que el framework esté iniciado antes que este resource

**Error: "ox_lib not found"**
- Instala ox_lib desde el repositorio oficial
- Asegúrate de que esté en la carpeta correcta

**Los contratos no se crean**
- Verifica la configuración de la base de datos
- Revisa que los items estén configurados correctamente
- Comprueba los logs del servidor para errores

### Logs de Seguridad
El sistema registra automáticamente actividad sospechosa:
```
[ANTI-EXPLOIT] 2024-01-01 12:00:00 | Source: 1 | CitizenId: ABC123 | Type: RATE_LIMIT_EXCEEDED
```

## 📝 Changelog

### v1.0.0
- ✅ Sistema completo de transferencia de vehículos
- ✅ Seguridad anti-exploit implementada
- ✅ Soporte para múltiples frameworks
- ✅ Interfaz de usuario moderna
- ✅ Sistema de localización
- ✅ Documentación completa

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver `LICENSE` para más detalles.

## 👨‍💻 Autor

**JericoFX** - *Desarrollo inicial* - [GitHub](https://github.com/JericoFX)

## 🙏 Agradecimientos

- **ox_lib** por las utilidades y clases
- **ox_target** por el sistema de targeting
- **QBCore** por el framework base
- **La comunidad de FiveM** por el feedback y testing

---

⭐ **¡Dale una estrella si este proyecto te ayudó!**
