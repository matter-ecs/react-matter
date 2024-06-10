local Package = script.Parent.Parent
local Packages = Package.Parent

local React = require(Packages.React)
local RegisteredComponents = require(Package.RegisteredComponents)

local e = React.createElement
local Fragment = React.Fragment
local useEffect = React.useEffect
local useMemo = React.useMemo
local useState = React.useState

export type RenderProps<P> = {
	child: React.ComponentType<P>,
	props: P,
}

export type Props<P> = {
	render: React.ComponentType<RenderProps<P>>?,
	props: P,
}

type Components = RegisteredComponents.Components
type RenderedComponents = { [string]: React.ReactNode }

local function DefaultRender<P>(props: RenderProps<P>): React.ReactNode
	return e(props.child, props.props)
end

local function RenderSystems<P>(props: Props<P>): React.ReactNode
	local render = props.render or DefaultRender
	local children: Components, updateChildren = useState({})

	useEffect(function()
		updateChildren(RegisteredComponents.Components)

		local connection = RegisteredComponents.ComponentsChanged:Connect(
			function(components: Components)
				updateChildren(components)
			end
		)

		return function()
			connection.disconnect()
		end
	end, {})

	local renderedChildren = useMemo(function(): RenderedComponents
		local renderedChildren = {}

		for key, component in children do
			renderedChildren[key] = e(render, {
				child = component,
				props = props.props,
			})
		end

		return renderedChildren
	end, { children, render, props.props })

	return e(Fragment, {}, renderedChildren)
end

return RenderSystems
