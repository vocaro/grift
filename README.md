# grift
A swift dependency graph visualizer tool.

The intent of this is to use sourcekit to get type information for all elements of a set of swift files and create a dotfile that can be rendered into a graph via graphviz or some other tool.

Grift is in its very early stages. There are many scenarios it does not account for properly, and there's lots of type information that it isn't able to easily detect yet. If you're curious what it does support so far, check out the uncommented unit tests [here](Tests/GriftKitTests/GriftKitTests.swift) for examples.

To play with what's there, you can simply run `swift run` to run grift in its own directory, or `swift run grift dependencies --path {your-path-here}` to specify your own location. The output will be in the graphviz dot format to standard output, which you can generate an image with using graphviz

For a rough idea of what this tool may become, check out the [roadmap](roadmap.md).

## Excludes

Grift can exclude types that may be irrelevant to the visualization, such as Foundation classes. The exclusion must be expressed as a regular expression, such as `^UI.*`. Be sure to use anchors when needed: `Set` will match both `Set` and `OptionSet`, but `^Set$` will match only `Set`.

To specify exclusions, use the `excludes` parameter with a list of regular expressions separated by commas. Example: `--excludes ^Clock$,^NS.*`

Grift provides a set of common types that can be excluded with a single parameter: `--defaultExcludes`

If `--excludes` and `--defaultExcludes` parameters are both provided, they will be combined.
