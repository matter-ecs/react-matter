local Package = script.Parent.Parent
local Packages = Package.Parent
local Contexts = Package.contexts

local Params = require(Contexts.Params)
local React = require(Packages.React)
local Return = require(Contexts.Return)
local Signal = require(Packages.Signal)

local e = React.createElement
local useEffect = React.useEffect
local useState = React.useState

--[=[
	A complete state for a set of system components.

	Indicates that the components have completed rendering and are current. The
	`value` field contains the return value of the system components.

	```lua
	local ready = useReact({
		Component = MyComponent,
	}, {})

	if ready.completed then
		print("The return value is", ready.value)
	end
	```

	.completed true -- The components are rendered
	.value T -- The return value

	@interface Complete<T>
	@within ReactMatter
]=]
export type Complete<T> = {
	completed: true,
	value: T,
}

--[=[
	A previously complete state for a set of system components.

	Indicates that the components have completed rendering at some point, however
	the set of components or parameters have changed and a newly rendered value is
	not yet available. The `value` field contains the return value of the system
	components.

	```lua
	local ready = useReact({
		Component = MyComponent,
	}, {})

	if not ready.completed then
		print("The components are not yet ready.")

		if ready.value then
			print("The most recent return value is", ready.value)
		end
	end
	```

	.completed false -- The components are not yet rendered
	.value T -- The most recent return value

	@interface PreviouslyComplete<T>
	@within ReactMatter
]=]
export type PreviouslyComplete<T> = {
	completed: false,
	value: T,
}

--[=[
	An incomplete state for a set of system components.

	Indicates that the components have not yet completed rendering. No `value` is
	yet available.

	```lua
	local ready = useReact({
		Component = MyComponent,
	}, {})

	if not ready.completed then
		print("The components are not yet ready.")
	end
	```

	.completed false -- The components are not yet rendered

	@interface Incomplete
	@within ReactMatter
]=]
export type Incomplete = {
	completed: false,
}

--[=[
	A ready state for a set of system components.

	Informs the system of the result of rendering components. It is always one of
	three states: [[Complete]], [[PreviouslyComplete]], or [[Incomplete]].

	The `completed` field always exists and indicates whether the components have
	completed rendering since the components or parameters changed.

	The `value` field is only present when the components have successfully
	rendered at some point. It contains the return value of the components.

	```lua
	local ready = useReact({
		Component = MyComponent,
	}, {})

	if ready.completed then
		print("The return value is", ready.value)
	end
	```

	@type Ready<T> Complete<T> | PreviouslyComplete<T> | Incomplete
	@within ReactMatter
]=]
export type Ready<T> = Complete<T> | PreviouslyComplete<T> | Incomplete

export type Passed<Params, Return> = {
	params: Params,
	ready: Ready<Return>,
}

local function SystemComponent<Props, Params, Return>(
	component: React.ComponentType<Props>,
	passed: Passed<Params, Return>,
	signal: typeof(Signal.new())
): React.ComponentType<Props>
	return function(props: Props): React.ReactNode
		local passed, updatePassed = useState(passed)

		local function updateReturn(value: Return | (value: Return?) -> Return)
			if type(value) == "function" then
				updatePassed(function(oldPassed: Passed<Params, Return>): Passed<Params, Return>
					local newPassed = {
						params = oldPassed.params,
						ready = {
							completed = true,
							value = value(
								if oldPassed.ready.completed then oldPassed.ready.value else nil
							),
						},
					}

					signal:Fire(newPassed)
					return newPassed
				end)
			else
				local newPassed = {
					params = passed.params,
					ready = {
						completed = true,
						value = value,
					},
				}

				signal:Fire(newPassed)
			end
		end

		useEffect(function()
			local connection = signal:Connect(function(value: Passed<Params, Return>)
				updatePassed(value)
			end)

			return function()
				connection.disconnect()
			end
		end, {})

		return e(Params.Provider, {
			value = {
				params = passed.params,
			},
		}, {
			e(Return.Provider, {
				value = {
					updateReturn = updateReturn,
				},
			}, {
				SystemComponent = e(component, props),
			}),
		})
	end
end

return SystemComponent
