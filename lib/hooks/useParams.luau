local Package = script.Parent.Parent
local Packages = Package.Parent
local Contexts = Package.contexts

local Params = require(Contexts.Params)
local React = require(Packages.React)

local useContext = React.useContext

local function useParams<T>(): ...T
	local paramsContext: Params.Params<T> = useContext(Params)

	if not paramsContext.params then
		error("'useParams' was called outside of a 'useReact' context.")
	end

	return table.unpack(paramsContext.params)
end

return useParams
