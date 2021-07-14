(lang dune 2.8)
(name ppx_open)

(generate_opam_files true)

(license MIT)
(maintainers "ajo41@cam.ac.uk")
(authors "Alistair O'Brien")
(source
 (github johnyob/ppx-open))

(package
 (name ppx_open)
 (synopsis "")
 (description
  "A ppx rewriter that provides idiomatic selective `open`s in OCaml.")
 (depends
  (ocaml
   (>= 4.08.0))
  (dune
   (>= 2.8))))
