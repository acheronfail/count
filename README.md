# `count`

A little toy project which implements the same program in many different languages, and then performs a naive performance and memory benchmark to compare each of them.

The program that's implemented in each of them is a simple counter, but it's constructed in a way to prevent compilers from pre-optimising everything at compile time: modern compilers are quite intelligent and can even optimise away some things which are rather complex!

Have a look at the [**latest release**](https://github.com/acheronfail/count/releases/latest) if you're curious. Each Release contains a table of the results of each CI test (obviously using CI is not a great test, since we don't control the load of the machine, but it's good enough for something as silly as what we're doing in this repository).
