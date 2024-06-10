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

export type Complete<T> = Return.Complete<T>
export type PreviouslyComplete<T> = Return.PreviouslyComplete<T>
export type Incomplete = Return.Incomplete
export type Ready<T> = Return.Ready<T>

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
