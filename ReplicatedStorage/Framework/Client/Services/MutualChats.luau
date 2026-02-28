--[[
 - @ Author: flora
 - @ Create Time: 2026-02-23 23:19:22
 - @ Modified by: flora
 - @ Modified time: 2026-02-28 18:26:19
 - @ Description: İstemci (local) oyuncusunun diğer oyuncularla sohbet edip edemeyeceğini kontrol eden modül. Oyuncuların birbirlerini görüp göremeyeceği, birbirleriyle sohbet edip edemeyeceği gibi özellikleri yönetir.
]]

--// Services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules
local Attributes = require(ReplicatedStorage.Framework.Shared.Config.Attributes)

--// Assets
local localPlayer = Players.LocalPlayer

--// Module
local MutualChats = {
    Name = "MutualChats",
}

--// Helper Functions
local function getPlayerChatGroups(player: Player)
    local playerChatGroups = player:GetAttribute(Attributes.Player.CHAT_GROUPS)

    if not playerChatGroups then
        warn(`⚠️ | Player {player.Name} does not have chat groups attribute set.`)
        return {}
    end

    return HttpService:JSONDecode(playerChatGroups)
end

--// Functions
function MutualChats:LocalPlayerCanChatWith(player: Player)
    if not player or not player:IsA("Player") then
        warn(`⚠️ | Invalid player argument passed to LocalPlayerCanChatWith: {tostring(player)}`)
        return false
    end

    local localPlayerGroups = getPlayerChatGroups(localPlayer)
    local targetPlayerGroups = getPlayerChatGroups(player)

    for _, group in ipairs(localPlayerGroups) do
        if table.find(targetPlayerGroups, group) then
            return true
        end
    end

    return false
end

function MutualChats:AttachBillboardToCharacter(character: Model)
    if not character or not character:IsA("Model") then
        warn(`⚠️ | Invalid character argument passed to AttachBillboardToCharacter: {tostring(character)}`)
        return
    end

    local billboardClone = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("MutualChatBillboard"):Clone()
    billboardClone.Parent = character:WaitForChild("Head")
    billboardClone.Adornee = character:WaitForChild("Head")
end

function MutualChats:StartPlayersEvents()
    if not localPlayer:GetAttribute(Attributes.Player.CHAT_GROUPS_LOADED) then
        print("ℹ️ | Waiting for local player's chat groups to load...")
        localPlayer:GetAttributeChangedSignal(Attributes.Player.CHAT_GROUPS):Wait()
    end

    print("ℹ️ | Local player's chat groups have been loaded. MutualChats is now active.")

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            print(`ℹ️ | Checking existing player {player.Name} for mutual chat status...`)
            
            if player.Character and not self:LocalPlayerCanChatWith(player) then
                print(`❌ | Local player cannot chat with {player.Name}. Attaching billboard to existing character...`)
                self:AttachBillboardToCharacter(player.Character)
            else
                print(`✅ | Local player can chat with {player.Name} or character not loaded yet.`)
            end
        end
    end

    Players.PlayerAdded:Connect(function(player)
        if not player:GetAttribute(Attributes.Player.CHAT_GROUPS_LOADED) then
            player:GetAttributeChangedSignal(Attributes.Player.CHAT_GROUPS):Wait()
        end
        
        print(`ℹ️ | Player {player.Name} has joined and their chat groups are loaded. Checking mutual chat status...`)
        
        if player.Character and not self:LocalPlayerCanChatWith(player) then
            print(`❌ | Local player cannot chat with {player.Name}. Attaching billboard to existing character...`)
            self:AttachBillboardToCharacter(player.Character)
        else
            print(`✅ | Local player can chat with {player.Name} or character not loaded yet.`)
        end

        player.CharacterAdded:Connect(function()
            print(`ℹ️ | Player {player.Name}'s character has loaded. Checking mutual chat status...`)
            
            if self:LocalPlayerCanChatWith(player) then
                print(`✅ | Local player can chat with {player.Name}.`)
                return                
            end

            print(`❌ | Local player cannot chat with {player.Name}.`)

            local billboardClone = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("MutualChatBillboard"):Clone()
            billboardClone.Parent = player.Character:WaitForChild("Head")
            billboardClone.Adornee = player.Character:WaitForChild("Head")
        end)
    end)
end

function MutualChats:Start()
    print("ℹ️ | Starting MutualChats module. Waiting for local player's chat groups to load...")

    self:StartPlayersEvents()
end

--// Module Exporting
return MutualChats