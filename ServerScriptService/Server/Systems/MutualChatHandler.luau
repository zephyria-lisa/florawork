--[[
 - @ Author: flora
 - @ Create Time: 2026-02-23 22:35:32
 - @ Modified by: flora
 - @ Modified time: 2026-02-28 18:26:01
 - @ Description: Oyuncuların birbiriyle iletişim kurup kuramayacağını kontrol eden istemci tarafı modülü. Oyuncuların birbirlerini görüp göremeyeceği, birbirleriyle sohbet edip edemeyeceği gibi özellikleri yönetir.
]]

--// Services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

--// Modules
local Attributes = require(ReplicatedStorage.Framework.Shared.Config.Attributes)
local Net = require(ReplicatedStorage.Framework.Shared.Net.Net)

--// Module
local MutualChatHandler = {
    Name = "MutualChatHandler",
}

--// Functions
function MutualChatHandler:CachePlayerChatGroup(player: Player)
    local success, data = pcall(function()
        return TextChatService:GetChatGroupsAsync({ player })
    end)

    if not success then 
        warn(`⚠️ | Failed to get chat groups for player {player.Name} (ID: {player.UserId}): {data}`)
        return
    end

    local playerGroups = {}

    for _, group in data do
        for v, groupId in group do
            table.insert(playerGroups, groupId)
            print(`✅ | Player {player.Name} is in chat group: {groupId}`)
        end

        player:SetAttribute(Attributes.Player.CHAT_GROUPS_LOADED, true)
        player:SetAttribute(Attributes.Player.CHAT_GROUPS, HttpService:JSONEncode(playerGroups))
    end
end

function MutualChatHandler:CachePlayerGroups()
    local currentPlayers = Players:GetPlayers()

    for _, player in currentPlayers do
        self:CachePlayerChatGroup(player)
    end
end

function MutualChatHandler:Start()
    self:CachePlayerGroups()

    print("ℹ️ | MutualChatHandler started. Players' chat groups will be cached as they join.")

    Players.PlayerAdded:Connect(function(player)
        self:CachePlayerChatGroup(player)
    end)
end
    
--// Module Exporting
return MutualChatHandler