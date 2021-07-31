# ppx-open
A ppx rewriter that provides idiomatic selective `open`s in OCaml.

## Syntax
`ppx_open` adds selective `open` constructs, wrapped inside `[%%open]`
that may expose
- modules
- module types
- values
- types (and their constructors)
- exceptions

of a given module. 

For instance, the following code:
```ocaml
{%%open| Module_foo.(val1, val2 as renamed1, type type1, module Mod1, module type Mod_type1) |}
```
is rewritten into: 
```ocaml
open (struct
    let val1 = Module_foo.val1
    let renamed1 = Module_foo.val2
    type type1 = Module_foo.type1
    module Mod1 = Module_foo.Mod1
    module type Mod_type1 = Module_foo.Mod_type1
end)
```
### Modules and Module Types

TODO

### Values

TODO

### Types

TODO

### Exceptions

TODO