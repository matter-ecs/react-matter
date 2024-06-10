local Package = script.Parent.Parent
local Packages = Package.Parent

local React = require(Packages.React)

export type Complete<T> = {
	completed: true,
	value: T,
}

export type PreviouslyComplete<T> = {
	completed: false,
	value: T,
}

export type Incomplete = {
	completed: false,
}

export type Ready<T> = Complete<T> | PreviouslyComplete<T> | Incomplete

export type UpdateReturn<T> = (value: T | (value: T?) -> T) -> ()

export type Return<T> = {
	updateReturn: UpdateReturn<T>?,
}

local defaultReturn: Return<unknown> = {}

local Return = React.createContext(defaultReturn)

return Return
