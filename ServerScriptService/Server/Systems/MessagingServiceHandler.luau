--[[
 - @ Author: flora
 - @ Create Time: 2026-02-22 21:59:43
 - @ Modified by: flora
 - @ Modified time: 2026-02-28 18:25:59
 - @ Description: MessagingServiceHandler, Roblox'un MessagingService'ını kullanarak sunucu tarafında mesajlaşma işlemlerini yöneten bir modüldür. 
   Konfigürasyondan alınan topic'lere abone olur ve mesaj yayınlama işlevselliği sağlar.
]]

--// Services
local MessagingService = game:GetService("MessagingService")

--// Config
local MessagingConfig = require(script.Parent.Parent.Config.MessagingConfig)

--// Module
local MessagingServiceHandler = {}

--// Private properties
MessagingServiceHandler._subscriptions = {}
MessagingServiceHandler._handlers = {}

--// Helper functions


--// Topic Handlers

local function handlePlayerDataSync(message: any)
	-- message.data contains the published data
	-- message.Sent contains when the message was sent (in milliseconds)
	
	local data = message.data
	
	-- Example: decode JSON data if it was stringified
	if typeof(data) == "string" then
		local decoded = game:GetService("HttpService"):JSONDecode(data)
		data = decoded
	end
	
	print(`📦 | Received player data sync: {data}`)
	
	-- Example: Process the synced data
	-- local playerId = data.playerId
	-- local playerData = data.playerData
	-- UpdatePlayerDataInDatabase(playerId, playerData)
end

local function handleServerAnnouncement(message: any)
	local data = message.data
	
	-- Decode if stringified
	if typeof(data) == "string" then
		data = game:GetService("HttpService"):JSONDecode(data)
	end
	
	print(`📢 | Server Announcement: {data.message}`)
end

--- Validates if a topic exists in config
local function isValidTopic(topicName: string): boolean
	for _, topic in MessagingConfig.Topics do
		if topic == topicName then
			return true
		end
	end
	return false
end

--- Wraps a callback with error handling
local function createSafeCallback(callback: (message: any) -> ())
	return function(message: any)
		local success, err = pcall(callback, message)
		if not success then
			warn(`⚠️ | MessagingService callback error: {err}`)
		end
	end
end

--// Handler Registration

--- Registers a callback handler for a topic
--- This handler will be used when Start() is called
function MessagingServiceHandler:RegisterHandler(topicName: string, callback: (message: any) -> ())
	if not isValidTopic(topicName) then
		warn(`⚠️ | Topic "{topicName}" not found in MessagingConfig.`)
		return false
	end

	self._handlers[topicName] = callback
	return true
end

--- Registers multiple topic handlers at once
function MessagingServiceHandler:RegisterHandlers(handlers: {[string]: (message: any) -> ()})
	for topicName, callback in handlers do
		self:RegisterHandler(topicName, callback)
	end
end

--// Subscription Management

--- Subscribes to a topic with a callback
--- Returns the connection so it can be disconnected later
function MessagingServiceHandler:Subscribe(topicName: string, callback: (message: any) -> ())
	if not isValidTopic(topicName) then
		warn(`⚠️ | Topic "{topicName}" not found in MessagingConfig.`)
		return nil
	end
	
	if not MessagingConfig.Subscriptions[topicName] then
		warn(`⚠️ | Topic "{topicName}" is not enabled for subscriptions.`)
		return nil
	end
	
	local safeCallback = createSafeCallback(callback)
	
	-- Attempt subscription with retry logic for initial connection
	local connection, err = MessagingService:SubscribeAsync(topicName, safeCallback)
	
	if not connection then
		warn(`⚠️ | Failed to subscribe to topic "{topicName}": {err}`)
		return nil
	end
	
	-- Store subscription
	if not self._subscriptions[topicName] then
		self._subscriptions[topicName] = {}
	end
	table.insert(self._subscriptions[topicName], connection)
	
	print(`ℹ️ | Successfully subscribed to topic: {topicName}`)
	return connection
end

--- Subscribes to multiple topics with a single callback
--- Returns array of connections
function MessagingServiceHandler:SubscribeMultiple(topicNames: {string}, callback: (message: any) -> ())
	local connections = {}
	
	for _, topicName in topicNames do
		local connection = self:Subscribe(topicName, callback)
		if connection then
			table.insert(connections, connection)
		end
	end
	
	return connections
end

--// Publishing

--- Publishes a message to a topic
function MessagingServiceHandler:Publish(topicName: string, data: any)
	if not isValidTopic(topicName) then
		warn(`⚠️ | Topic "{topicName}" not found in MessagingConfig.`)
		return false
	end
	
	local success, err = pcall(function()
		MessagingService:PublishAsync(topicName, data)
	end)
	
	if not success then
		warn(`⚠️ | Failed to publish to topic "{topicName}": {err}`)
		return false
	end
	
	return true
end

--// Cleanup

--- Disconnects all connections for a specific topic
function MessagingServiceHandler:Disconnect(topicName: string)
	if self._subscriptions[topicName] then
		for _, connection in self._subscriptions[topicName] do
			connection:Disconnect()
		end
		self._subscriptions[topicName] = nil
		print(`ℹ️ | Disconnected from topic: {topicName}`)
	end
end

--- Disconnects all topic subscriptions
function MessagingServiceHandler:DisconnectAll()
	for topicName, connections in self._subscriptions do
		for _, connection in connections do
			connection:Disconnect()
		end
	end
	self._subscriptions = {}
	print("ℹ️ | All MessagingService subscriptions disconnected.")
end

--// Initialization

--- Starts the MessagingServiceHandler and auto-subscribes to all enabled topics
--- Registers built-in example handlers and then subscribes to enabled topics
function MessagingServiceHandler:Start()
	print("ℹ️ | Starting MessagingServiceHandler...")
	
	if not MessagingConfig.Topics or not MessagingConfig.Subscriptions then
		warn("⚠️ | MessagingConfig is missing required fields (Topics, Subscriptions)")
		return false
	end
	
	self:RegisterHandlers({
		[MessagingConfig.Topics.PLAYER_DATA_SYNC] = handlePlayerDataSync,
		[MessagingConfig.Topics.SERVER_ANNOUNCEMENT] = handleServerAnnouncement,
	})
	
	local topicsSubscribed = 0
	for topicName, isEnabled in MessagingConfig.Subscriptions do
		if isEnabled then
			local handler = self._handlers[topicName]
			
			if handler then
				local connection = self:Subscribe(topicName, handler)
				if connection then
					topicsSubscribed += 1
				end
			else
				warn(`⚠️ | No handler registered for enabled topic: {topicName}`)
			end
		end
	end
	
	print(`ℹ️ | MessagingServiceHandler started. Subscribed to {topicsSubscribed}/{self:GetTopicCount()} topics.`)
	return true
end

--// Utility

--- Returns the number of configured topics
function MessagingServiceHandler:GetTopicCount(): number
	local count = 0
	for _ in MessagingConfig.Topics do
		count += 1
	end
	return count
end

--- Returns all active subscriptions
function MessagingServiceHandler:GetActiveSubscriptions(): {[string]: number}
	local active = {}
	for topicName, connections in self._subscriptions do
		active[topicName] = #connections
	end
	return active
end

--- Örnek: Yeni topic'lere handler eklemek için aşağıdaki yolu takip edin:
---
--- 1. MessagingConfig.luau'ya topic'inizi ekleyin:
---    MyNewTopic = "MyNewTopicName"
---
--- 2. MessagingConfig.Subscriptions'da doğrulayın:
---    [MessagingConfig.Topics.MyNewTopic] = true
---
--- 3. Yukarıdakiler gibi bir handler fonksiyonu oluşturun
---
--- 4. Sistem başlatılırken kaydettirin:
---    MessagingServiceHandler:RegisterHandlers({
---        [MessagingConfig.Topics.PLAYER_DATA_SYNC] = handlePlayerDataSync,
---        [MessagingConfig.Topics.SERVER_ANNOUNCEMENT] = handleServerAnnouncement,
---        [MessagingConfig.Topics.MyNewTopic] = myNewHandler,
---    })
---
--- 5. Başlatmadan sonra Start() çağırın

return MessagingServiceHandler
