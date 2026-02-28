--[[
 - @ Author: flora
 - @ Create Time: 2026-03-01 02:42:51
 - @ Modified by: flora
 - @ Modified time: 2026-03-01 02:54:08
 - @ Description: Sunucu tarafı için maid sistemi. Olayları, örnekleri ve fonksiyonları temizlemek için kullanılır.
]]

--// Module
local Maid = {}
Maid.__index = Maid

--// Types
export type Task = RBXScriptConnection | Instance | (() -> ()) | { Destroy: (any) -> () } | { Disconnect: (any) -> () }
export type Maid = typeof(setmetatable(
	{} :: {
		ClassName: string,
		_tasks: { Task },
	},
	Maid
))

--// Functions
function Maid.new(): Maid
	local self = setmetatable({
		ClassName = "Maid",
		_tasks = {},
	}, Maid)

	return self
end

function Maid.isMaid(value: any): boolean
	return type(value) == "table" and value.ClassName == "Maid"
end

function Maid:GiveTask(task: Task): number?
	if not task then
		warn(`⚠️ | Attempted to give a task to the maid who is false or nil.`)
		return nil
	end

	local taskId = #self._tasks + 1
	self._tasks[taskId] = task

	return taskId
end

function Maid.DoCleaning(self: Maid)
	local tasks = self._tasks

	for index, task in tasks do
		if typeof(task) == "RBXScriptConnection" then
			tasks[index] = nil
			task:Disconnect()
		end
	end

	for index, task in pairs(tasks) do
		tasks[index] = nil

		local typeOfTask = typeof(task)
		if typeOfTask == "function" then
			(task :: () -> ())()
		elseif typeOfTask == "Instance" then
			(task :: Instance):Destroy()
		elseif typeOfTask == "table" then
			if type((task :: any).Destroy) == "function" then
				(task :: any):Destroy()
			elseif type((task :: any).Disconnect) == "function" then
				(task :: any):Disconnect()
			end
		elseif typeOfTask == "RBXScriptConnection" then
			(task :: RBXScriptConnection):Disconnect()
		end
	end
end

function Maid:Destroy()
	self:DoCleaning()
end

--// Module Exporting
return Maid
