--[[
 - @ Author: flora
 - @ Create Time: 2026-02-23 23:19:22
 - @ Modified by: flora
 - @ Modified time: 2026-02-28 20:53:09
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
local Assets = ReplicatedStorage:WaitForChild("Assets")
local BillboardTemplate = Assets:WaitForChild("MutualChatBillboard")

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

    local success, result = pcall(function()
        return HttpService:JSONDecode(playerChatGroups)
    end)

    if success then
        return result
    else
        warn(`⚠️ | Failed to decode chat groups for {player.Name}`)
        return {}
    end
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

    local head = character:WaitForChild("Head", 5)
    if not head then return end

    local billboardClone = BillboardTemplate:Clone()
    billboardClone.Parent = head
    billboardClone.Adornee = head
end

function MutualChats:HandlePlayer(player: Player)
    -- Check if the player is ready, wait with timeout to prevent memory leak
    if not player:GetAttribute(Attributes.Player.CHAT_GROUPS_LOADED) then
        local connection
        local bindable = Instance.new("BindableEvent")
        
        connection = player:GetAttributeChangedSignal(Attributes.Player.CHAT_GROUPS_LOADED):Connect(function()
            if player:GetAttribute(Attributes.Player.CHAT_GROUPS_LOADED) then
                bindable:Fire()
            end
        end)
        
        -- Fallback in case they leave or it takes too long
        task.delay(10, function() bindable:Fire() end)
        bindable.Event:Wait()
        connection:Disconnect()
        bindable:Destroy()
        
        -- If they left and destroyed
        if not player.Parent then return end
    end

    print(`ℹ️ | Checking player {player.Name} for mutual chat status...`)

    local function checkCharacter(character)
        print(`ℹ️ | Player {player.Name}'s character has loaded. Checking mutual chat status...`)
        
        if self:LocalPlayerCanChatWith(player) then
            print(`✅ | Local player can chat with {player.Name}.`)
        else
            print(`❌ | Local player cannot chat with {player.Name}. Attaching billboard...`)
            self:AttachBillboardToCharacter(character)
        end
    end

    if player.Character then
        task.spawn(checkCharacter, player.Character)
    end

    player.CharacterAdded:Connect(checkCharacter)
end

function MutualChats:StartPlayersEvents()
    if not localPlayer:GetAttribute(Attributes.Player.CHAT_GROUPS_LOADED) then
        print("ℹ️ | Waiting for local player's chat groups to load...")
        localPlayer:GetAttributeChangedSignal(Attributes.Player.CHAT_GROUPS_LOADED):Wait()
    end

    print("ℹ️ | Local player's chat groups have been loaded. MutualChats is now active.")

    Players.PlayerAdded:Connect(function(player)
        self:HandlePlayer(player)
    end)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            task.spawn(function()
                self:HandlePlayer(player)
            end)
        end
    end
end

function MutualChats:Start()
    print("ℹ️ | Starting MutualChats module. Waiting for local player's chat groups to load...")
    self:StartPlayersEvents()
end

--// Module Exporting
return MutualChats