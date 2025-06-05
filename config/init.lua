Config = {
    -- General settings
    language = "en", -- en, es
    debug = false,
    
    -- Security settings
    maxTransactionDistance = 10.0, -- Max distance between players for transaction
    maxVehicleDistance = 5.0, -- Max distance to vehicle for transfer
    contractTimeout = 300000, -- 5 minutes in milliseconds
    
    -- Items configuration
    items = {
        blankContract = "vehicle_contract_blank", -- Empty contract item
        signedContract = "vehicle_contract_signed", -- Signed contract item
        requireContractItem = true, -- Require blank contract item to start transfer
        removeContractOnUse = true, -- Remove blank contract when used
        giveSignedContract = true, -- Give signed contract to both parties
    },
    
    
    -- Notifications
    notifications = {
        duration = 5000,
        position = "top"
    },
    
    -- Exploits protection
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
