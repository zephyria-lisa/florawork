--[[
 - @ Author: flora
 - @ Create Time: 2026-02-22 20:09:03
 - @ Modified by: flora
 - @ Modified time: 2026-02-28 18:26:24
 - @ Description: Hem istemci hem de sunucu tarafında yazım hatalarının önüne geçmek için bir enum modülü.
]]

--// Module
local Attributes = {
    Player = {
        IS_LOADED = "_Isloaded",
        IS_BEING_TELEPORTED = "_IsBeingTeleported",
        GROUP_RANK = "_GroupRank",
        CHAT_GROUPS_LOADED = "_ChatGroupsLoaded",
        CHAT_GROUPS = "_ChatGroups",
    }
}

--// Module Exporting
return Attributes