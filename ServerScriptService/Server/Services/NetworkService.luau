--[[
 - @ Author: flora
 - @ Create Time: 2026-03-01 23:30:27
 - @ Modified by: flora
 - @ Modified time: 2026-03-01 23:40:14
 - @ Description: Sunucu tarafında custom (özelleştirilmiş) network (ağ) servisi.
]]

--// Types
export type Connection = {
    Disconnect: () -> ()
}

export type Network = {
    Name: string,
    _onFire: {(...any) -> (any?)},
    OnFire: (self: Network, callback: (...any) -> (any?)) -> Connection?,
    Fire: (self: Network, ...any) -> ()
}

--// Network Object Class
local Network = {}
Network.__index = Network

function Network:OnFire(callback: (...any) -> (any?)): Connection?
    if typeof(callback) ~= "function" then
        warn(`⚠️ | {self.Name}: Callback is not a function.`) 
        return nil
    end

    table.insert(self._onFire, callback)

    return {
        Disconnect = function()
            local index = table.find(self._onFire, callback)
            if index then
                table.remove(self._onFire, index)
            end
        end
    }
end

function Network:Fire(...)
    local callbacks = table.clone(self._onFire)
    for _, callback in callbacks do
        callback(...)
    end
end

--// Module
local NetworkService = {
    Name = "NetworkService",
    Dependencies = {},
    _networks = {} :: { [string]: Network }
}

--// Functions
function NetworkService.New(name: string): Network?
    if NetworkService._networks[name] then
        warn(`⚠️ | {NetworkService.Name}: Network {name} already exists.`) 
        return nil
    end

    local network = setmetatable({
        Name = name,
        _onFire = {}
    }, Network)

    NetworkService._networks[name] = network

    return network
end

function NetworkService.Get(name: string): Network?
    local network = NetworkService._networks[name]
    if not network then
        warn(`⚠️ | {NetworkService.Name}: Network {name} does not exist.`)
    end
    return network
end

function NetworkService:Init()
end

--// Module Exporting
return NetworkService