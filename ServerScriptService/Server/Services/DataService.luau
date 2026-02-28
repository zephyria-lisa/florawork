--[[
 - @ Author: flora
 - @ Create Time: 2026-02-22 21:26:42
 - @ Modified by: flora
 - @ Modified time: 2026-02-28 18:25:42
 - @ Description: Suucu tarafı için veri yönetimi servisi.
 ]]

--// Services
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

--// Modules
local Attributes = require(ReplicatedStorage.Framework.Shared.Config.Attributes)
local DataConfig = require(ServerScriptService.Server.Config.DataConfig)

--// Module
local DataService = {
    Name = "DataService",
    Dependencies = {}
}

--// Functions
function DataService:Init()
    self._playerDataStore = DataStoreService:GetDataStore(DataConfig.playerDataKey)
    self._playerDatas = {}
end

function DataService:SavePlayer(player: Player): boolean
    if not player:GetAttribute(Attributes.Player.IS_LOADED) then
        warn(`⚠️ | {self.Name}: Attempted to save data for player {player.Name} who is not fully loaded.`)
        return false
    end

    if player:GetAttribute(Attributes.Player.IS_BEING_TELEPORTED) then
        warn(`⚠️ | {self.Name}: Attempted to save data for player {player.Name} who is currently teleporting.`)
        return false
    end

    local playerData = self._playerDatas[player.UserId]
    if not playerData then
        warn(`⚠️ | {self.Name}: No data found for player {player.Name} when attempting to save.`)
        return false
    end

    local success, errorMessage = pcall(function()
        self._playerDataStore:UpdateAsync(player.UserId, function(oldData)
            local newData = if typeof(oldData) == "table" then oldData else {}
            
            for key, value in playerData do
                newData[key] = value
            end
            
            return newData
        end)
    end)

    if not success then
        warn(`⚠️ | {self.Name}: Failed to save data for player {player.Name}. Error: {errorMessage}`)
        return false
    end

    print(`✅ | {self.Name}: Successfully saved data for player {player.Name}.`)

    return true
end

function DataService:LoadPlayer(player: Player): boolean
    local success, data = pcall(function()
        return self._playerDataStore:GetAsync(player.UserId)
    end)

    if not data then
        data = DataConfig.defaultValues
    end

    if not success then
        warn(`⚠️ | {self.Name}: Failed to load data for player {player.Name}. Error: {data}`)
        return false
    end

    for key, defaultValue in DataConfig.defaultValues do
        if data[key] == nil then
            data[key] = defaultValue
        end
    end

    for key, folderName in DataConfig.folderStructure do
        if data[key] then
            local folder = player:FindFirstChild(folderName) or Instance.new("Folder")
            folder.Name = folderName
            folder.Parent = player

            local valueObject = nil
            if typeof(data[key]) == "number" then
                valueObject = Instance.new("NumberValue")
            elseif typeof(data[key]) == "string" then
                valueObject = Instance.new("StringValue")
            elseif typeof(data[key]) == "boolean" then
                valueObject = Instance.new("BoolValue")
            else
                warn(`⚠️ | {self.Name}: Unsupported data type for key {key} in player {player.Name}'s data.`)
                continue
            end

            valueObject.Name = key
            valueObject.Value = data[key]
            valueObject.Parent = folder
        end
    end

    self._playerDatas[player.UserId] = data or DataConfig.defaultValues

    player:SetAttribute(Attributes.Player.IS_LOADED, true)
    return true
end

function DataService:GetValue(player: Player, key: string): any
    local playerData = self._playerDatas[player.UserId]
    if not playerData then
        warn(`⚠️ | {self.Name}: No data found for player {player.Name} when attempting to get value for key {key}.`)
        return nil
    end

    return playerData[key]
end

function DataService:SetValue(player: Player, key: string, value: any): boolean
    local playerData = self._playerDatas[player.UserId]
    if not playerData then
        warn(`⚠️ | {self.Name}: No data found for player {player.Name} when attempting to set value for key {key}.`)
        return false
    end

    playerData[key] = value

    local folderName = DataConfig.folderStructure[key]
    if folderName then
        local folder = player:FindFirstChild(folderName)
        if folder then
            local valueObject = folder:FindFirstChild(key)
            if valueObject then
                valueObject.Value = value
            else
                warn(`⚠️ | {self.Name}: No value object found for key {key} in player {player.Name}'s folder {folderName}.`)
            end
        else
            warn(`⚠️ | {self.Name}: No folder named {folderName} found for player {player.Name} when attempting to set value for key {key}.`)
        end
    end

    return true
end

function DataService:AddValue(player: Player, key: string, amount: number): boolean
    local currentValue = self:GetValue(player, key)
    if typeof(currentValue) ~= "number" then
        warn(`⚠️ | {self.Name}: Attempted to add value to key {key} for player {player.Name}, but current value is not a number.`)
        return false
    end

    return self:SetValue(player, key, currentValue + amount)
end

--// Module Exporting
return DataService