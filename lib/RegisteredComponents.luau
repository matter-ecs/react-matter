local Package = script.Parent
local Packages = Package.Parent

local React = require(Packages.React)
local Signal = require(Packages.Signal)

export type Component = React.ComponentType<unknown>
export type Components = { [string]: Component }

local components: Components = {}
local componentsChanged = Signal.new()

local function updateComponents()
	componentsChanged:Fire(components)
end

local function insertComponent(key: string, component: Component)
	assert(not components[key], `Duplicate system component key '{key}'. Keys must be unique.`)
	components[key] = component
	updateComponents()
end

local function removeComponent(key: string)
	assert(
		components[key],
		`No system component with key '{key}'. This indicates a duplicate key or a missing component.`
	)
	components[key] = nil
	updateComponents()
end

return {
	Components = components,
	ComponentsChanged = componentsChanged.Event,

	insertComponent = insertComponent,
	removeComponent = removeComponent,
}
