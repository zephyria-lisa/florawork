--[[
 - @ Author: flora
 - @ Create Time: 2026-03-01 18:18:48
 - @ Modified by: flora
 - @ Modified time: 2026-03-01 23:40:34
 - @ Description: EasyLeaderboard için konfigürasyon dosyası.
]]

--// Types
export type LeaderboardData = {
    DataKey: string,
}

--// Module
local LeaderboardConfig = {
    -- How often the leaderboard updates in seconds.
    UPDATE_DURATION = 60,
    -- Default page size for the leaderboard.
    DEFAULT_PAGE_SIZE = 100,
    -- Minimum value for the leaderboard.
    MIN_VALUE = 1,
    -- Maximum value for the leaderboard.
    MAX_VALUE = math.huge,
    -- The data keys to use for the leaderboard.
    LEADERBOARD_DATA = {
        {
            DataKey = "Coins",
        },
        {
            DataKey = "Level",
        },
    } :: { LeaderboardData }
}

--// Module Exporting
return LeaderboardConfig