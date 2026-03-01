--[[
 - @ Author: flora
 - @ Create Time: 2026-02-22 21:55:02
 - @ Modified by: flora
 - @ Modified time: 2026-03-01 23:44:54
 - @ Description: Net modülü, istemci ve sunucu arasında iletişim kurmak için kullanılan bir ağ (network) modülüdür. 
]]

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--// Config
local IS_SERVER = RunService:IsServer()
local IS_CLIENT = RunService:IsClient()

--// Module
local Net = {
	_events = {},
	_functions = {},
	_connections = {}
}

--// Functions
local function getRemoteEvent(self: any, remoteName: string): RemoteEvent?
	local remote = self._events[remoteName]
	if not remote then
		warn(`⚠️ | Remote event "{remoteName}" not found.`)
		return nil
	end
	return remote
end

local function getRemoteFunction(self: any, remoteName: string): RemoteFunction?
	local remote = self._functions[remoteName]
	if not remote then
		warn(`⚠️ | Remote function "{remoteName}" not found.`)
		return nil
	end
	return remote
end

function Net:FireClient(remoteName: string, player: Player, ...: any?)
	if not IS_SERVER then
		return
	end
	
	local remoteEvent = getRemoteEvent(self, remoteName)
	if remoteEvent then
		remoteEvent:FireClient(player, ...)
	end
end

function Net:FireAllClients(remoteName: string, ...: any?)
	if not IS_SERVER then
		print(`⚠️ | Attempted to fire remote event "{remoteName}" to all clients from the client side. This action is not allowed.`)
		return
	end

	local remoteEvent = getRemoteEvent(self, remoteName)

	print(`ℹ️ | Firing remote event "{remoteName}" to all clients with arguments:`, ...)

	if remoteEvent then
		remoteEvent:FireAllClients(...)
	end
end

function Net:FireServer(remoteName: string, ...: any?)
	if not IS_CLIENT then
		return
	end
	
	local remoteEvent = getRemoteEvent(self, remoteName)
	if remoteEvent then
		remoteEvent:FireServer(...)
	end
end

function Net:InvokeServer(remoteName: string, ...: any?)
	if not IS_CLIENT then
		return
	end
	
	local remoteFunction = getRemoteFunction(self, remoteName)
	if remoteFunction then
		return remoteFunction:InvokeServer(...)
	end
end

function Net:BindServerEvent(selfData: any, remoteName: string, callback: (selfData: any, player: Player, ...any) -> ())
	if not IS_SERVER then
		return
	end
	
	local remoteEvent = getRemoteEvent(self, remoteName)
	if not remoteEvent then
		return nil
	end
	
	local connection = remoteEvent.OnServerEvent:Connect(function(player: Player, ...)
		callback(selfData, player, ...)
	end)
	
	if not self._connections[remoteName] then
		self._connections[remoteName] = {}
	end
	table.insert(self._connections[remoteName], connection)
	
	return connection
end

function Net:BindClientEvent(remoteName: string, callback: (selfData: any, ...any?) -> (), selfData: any)
	if not IS_CLIENT then
		return
	end
	
	local remoteEvent = getRemoteEvent(self, remoteName)
	if not remoteEvent then
		return nil
	end
	
	local connection = remoteEvent.OnClientEvent:Connect(function(...: any?)
		callback(selfData, ...)
	end)
	
	if not self._connections[remoteName] then
		self._connections[remoteName] = {}
	end
	table.insert(self._connections[remoteName], connection)
	
	return connection
end

function Net:BindServerFunction(selfData: any, remoteName: string, callback: (selfData: any, player: Player, ...any?) -> any?)
	if not IS_SERVER then
		return
	end
	
	local remoteFunction = getRemoteFunction(self, remoteName)
	if remoteFunction then
		remoteFunction.OnServerInvoke = function(player: Player, ...)
			return callback(selfData, player, ...)
		end
	end
end

function Net:Disconnect(remoteName: string)
	if self._connections[remoteName] then
		for _, connection in self._connections[remoteName] do
			connection:Disconnect()
		end
		self._connections[remoteName] = nil
	end
end

function Net:DisconnectAll()
	for remoteName, connections in self._connections do
		for _, connection in connections do
			connection:Disconnect()
		end
	end
	self._connections = {}
end

function Net:Init()
	print(`ℹ️ | Initializing Net on the {if IS_SERVER then "server" else "client"} side.`)
	
	local remotesFolder = ReplicatedStorage:WaitForChild("Framework"):WaitForChild("Shared"):WaitForChild("Remotes")
	local eventsFolder = remotesFolder:FindFirstChild("Events")
	local functionsFolder = remotesFolder:FindFirstChild("Functions")
	
	if functionsFolder then
		for _, remoteFunction in functionsFolder:GetChildren() do
			if remoteFunction:IsA("RemoteFunction") then
				self._functions[remoteFunction.Name] = remoteFunction
			end
		end
	end
	
	if eventsFolder then
		for _, remoteEvent in eventsFolder:GetChildren() do
			if remoteEvent:IsA("RemoteEvent") then
				self._events[remoteEvent.Name] = remoteEvent
			end
		end
	end
end

--// Module Exporting
return Net