--[[
 - @ Author: flora
 - @ Create Time: 2026-02-22 21:53:45
 - @ Modified by: flora
 - @ Modified time: 2026-02-28 18:26:09
 - @ Description: Sunucu tarafı için bootstrapper. Tüm sunucu tarafı modülleri burada toplanır, enjekte edilir ve başlatılır.
 ]]

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

--// Modules
local Net = require(ReplicatedStorage.Framework.Shared.Net.Net)

--// Config
local ROOTS = {
	ServerScriptService.Server.Services,
	ServerScriptService.Server.Systems,
}
local IS_STUDIO = RunService:IsStudio()

--// Cache
local RawModules = {}
local Registry = {}

--// Functions
local function storeRoots()	
	for _, root in ipairs(ROOTS) do
		for _, module in ipairs(root:GetDescendants()) do
			if module:IsA("ModuleScript") then
				local moduleRequired = require(module)
				
				if table.find(RawModules, moduleRequired) then
					warn(`⚠️ | Duplicate module detected: {module.Name}`)
					continue
				end
				
				table.insert(RawModules, moduleRequired)
			end
		end
	end
end

local function createRegistries()
	for _, module in RawModules do
		if not module.Name then
			warn(`⚠️ | A module has no name, skipping it. Ignore this if it is not intended to have a name.`)
			continue
		end
		
		Registry[module.Name] = module
	end
end

local function injectDependencies()
	for _, module in Registry do
		if not module.Dependencies then
			continue
		end
		
		for fieldName, dependencyName in module.Dependencies do
			local dependency = Registry[dependencyName]
			
			assert(dependency, `Malformed dependency: {dependencyName}`)
			
			module[fieldName] = dependency
		end
	end
end

local function initRegistries()
	for _, registry in Registry do
		if not registry.Init then
			continue
		end
		
		print(`ℹ️ | Initializing registry '{registry.Name}'`)
		
		registry:Init()
		
		print(`ℹ️ | Initialized registry '{registry.Name}'`)
	end
end

local function startRegistries()
	for _, registry in Registry do
		if not registry.Start then
			continue
		end
		
		print(`ℹ️ | Starting registry '{registry.Name}'`)
		
		task.spawn(function()
			registry:Start()
		end)
		
		print(`ℹ️ | Started registry '{registry.Name}'`)
	end
end

--// Initialization
Net:Init()
storeRoots()
createRegistries()
injectDependencies()
initRegistries()
startRegistries()
