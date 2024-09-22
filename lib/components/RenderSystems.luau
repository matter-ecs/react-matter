local Package = script.Parent.Parent
local Packages = Package.Parent

local React = require(Packages.React)
local RegisteredComponents = require(Package.RegisteredComponents)

local e = React.createElement
local Fragment = React.Fragment
local useEffect = React.useEffect
local useMemo = React.useMemo
local useState = React.useState

--[=[
	These are the props passed to a custom render component.

	.child ReactComponent<P> -- The system component to render
	.props P -- The props to pass to the system component

	@interface RenderProps<P>
	@within ReactMatter
]=]
export type RenderProps<P> = {
	child: React.ComponentType<P>,
	props: P,
}

--[=[
	These are the props passed to the RenderSystems component.

	.render ReactComponent<RenderProps<P>>? -- The render system to use
	.props P -- The props to pass to components rendered

	@interface RenderSystemsProps<P>
	@within ReactMatter
]=]
export type RenderSystemsProps<P> = {
	render: React.ComponentType<RenderProps<P>>?,
	props: P,
}

type Components = RegisteredComponents.Components
type RenderedComponents = { [string]: React.ReactNode }

local function DefaultRender<P>(props: RenderProps<P>): React.ReactNode
	return e(props.child, props.props)
end

--[=[
	A component that renders all system components.

	This component will render all components that have been registered using the
	`useReact` hook within a Matter system. All components can be passed the same
	set of props using the `props` prop.

	```lua
	local function MySystems(props)
		return React.createElement(RenderSystems, {
			props = {
				commonData = props.data, -- Some data common to all components
			},
		})
	end
	```

	A custom render component can be passed to the `render` prop to customize how
	components are rendered or if they should be rendered at all. The render
	component will be passed [[RenderProps]] as props containing the component to
	render and the props to pass to the system component. Each render component is
	responsible for rendering a single system component.

	```lua
	local function MyRender(renderProps: RenderProps)
		local props = if someCondition then merge(renderProps.props, {
			specialParameter = data, -- Some special data for this component
		}) else renderProps.props

		return React.createElement(renderProps.child, props)
	end

	local function MySystems(props)
		return React.createElement(RenderSystems, {
			render = MyRender,
			props = {
				commonData = props.data, -- Some data common to all components
			},
		})
	end
	```

	If no render component is passed, a default render component will be used. The
	default will render each system component directly and pass the props directly
	to it.

	@within ReactMatter
]=]
local function RenderSystems<P>(props: RenderSystemsProps<P>): React.ReactNode
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
