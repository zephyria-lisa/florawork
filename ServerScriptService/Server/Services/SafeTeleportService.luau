--[[
 - @ Author: flora
 - @ Create Time: 2026-02-25 21:59:42
 - @ Modified by: flora
 - @ Modified time: 2026-03-09 23:23:42
 - @ Description: Oyuncuların güvenli bir şekilde teleport olmalarını sağlayan modül. Teleport işlemi sırasında oyuncuların konumlarını kontrol eder, güvenli bir alan olup olmadığını belirler ve teleport işlemini gerçekleştirir. Ayrıca, teleport işlemi sırasında oluşabilecek hataları engeller.
]]

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

--// Modules
local Attributes = require(ReplicatedStorage.Framework.Shared.Config.Attributes)

--// Module
local SafeTeleportService = {
    Name = "SafeTeleportService",
    Dependencies = {
        DataService = "DataService",
    },
}

--// Functions
function SafeTeleportService:ForceReserveServer(placeId: number)
    for i = 1, 5 do
        local success, data = pcall(function()
            return TeleportService:ReserveServerAsync(placeId)
        end)

        if success then
            return data
        end

        warn("⚠️ | Failed to reserve server for placeId " .. tostring(placeId) .. ". Attempt " .. tostring(i) .. "/5. Error: " .. tostring(data))
        task.wait(1 + 0.5 * i)
    end
end

function SafeTeleportService:SafeTeleportPlayers(
    players: { Player }, 
    placeId: number, 
    reservedServerCode: string?
)
    local teleportOptions = Instance.new("TeleportOptions")

    for _, player in players do
        player:SetAttribute(Attributes.Player.IS_BEING_TELEPORTED, true)

        for i = 1, 5 do
            local status = self.DataService:SavePlayer(player, true)

            if status then
                break
            else
                warn("⚠️ | " .. tostring(self.Name) .. ": Failed to save data for player " .. tostring(player.Name) .. " before teleporting.")
                task.wait(1 + 0.5 * i)
            end
        end
    end

    local optionsToPass = nil

    if reservedServerCode then
        teleportOptions.ReservedServerCode = reservedServerCode
        optionsToPass = teleportOptions
    end

    local success, data = pcall(function()
        TeleportService:TeleportAsync(placeId, players, optionsToPass)
    end)

    if not success then
        warn("⚠️ | " .. tostring(self.Name) .. ": Failed to teleport players to placeId " .. tostring(placeId) .. ". Error: " .. tostring(data))
        for _, player in players do
            player:SetAttribute(Attributes.Player.IS_BEING_TELEPORTED, false)
        end
    end

    return true
end

--// Module Exporting
return SafeTeleportService