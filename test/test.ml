(** test1 *)
[%%open Module_foo.(val1)]

(** test2 *)
[%%open Module_foo.(val1, val2)]

(** test3 *)
[%%open Module_foo.(val1, val2 [@as renamed1])]
