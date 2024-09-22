local Package = script.Parent.Parent
local Packages = Package.Parent
local Contexts = Package.contexts

local React = require(Packages.React)
local Return = require(Contexts.Return)

local useContext = React.useContext

export type UpdateReturn<T> = Return.UpdateReturn<T>

--[=[
	Retrieves the update function for the return value of a system component.

	This is a hook that can only be called within a `useReact` context, typically
	within a system component. It returns the function that can be used to update
	the return value of the system component.

	```lua
	local function MySystemComponent()
		local updateReturn = useReturn()

		useEffect(function()
			updateReturn(10)

			-- or

			updateReturn(function(value)
				return value + 1
			end)
		end)

		-- ...
	end
	```

	@within ReactMatter
	@tag ReactHook
]=]
local function useReturn<T>(): UpdateReturn<T>
	local returnContext: Return.Return<T> = useContext(Return)

	if not returnContext.updateReturn then
		error("'useReturn' was called outside of a 'useReact' context.")
	end

	return returnContext.updateReturn
end

return useReturn
