--[[
 - @ Author: flora
 - @ Create Time: 2026-02-22 21:39:08
 - @ Modified by: flora
 - @ Modified time: 2026-02-28 18:25:24
 - @ Description: DataService ve diğer veri yönetimi modülleri için ortak konfigürasyon dosyası.
]]

--// Module
local DataConfig = {
    playerDataKey = "PlayerData",
    defaultValues = {
        Coins = 0,
        Level = 1,
        Experience = 0,
    },
    folderStructure = {
        Coins = "leaderstats",
        Level = "leaderstats",
    }
}

--// Module Exporting
return DataConfig 