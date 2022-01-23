# cl-upp

Reads the JSON produced by [unplusplus](https://github.com/spaceotter/unplusplus) to create the
bindings to its C library. This only works with [ECL](https://gitlab.com/embeddable-common-lisp/ecl)
right now.

## Caveats...

* No type checking, most pointers are flattened to `:pointer-void`
* No automatic type conversion, so it can be hard to tell how to write the equivalent of something
  that seems simple in C++
* No memory managment - this problem is unlikely to ever completely go away, there's know way of
  knowing whether functions are returning newly allocated objects or not.
