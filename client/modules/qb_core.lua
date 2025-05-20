local Core = lib.class("qb-core")

function Core:load()
    self.core = exports["qb-core"]:GetPlayerData()
end

Core:load()
