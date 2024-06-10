local Package = script.Parent
local Packages = Package.Parent
local Hooks = Package.hooks

local React = require(Packages.React)
local useParams = require(Hooks.useParams)
local useReact = require(Package.useReact)
local useReturn = require(Hooks.useReturn)

local e = React.createElement
local Fragment = React.Fragment
local useEffect = React.useEffect
local useState = React.useState

local function merge(left, right)
	local result = table.clone(left)

	for key, value in right do
		result[key] = value
	end

	return result
end

local function filter(left, right)
	local result = table.clone(left)

	for key in right do
		result[key] = nil
	end

	return result
end

local function getComponentsINeedButtonsFor(world)
	return world
end

local function ComponentButton() end

local function RenderButtons()
	local componentsWithButtons = useParams()
	local updateReturn = useReturn()
	local buttonsPressed, updateState = useState({})

	useEffect(function()
		updateReturn(buttonsPressed)
	end, { buttonsPressed })

	local buttons = {}
	for _, component in componentsWithButtons do
		table.insert(
			buttons,
			e(ComponentButton, {
				text = component,

				onPress = function(pressed)
					if pressed then
						updateState(function(state)
							merge(state, { [component] = true })
						end)
					else
						updateState(function()
							filter(buttonsPressed, { [component] = true })
						end)
					end
				end,
			})
		)
	end

	return e(Fragment, buttons)
end

local function mySystem(world)
	local componentsWithButtons = getComponentsINeedButtonsFor(world)

	local pressed = useReact({
		Buttons = RenderButtons,
	}, { componentsWithButtons })

	if pressed.completed then
		for component in pressed.value do
			print(component, "was pressed.")
		end
	end
end

return mySystem
