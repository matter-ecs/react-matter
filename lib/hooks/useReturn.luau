local Package = script.Parent.Parent
local Packages = Package.Parent
local Contexts = Package.contexts

local React = require(Packages.React)
local Return = require(Contexts.Return)

local useContext = React.useContext

export type UpdateReturn<T> = Return.UpdateReturn<T>

local function useReturn<T>(): UpdateReturn<T>
	local returnContext: Return.Return<T> = useContext(Return)

	if not returnContext.updateReturn then
		error("'useReturn' was called outside of a 'useReact' context.")
	end

	return returnContext.updateReturn
end

return useReturn
