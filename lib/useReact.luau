local Package = script.Parent
local Packages = Package.Parent
local Components = Package.components

local Matter = require(Packages.Matter)
local RegisteredComponents = require(Package.RegisteredComponents)
local Signal = require(Packages.Signal)
local SystemComponent = require(Components.SystemComponent)
local diffTables = require(Package.diffTables)

export type Component = RegisteredComponents.Component
export type Components = RegisteredComponents.Components
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

--[=[
	Renders a set of components from within a Matter system.

	This is a Matter hook that can be used to render a set of components from
	within a Matter system. It's able to pass parameters to the components and
	receive a return value from the components.

	```lua
	local function mySystem()
		useReact({
			MyComponent = MyComponent,
		}, {})
	end
	```

	Parameters can be passed to the components by providing a table of parameters
	to the `useReact` hook. The parameters can be updated by providing a new set
	of parameters to the `useReact` hook at any time. Treat these parameters as
	if they were dependencies of some other hook. When the parameters change, the
	components will be re-rendered with the new parameters, and the parameters
	should be immutable.

	```lua
	local function mySystem()
		useReact({
			MyComponent = MyComponent,
		}, { param1, param2, param3 })
	end
	```

	When the components are rendered, they may return a value. This value can be
	read by the system by calling the `useReact` hook. The return value is not
	immediately available as React may not have rendered the components yet. The
	returned [[Ready]] value indicates whether the components have completed
	rendering and provides the return value of the components.

	```lua
	local function mySystem()
		local ready = useReact({
			MyComponent = MyComponent,
		}, {})

		if ready.completed then
			print("The component returned", ready.value)
		end
	end
	```
]=]
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
