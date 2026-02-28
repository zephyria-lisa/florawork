--[[
 - @ Author: flora
 - @ Create Time: 2026-02-22 19:58:19
 - @ Modified by: flora
 - @ Modified time: 2026-02-28 20:44:54
 - @ Description: Client tarafı için bootstrapper.
]]

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules
local Net = require(ReplicatedStorage.Framework.Shared.Net.Net)

--// Config
local ROOT = {
	ReplicatedStorage.Framework.Client.Services,
	ReplicatedStorage.Framework.Client.Systems,
}

--// Cache
local RawModules = {}
local Registries = {}

--// Functions
local function storeRawModules()
	for _, root in ROOT do
		for _, module in root:GetDescendants() do
			if module:IsA("ModuleScript") then
				table.insert(RawModules, require(module))

			end
		end
	end
end

local function storeRegistries()
	for _, rawModule in RawModules do
		local name = rawModule.Name
		
		if not name then
			continue
		end
		
		Registries[name] = rawModule
	end
end

local function injectDependencies()
	for _, rawModule in Registries do
		local dependencies = rawModule.Dependencies
		
		if not dependencies then
			continue
		end
		
		for desiredName, dependencyName in dependencies do
			local dependencyFound = Registries[dependencyName]
			
			if dependencyFound then
				rawModule[desiredName] = dependencyFound
			end
		end
	end
end

local function initModules()
	for registryName, registry in Registries do
		if registry.Init then
			registry:Init()
		end
	end
	
	for _, registry in Registries do
		if registry.Start then
			task.spawn(function()
				registry:Start()
			end)
		end
	end
end

--// Initialization
Net:Init()
storeRawModules()
storeRegistries()
injectDependencies()
initModules()