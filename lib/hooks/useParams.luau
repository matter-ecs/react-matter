local Package = script.Parent.Parent
local Packages = Package.Parent
local Contexts = Package.contexts

local Params = require(Contexts.Params)
local React = require(Packages.React)

local useContext = React.useContext

--[=[
	Retrieves the parameters passed to a system component.

	This is a hook that can only be called within a `useReact` context, typically
	within a system component. It returns the parameters passed to the system
	component.

	```lua
	local function MySystemComponent()
		local x, y, z = useParams()

		-- ...
	end
	```

	Notably these parameters are distinct from the props passed to a system
	component. Parameters are passed to a system component via the `useReact`
	matter hook, while props are passed to a system component via the
	[[RenderSystems]] component from within a React render tree. Both can be used
	simultaneously to pass data to a system component, but originate from
	different sources.

	```lua
	local function MySystemComponent(props)
		local param = useParams() -- Comes from a Matter system
		local prop = props.value -- Comes from a React component

		-- ...
	end
	```

	@within ReactMatter
	@tag ReactHook
]=]
local function useParams<T>(): ...T
	local paramsContext: Params.Params<T> = useContext(Params)

	if not paramsContext.params then
		error("'useParams' was called outside of a 'useReact' context.")
	end

	return table.unpack(paramsContext.params)
end

return useParams
