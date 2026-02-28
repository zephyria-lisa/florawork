--[[
 - @ Author: flora
 - @ Create Time: 2026-02-22 21:55:02
 - @ Modified by: flora
 - @ Modified time: 2026-02-28 18:26:29
 - @ Description: Net modülü, istemci ve sunucu arasında iletişim kurmak için kullanılan bir ağ (network) modülüdür. 
]]

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--// Config
local IS_SERVER = RunService:IsServer()
local IS_CLIENT = RunService:IsClient()

--// Module
local Net = {}

--// Private properties
Net._events = {}
Net._functions = {}
Net._connections = {}

--// Helper functions

--- Validates if a remote event exists and returns it
local function getRemoteEvent(self: any, remoteName: string): RemoteEvent?
	local remote = self._events[remoteName]
	if not remote then
		warn(`⚠️ | Remote event "{remoteName}" not found.`)
		return nil
	end
	return remote
end

--- Validates if a remote function exists and returns it
local function getRemoteFunction(self: any, remoteName: string): RemoteFunction?
	local remote = self._functions[remoteName]
	if not remote then
		warn(`⚠️ | Remote function "{remoteName}" not found.`)
		return nil
	end
	return remote
end

--// Fire Events

--- Fires a remote event to a specific client (Server only)
function Net:FireClient(remoteName: string, player: Player, ...: any?)
	if not IS_SERVER then
		return
	end
	
	local remoteEvent = getRemoteEvent(self, remoteName)
	if remoteEvent then
		remoteEvent:FireClient(player, ...)
	end
end

--- Fires a remote event to all clients (Server only)
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

--- Fires a remote event to the server (Client only)
function Net:FireServer(remoteName: string, ...: any?)
	if not IS_CLIENT then
		return
	end
	
	local remoteEvent = getRemoteEvent(self, remoteName)
	if remoteEvent then
		remoteEvent:FireServer(...)
	end
end

--// Invoke Functions

--- Invokes a remote function on the server (Client only)
function Net:InvokeServer(remoteName: string, ...: any?)
	if not IS_CLIENT then
		return
	end
	
	local remoteFunction = getRemoteFunction(self, remoteName)
	if remoteFunction then
		return remoteFunction:InvokeServer(...)
	end
end

--// Event Binding

--- Binds a callback to a server event (Server only)
--- Returns the connection so it can be disconnected later
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
	
	-- Track connection for cleanup
	if not self._connections[remoteName] then
		self._connections[remoteName] = {}
	end
	table.insert(self._connections[remoteName], connection)
	
	return connection
end

--- Binds a callback to a client event (Client only)
--- Returns the connection so it can be disconnected later
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
	
	-- Track connection for cleanup
	if not self._connections[remoteName] then
		self._connections[remoteName] = {}
	end
	table.insert(self._connections[remoteName], connection)
	
	return connection
end

--- Binds a callback to a server function (Server only)
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

--// Cleanup

--- Disconnects all connections for a specific remote
function Net:Disconnect(remoteName: string)
	if self._connections[remoteName] then
		for _, connection in self._connections[remoteName] do
			connection:Disconnect()
		end
		self._connections[remoteName] = nil
	end
end

--- Disconnects all connections
function Net:DisconnectAll()
	for remoteName, connections in self._connections do
		for _, connection in connections do
			connection:Disconnect()
		end
	end
	self._connections = {}
end

--// Initialization

function Net:Init()
	print(`ℹ️ | Initializing Net on the {if IS_SERVER then "server" else "client"} side.`)
	
	-- Load remotes folder
	local remotesFolder = ReplicatedStorage:WaitForChild("Framework"):WaitForChild("Shared"):WaitForChild("Remotes")
	local eventsFolder = remotesFolder:FindFirstChild("Events")
	local functionsFolder = remotesFolder:FindFirstChild("Functions")
	
	-- Load remote functions
	if functionsFolder then
		for _, remoteFunction in functionsFolder:GetChildren() do
			if remoteFunction:IsA("RemoteFunction") then
				self._functions[remoteFunction.Name] = remoteFunction
			end
		end
	end
	
	-- Load remote events
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