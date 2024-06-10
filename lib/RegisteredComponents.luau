local Package = script.Parent
local Packages = Package.Parent

local React = require(Packages.React)
local Signal = require(Packages.Signal)

export type Component = React.ComponentType<unknown>
export type Components = { [string]: Component }

local components: Components = {}
local componentsChanged = Signal.new()

local function updateComponents(components: Components)
	components = components
	componentsChanged:Fire(components)
end

local function insertComponent(key: string, component: Component)
	components[key] = component
	updateComponents(components)
end

local function removeComponent(key: string)
	components[key] = nil
	updateComponents(components)
end

return {
	Components = components,
	ComponentsChanged = componentsChanged.Event,

	insertComponent = insertComponent,
	removeComponent = removeComponent,
}
