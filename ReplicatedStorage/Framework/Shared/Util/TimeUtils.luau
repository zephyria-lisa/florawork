--[[
 - @ Author: flora
 - @ Create Time: 2026-02-28 21:07:32
 - @ Modified by: flora
 - @ Modified time: 2026-02-28 21:12:12
 - @ Description: Zaman biçimlendirme ve hesaplama işlemleri için yardımcı fonksiyonlar içerir (İngilizce/Türkçe destekli).
]]

--// Module
local TimeUtils = {}

--// Constants
local MINUTE_IN_SECONDS = 60
local HOUR_IN_SECONDS = 3600
local DAY_IN_SECONDS = 86400

--// Functions
function TimeUtils.FormatToMMSS(seconds: number): string
    seconds = math.max(0, math.floor(seconds))
    local minutes = math.floor(seconds / MINUTE_IN_SECONDS)
    local remainingSeconds = seconds % MINUTE_IN_SECONDS
    
    return string.format("%02d:%02d", minutes, remainingSeconds)
end

function TimeUtils.FormatToHHMMSS(seconds: number): string
    seconds = math.max(0, math.floor(seconds))
    local hours = math.floor(seconds / HOUR_IN_SECONDS)
    local minutes = math.floor((seconds % HOUR_IN_SECONDS) / MINUTE_IN_SECONDS)
    local remainingSeconds = seconds % MINUTE_IN_SECONDS
    
    return string.format("%02d:%02d:%02d", hours, minutes, remainingSeconds)
end

function TimeUtils.FormatToShortDHMS(seconds: number): string
    seconds = math.max(0, math.floor(seconds))
    
    if seconds == 0 then
        return "0s"
    end
    
    local days = math.floor(seconds / DAY_IN_SECONDS)
    local hours = math.floor((seconds % DAY_IN_SECONDS) / HOUR_IN_SECONDS)
    local minutes = math.floor((seconds % HOUR_IN_SECONDS) / MINUTE_IN_SECONDS)
    local remainingSeconds = seconds % MINUTE_IN_SECONDS
    
    local parts = {}
    
    if days > 0 then table.insert(parts, string.format("%dd", days)) end
    if hours > 0 then table.insert(parts, string.format("%dh", hours)) end
    if minutes > 0 then table.insert(parts, string.format("%dm", minutes)) end
    if remainingSeconds > 0 or #parts == 0 then 
        table.insert(parts, string.format("%ds", remainingSeconds)) 
    end
    
    return table.concat(parts, " ")
end

function TimeUtils.GetTimeSince(unixTimestamp: number, useTurkish: boolean?): string
    local currentTimestamp = os.time()
    local difference = currentTimestamp - unixTimestamp
    
    if difference < 0 then
        return if useTurkish then "gelecekte" else "in the future"
    end
    
    if difference < MINUTE_IN_SECONDS then
        return if useTurkish then "az önce" else "just now"
    end
    
    if difference < HOUR_IN_SECONDS then
        local mins = math.floor(difference / MINUTE_IN_SECONDS)
        return if useTurkish then string.format("%d dakika önce", mins) else string.format("%d minutes ago", mins)
    end
    
    if difference < DAY_IN_SECONDS then
        local hrs = math.floor(difference / HOUR_IN_SECONDS)
        return if useTurkish then string.format("%d saat önce", hrs) else string.format("%d hours ago", hrs)
    end
    
    local days = math.floor(difference / DAY_IN_SECONDS)
    return if useTurkish then string.format("%d gün önce", days) else string.format("%d days ago", days)
end

function TimeUtils.GetElapsedSeconds(startTick: number): number
    return math.max(0, os.clock() - startTick)
end

--// Module Exporting
return TimeUtils