--[[
 - @ Author: flora
 - @ Create Time: 2026-02-24 23:21:12
 - @ Modified by: flora
 - @ Modified time: 2026-02-28 18:25:48
 - @ Description: Sunucu tarafında komutların konfigürasyonunu ve yönetimini sağlayan modül. Hangi komutların mevcut olduğunu, bu komutların hangi yetkilere sahip oyuncular tarafından kullanılabileceğini ve komutların nasıl çalışacağını tanımlar.
]]

--// Module
local CommandModule = {
    RANKS = {
        Owner = 250,
        Moderator = 52,
        Tester = 11,
    },
    PREFIX = "!",
}

--// Module Exporting
return CommandModule