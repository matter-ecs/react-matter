local RenderSystems = require(script.components.RenderSystems)
local useParams = require(script.hooks.useParams)
local useReact = require(script.useReact)
local useReturn = require(script.hooks.useReturn)

export type Component = useReact.Component
export type Components = useReact.Components
export type Complete<T> = useReact.Complete<T>
export type PreviouslyComplete<T> = useReact.PreviouslyComplete<T>
export type Incomplete = useReact.Incomplete
export type Ready<T> = useReact.Ready<T>
export type UpdateReturn<T> = useReturn.UpdateReturn<T>
export type RenderProps<P> = RenderSystems.RenderProps<P>
export type RenderSystemsProps<P> = RenderSystems.RenderSystemsProps<P>

--[=[
	@class ReactMatter
]=]

return {
	useReact = useReact,

	useParams = useParams,
	useReturn = useReturn,

	RenderSystems = RenderSystems,
}
