--[[
 - @ Author: flora
 - @ Create Time: 2026-02-23 22:58:57
 - @ Modified by: flora
 - @ Modified time: 2026-02-28 18:26:21
 - @ Description: İstemci tarafı olayları yöneten modül. Oyuncuların sunucu ile iletişim kuracağı istemci tarafı modülü.
]]

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Assets
local remotesFolder = ReplicatedStorage:WaitForChild("Framework"):WaitForChild("Shared"):WaitForChild("Remotes")

--// Module
local ClientEvents = {
    Name = "ClientEvents",
}

--// Events Functions
local function printTest(...)
    print("Test function called with arguments:", ...)
end

--// Functions
function ClientEvents:BindRemoteEvents(eventsTable: { [string]: (...any?) -> (...any?) })
    if not self._remoteEvents then
        self._remoteEvents = {}
    end

    for eventName, callback in pairs(eventsTable) do
        local remoteEvent = remotesFolder:FindFirstChild("Events"):FindFirstChild(eventName)
        if not remoteEvent then
            warn(`⚠️ | Remote event "{eventName}" not found in ReplicatedStorage.Framework.Shared.Remotes.`)
            continue
        end

        if not remoteEvent:IsA("RemoteEvent") then
            warn(`⚠️ | "{eventName}" in ReplicatedStorage.Framework.Shared.Remotes is not a RemoteEvent.`)
            continue
        end

        remoteEvent.OnClientEvent:Connect(function(...)
            callback(...)
        end)

        self._remoteEvents[eventName] = remoteEvent
    end
end

function ClientEvents:BindRemoteFunctions(functionsTable: { [string]: (...any?) -> (...any?) })
    if not self._remoteFunctions then
        self._remoteFunctions = {}
    end

    for functionName, callback in pairs(functionsTable) do
        local remoteFunction = remotesFolder:FindFirstChild("Functions"):FindFirstChild(functionName)
        if not remoteFunction then
            warn(`⚠️ | Remote function "{functionName}" not found in ReplicatedStorage.Framework.Shared.Remotes.`)
            continue
        end

        if not remoteFunction:IsA("RemoteFunction") then
            warn(`⚠️ | "{functionName}" in ReplicatedStorage.Framework.Shared.Remotes is not a RemoteFunction.`)
            continue
        end

        remoteFunction.OnClientInvoke = function(...)
            return callback(...)
        end

        self._remoteFunctions[functionName] = remoteFunction
    end
end

function ClientEvents:Start()
    self:BindRemoteEvents({
        TestEvent = printTest,
    })
end

--// Module Exporting
return ClientEvents
