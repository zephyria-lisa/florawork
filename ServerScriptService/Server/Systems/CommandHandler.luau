--[[
 - @ Author: flora
 - @ Create Time: 2026-02-24 23:23:48
 - @ Modified by: flora
 - @ Modified time: 2026-02-28 18:25:53
 - @ Description: Oyuncuların kullandıkları komutları işleyen ve bu komutlara göre aksiyon alan modül. Komutların tanımlanması, hangi oyuncuların hangi komutları kullanabileceği ve komutların nasıl çalışacağı gibi özellikleri yönetir.
 ]
]]

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

--// Modules
local Attributes = require(ReplicatedStorage.Framework.Shared.Config.Attributes)
local CommandConfig = require(ServerScriptService.Server.Config.CommandConfig)

--// Module
local CommandHandler = {
    Name = "CommandHandler",
    Dependencies = {
        PlayerHandler = "PlayerHandler",
    },
    Commands = {
        test = {
            ArgumentsRequired = 1,
            RequiredRank = CommandConfig.RANKS.Tester,
        },
        kick = {
            ArgumentsRequired = 1,
            RequiredRank = CommandConfig.RANKS.Moderator,
        },
    }
}

--// Command Functions
local function testCommand(player: Player, args: { string }, fullMessage: string)
    print(`Test command executed by {player.Name}. Args: {table.concat(args, ", ")}. Full Message: {fullMessage}`)
    return "Test command executed successfully."
end

local function kickCommand(player: Player, args: { string }, fullMessage: string)
    local targetPlayerName = args[1]
    local targetPlayer = CommandHandler.PlayerHandler:FindPlayer(targetPlayerName)
    local reason = fullMessage[#targetPlayerName + 2]
    if #reason == 0 then
        reason = "No reason provided."
    end

    if not targetPlayer then
        return `Player "{targetPlayerName}" not found.`
    end

    local targetRank = targetPlayer:GetAttribute(Attributes.Player.GROUP_RANK) or 0
    local playerRank = player:GetAttribute(Attributes.Player.GROUP_RANK) or 0

    if targetRank >= playerRank then
        return `You cannot kick {targetPlayer.Name} because their rank is equal to or higher than yours.`
    end

    targetPlayer:Kick(`You have been kicked by {player.Name}. Reason: {fullMessage}`)
    return `Player "{targetPlayer.Name}" has been kicked.`
end

--// Main Functions
function CommandHandler:BindCommandFunctions(functions: { [string]: (Player, { string }, ...any) -> (string) })
    for comandName, commandFunction in pairs(functions) do
        if not self.Commands[comandName] then
            warn(`⚠️ | Attempted to bind function for undefined command: {comandName}`)
            continue
        end

        self.Commands[comandName].Function = commandFunction
    end
end

function CommandHandler:HandlePlayerChatted(player: Player)
    local playerRank = player:GetAttribute(Attributes.Player.GROUP_RANK)

    player.Chatted:Connect(function(message: string)
        if not message:lower()[1] == CommandConfig.PREFIX then
            return
        end

        local args = message:sub(#CommandConfig.PREFIX + 1):split(" ")
        local commandName = args[1]:lower()
        table.remove(args, 1)

        local commandInfo = self.Commands[commandName]
        if not commandInfo then
            warn(`⚠️ | Player {player.Name} attempted to use undefined command: {commandName}`)
            return
        end

        if playerRank < commandInfo.RequiredRank then
            warn(`⚠️ | Player {player.Name} attempted to use command {commandName} without sufficient rank. Required: {commandInfo.RequiredRank}, Player Rank: {playerRank}`)
            return
        end

        if not commandInfo.Function then
            warn(`⚠️ | Command {commandName} does not have a function bound to it.`)
            return
        end

        if #args < commandInfo.ArgumentsRequired then
            warn(`⚠️ | Player {player.Name} attempted to use command {commandName} with insufficient arguments. Required: {commandInfo.ArgumentsRequired}, Provided: {#args}`)
            return
        end

        local messageWithoutCommandPrefix = message:sub(#CommandConfig.PREFIX + #commandName + 2)

        local statusMessage = commandInfo.Function(player, args, messageWithoutCommandPrefix)

        print(`ℹ️ | Player {player.Name} executed command {commandName}. Status: {statusMessage}`)
    end)
end

function CommandHandler:Init()
    self:BindCommandFunctions({
        test = testCommand,
        kick = kickCommand,
    })
end

--// Module Exporting
return CommandHandler