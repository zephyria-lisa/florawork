--[[
 - @ Author: flora
 - @ Create Time: 2026-03-01 18:18:14
 - @ Modified by: flora
 - @ Modified time: 2026-03-01 22:16:43
 - @ Description: Kolay liderlik tablosu sistemi. Projelere kolayca entegre edilebilir.
]]

--// Services
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules
local Attributes = require(ReplicatedStorage.Framework.Shared.Config.Attributes)
local LeaderboardConfig = require(ReplicatedStorage.Framework.Server.Config.LeaderboardConfig)

--// Module
local EasyLeaderboard = {
    Name = "EasyLeaderboard",
    Dependencies = {
        DataService = "DataService",
    },
}

--// Functions
function EasyLeaderboard:UpdateLeaderboards()
    for _, leaderboardData in LeaderboardConfig.LEADERBOARD_DATA do
       local datastore = self._datastores[leaderboardData.DataKey]

        if not datastore then
            warn(`⚠️ | Datastore not found for leaderboard data key: {leaderboardData.DataKey}`)
            continue
        end

        local currentPlayers = Players:GetPlayers()
        
        for _, player in currentPlayers do
            if not player:GetAttribute(Attributes.Player.IS_LOADED) then
                continue
            end

            local playerData = self.DataService:GetValue(player, leaderboardData.DataKey)

            if not playerData then
                warn(`⚠️ | Player data not found for leaderboard data key: {leaderboardData.DataKey}`)
                continue
            end
            
            task.spawn(function()
                local numericData = tonumber(playerData)
                if not numericData then
                    warn(`⚠️ | Error: leaderboard data for {leaderboardData.DataKey} must be a number! Data type: {typeof(playerData)}`)
                    return
                end

                numericData = math.floor(numericData)

                local success, err = pcall(function()
                    datastore:SetAsync(tostring(player.UserId), numericData)
                end)

                if not success then
                    warn(`⚠️ | Failed to set leaderboard data for player: {player.Name} | Error: {err}`)
                    return
                end

                print(`✅ | Set leaderboard data for player: {player.Name} | {leaderboardData.DataKey} | {numericData}`)
            end)
        end
    end
end

function EasyLeaderboard:GetLeaderboardData(dataKey: string, pageSize: number?)
    local datastore = self._datastores[dataKey]

    if not datastore then
        warn(`⚠️ | Datastore not found for leaderboard data key: {dataKey}`)
        return nil
    end

    local success, pagesOrErr = pcall(function()
        local minVal = if LeaderboardConfig.MIN_VALUE == math.huge then nil else LeaderboardConfig.MIN_VALUE
        local maxVal = if LeaderboardConfig.MAX_VALUE == math.huge then nil else LeaderboardConfig.MAX_VALUE

        return datastore:GetSortedAsync(
            false,
            pageSize or LeaderboardConfig.DEFAULT_PAGE_SIZE,
            minVal,
            maxVal
        )
    end)

    if not success then
        warn(`⚠️ | Failed to get leaderboard data for data key: {dataKey} | Error: {pagesOrErr}`)
        return nil
    end

    return pagesOrErr:GetCurrentPage()
end

function EasyLeaderboard:Init()
    self._datastores = {}

    for _, leaderboardData in LeaderboardConfig.LEADERBOARD_DATA do
        self._datastores[leaderboardData.DataKey] = DataStoreService:GetOrderedDataStore(leaderboardData.DataKey .. "_Leaderboard")
    end
end

function EasyLeaderboard:Start()    
    task.spawn(function()
        while task.wait(LeaderboardConfig.UPDATE_DURATION) do
            self:UpdateLeaderboards()
        end
    end)
end

--// Module Exporting
return EasyLeaderboard
