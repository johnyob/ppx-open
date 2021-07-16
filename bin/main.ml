let () = print_endline "Hello, World!"


module Foo = struct
  let val1 = 1
end

[%%open Foo.(val1 [@as renamed1])]

let () = print_endline (string_of_int renamed1)

module Bar = struct

  type t = A | B | C

  let to_string = function
  | A -> "A"
  | B -> "B"
  | C -> "C"
end

[%%open Bar.([%type] t [@as bar])]

let () = print_endline (Bar.to_string A)
