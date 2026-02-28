--[[
 - @ Author: flora
 - @ Create Time: 2026-02-26 22:40:00
 - @ Modified by: flora
 - @ Modified time: 2026-02-28 18:25:30
 - @ Description: AnalyticsService kullanımını kolayaştıran modül. Oyun içi olayları, oyuncu davranışlarını ve diğer önemli metrikleri takip etmek ve analiz etmek için kullanılır. Bu modül, oyun performansını artırmak, oyuncu deneyimini geliştirmek ve oyun içi kararları desteklemek için veri toplama ve analiz süreçlerini yönetir.
]]

--// Services
local AnalyticsService = game:GetService("AnalyticsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules
local Attributes = require(ReplicatedStorage.Framework.Shared.Config.Attributes)

--// Module
local EasyAnalytics = {
    Name = "EasyAnalytics",
    Dependencies = {
        DataService = "DataService",
    },
}

--// Functions
function EasyAnalytics:ChangeDataValueUsingEconomy(
    player: Player, 
    key: string, 
    changeAmount: number, 
    transactionType: Enum.AnalyticsEconomyTransactionType | string,
    flowType: Enum.AnalyticsEconomyFlowType,
    customFields: { [string]: any }?,
    sku: string?
)
    if not player or not player:IsA("Player") then
        warn("⚠️ | Invalid player provided to ChangeDataValueUsingEconomy.")
        return false
    end

    if not player:GetAttribute(Attributes.Player.IS_LOADED) then
        warn(`⚠️ | Player {player.Name} is not fully loaded. Cannot change data value.`)
        return false
    end

    local currentValue = self.DataService:GetValue(player, key)

    if not currentValue then
        warn(`⚠️ | No current value found for player {player.Name} and key "{key}". Cannot change data value.`)
        return false
    end
    
    local newValue = currentValue + changeAmount 
    
    local status = self.DataService:SetValue(player, key, newValue)

    if not status then
        warn(`⚠️ | Failed to set new value for player {player.Name} and key "{key}". Change amount: {changeAmount}.`)
        return false
    end

    local success, errorMessage = pcall(function()
        AnalyticsService:LogEconomyEvent(
            player,
            flowType,
            key,
            changeAmount,
            newValue,
            transactionType,
            nil,
            customFields,
            sku
        )
    end)

    if not success then
        warn(`⚠️ | Failed to log economy event for player (still succeeded to set data value){player.Name}. Error: {errorMessage}`)
        return false
    end

    print(`✅ | Successfully changed data value for player {player.Name} and key "{key}". Change amount: {changeAmount}, New value: {newValue}. Logged economy event successfully.`)

    return true
end

function EasyAnalytics:ForceCustomEvent(player: Player, eventName: string, value: number, customFields: { [string]: any }?)
    if not player or not player:IsA("Player") then
        warn("⚠️ | Invalid player provided to ForceCustomEvent.")
        return false
    end

    for i = 1, 5 do
        local success, errorMessage = pcall(function()
            AnalyticsService:LogCustomEvent(player, eventName, value, customFields)
        end)

        if success then
            print(`✅ | Successfully logged custom event for player {player.Name}. Event name: "{eventName}", Value: {value}. Attempt {i}`)
            return true
        else
            warn(`⚠️ | Attempt {i} to log custom event failed for player {player.Name}. Event: "{eventName}", Value: {value}. Error: {errorMessage}`)
            task.wait(1 + 0.5 * i)
        end
    end

    warn(`⚠️ | All attempts to log custom event failed for player {player.Name}. Event name: "{eventName}", Value: {value}.`)
    return false
end

--// Module Exporting
return EasyAnalytics