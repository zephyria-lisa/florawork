--[[
 - @ Author: flora
 - @ Create Time: 2026-02-28 20:56:50
 - @ Modified by: flora
 - @ Modified time: 2026-02-28 21:01:26
 - @ Description: Sunucu genelinde cooldown yönetimi modülü.
]]

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Module
local ServerCooldownService = {
    Name = "ServerCooldownService",
}

--// Functions
function ServerCooldownService:InitCooldowns(cooldownsTable: { [string]: number })
    if not self._cooldowns then
        self._cooldowns = {}
    end
    
    for cooldownName, cooldownDuration in cooldownsTable do
        self._cooldowns[cooldownName] = {
            endsBy = 0,
            duration = cooldownDuration,
        } 
    end
end

function ServerCooldownService:StartCooldown(cooldownName: string)
    local cooldown = self._cooldowns[cooldownName]
    
    if not cooldown then
        warn(`⚠️ | Cooldown {cooldownName} not found.`) 
        return
    end
    
    cooldown.endsBy = os.time() + cooldown.duration
end

function ServerCooldownService:IsOnCooldown(cooldownName: string)
    local cooldown = self._cooldowns[cooldownName]
    
    if not cooldown then
        warn(`⚠️ | Cooldown {cooldownName} not found.`) 
        return false
    end
    
    return os.time() < cooldown.endsBy
end

function ServerCooldownService:GetRemainingTime(cooldownName: string)
    local cooldown = self._cooldowns[cooldownName]
    
    if not cooldown then
        warn(`⚠️ | Cooldown {cooldownName} not found.`) 
        return 0
    end
    
    return math.max(0, cooldown.endsBy - os.time())
end

function ServerCooldownService:Init()
    print("ℹ️ | Initializing ServerCooldownService module.")
end

function ServerCooldownService:Start()
    print("ℹ️ | Starting ServerCooldownService module.")
end

--// Module Exporting
return ServerCooldownService