--[[
 - @ Author: flora
 - @ Create Time: 2026-02-22 21:48:21
 - @ Modified by: flora
 - @ Modified time: 2026-02-28 18:26:04
 - @ Description: Oyuncu verilerini yönetmek için sunucu tarafı modülü. Verilerin kaydedilmesi, yüklenmesi ve güncellenmesi gibi işlemleri içerir.
]]

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules
local Attributes = require(ReplicatedStorage.Framework.Shared.Config.Attributes)
local GeneralConfig = require(ReplicatedStorage.Framework.Shared.Config.GeneralConfig)

--// Module
local PlayerHandler = {
    Name = "PlayerHandler",
    Dependencies = {
        CommandHandler = "CommandHandler",
        DataService = "DataService",
    }
}

--// Functions
local function playerAdded(player: Player)
    print(`🎮 | Player added: {player.Name} (ID: {player.UserId})`)

    local playerRank = player:GetRankInGroupAsync(GeneralConfig.GROUP_ID)

    player:SetAttribute(Attributes.Player.GROUP_RANK, playerRank)

    PlayerHandler.CommandHandler:HandlePlayerChatted(player)

    PlayerHandler.DataService:LoadPlayer(player)
end

local function playerRemoving(player: Player)
    print(`👋 | Player removing: {player.Name} (ID: {player.UserId})`)

    PlayerHandler.DataService:SavePlayer(player)
end

function PlayerHandler:FindPlayer(username: string): Player?
    local directFound = Players:FindFirstChild(username)
    if directFound then
        return directFound
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player.Name:lower() == username:lower() then
            return player
        end

        if string.lower(player.Name[#username]) == string.lower(username[#username]) then
            return player
        end
    end
    
    return nil
end

function PlayerHandler:Start()
    for _, player in Players:GetPlayers() do
        playerAdded(player)
    end
    
    Players.PlayerAdded:Connect(function(player)
        playerAdded(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        playerRemoving(player)
    end)
end

--// Module Exporting
return PlayerHandler