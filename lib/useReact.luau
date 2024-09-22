local Package = script.Parent
local Packages = Package.Parent
local Components = Package.components

local Matter = require(Packages.Matter)
local RegisteredComponents = require(Package.RegisteredComponents)
local Signal = require(Packages.Signal)
local SystemComponent = require(Components.SystemComponent)
local diffTables = require(Package.diffTables)

export type Component = RegisteredComponents.Component
export type Components = { [string]: Component }
export type Complete<T> = SystemComponent.Complete<T>
export type PreviouslyComplete<T> = SystemComponent.PreviouslyComplete<T>
export type Incomplete = SystemComponent.Incomplete
export type Ready<T> = SystemComponent.Ready<T>
export type Passed<Params, Return> = SystemComponent.Passed<Params, Return>

type Storage<Params, Return> = {
	components: Components?,
	passed: Passed<Params, Return>?,
	signal: typeof(Signal.new())?,
}

local function clearComponents<Params, Return>(storage: Storage<Params, Return>)
	if storage.components then
		for key in storage.components do
			RegisteredComponents.removeComponent(key)
		end
	end
end

local function cleanup<Params, Return>(storage: Storage<Params, Return>)
	clearComponents(storage)

	if storage.signal then
		storage.signal:DisconnectAll()
	end
end

local function useReact<Params, Return>(
	components: Components,
	dependencies: Params & {},
	discriminator: unknown?
): Ready<Return>
	local storage = Matter.useHookState(discriminator, cleanup) :: Storage<Params, Return>

	if diffTables(components, storage.components) then
		clearComponents(storage)
		storage.components = components

		if not storage.passed then
			storage.passed = {
				params = {},
				ready = {
					completed = false,
				},
			}

			storage.signal = Signal.new()

			storage.signal:Connect(function(value: Passed<Params, Return>)
				storage.passed = value
			end)
		end

		for key, component in components do
			local systemComponent = SystemComponent(component, storage.passed, storage.signal)
			RegisteredComponents.insertComponent(key, systemComponent)
		end
	end

	if diffTables(dependencies, storage.passed.params) then
		storage.passed = {
			params = dependencies,
			ready = {
				completed = false,
				value = if storage.ready and storage.ready.completed
					then storage.ready.value
					else nil,
			},
		}

		storage.signal:Fire(storage.passed)
	end

	return storage.passed.ready
end

return useReact
