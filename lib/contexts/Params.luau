local Package = script.Parent.Parent
local Packages = Package.Parent

local React = require(Packages.React)

export type ParamType<T> = T & {}

export type Params<T> = {
	params: ParamType<T>?,
}

local defaultParams: Params<unknown> = {}

local Params = React.createContext(defaultParams)

return Params
