# React-Matter [![CI status][ci-badge]][ci] [![Docs status][docs-badge]][docs]

**React-Matter** is an interface between _[React]_ and _[Matter]_.

It provides access to useful hooks not included in with Matter.

[ci-badge]: https://github.com/matter-ecs/react-matter/actions/workflows/ci.yaml/badge.svg
[docs-badge]: https://github.com/matter-ecs/react-matter/actions/workflows/docs.yaml/badge.svg
[ci]: https://github.com/matter-ecs/react-matter/actions/workflows/ci.yaml
[docs]: https://matter-ecs.github.io/react-matter/
[react]: https://jsdotlua.github.io/react-lua/
[matter]: https://matter-ecs.github.io/matter/

## Installation

React-Matter can be installed with [Wally] by including it as a dependency in
your `wally.toml` file.

```toml
ReactMatter = "matter-ecs/react-matter@0.1.0"
```

## Building

Before building, you'll need to install all dependencies using [Wally].

You can then sync or build the project with [Rojo]. React-Matter contains
several project files with different builds of the project. The
`default.project.json` is the package build.

[rojo]: https://rojo.space/
[wally]: https://wally.run/

## Contributing

Contributions are welcome, please make a pull request! Check out our
[contribution] guide for further information.

Please read our [code of conduct] when getting involved.

[contribution]: CONTRIBUTING.md
[code of conduct]: CODE_OF_CONDUCT.md

## License

React-Matter is free software available under the MIT license. See the [license]
for details.

[license]: LICENSE.md
