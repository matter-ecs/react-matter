local Package = script.Parent.Parent
local Packages = Package.Parent

local React = require(Packages.React)

--[=[
	Updates the return value of a system component.

	@type UpdateReturn<T> (value: T | (value: T?) -> T) -> ()
	@within ReactMatter
]=]
export type UpdateReturn<T> = (value: T | (value: T?) -> T) -> ()

export type Return<T> = {
	updateReturn: UpdateReturn<T>?,
}

local defaultReturn: Return<unknown> = {}

local Return = React.createContext(defaultReturn)

return Return
