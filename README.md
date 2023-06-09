# simple-circle-tool

Just a small little graphical application demonstrating how triangulation works.

In particular you don't need exact radii; as long as you know the proportion of radii among the three circles, you can perform triangulation just fine (slide the slider around until the circles touch at a point).

## development

This is written in Elm. The standard Elm toolchain install will work fine. `run.sh` uses `elm-live`, but the same effect can be achieved by replacing the `elm-live` command in `run.sh` with an `elm make` command.
