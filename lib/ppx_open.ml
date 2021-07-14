open Base
open Ppxlib

let name = "open"

module Payload = struct
  module Value = struct
    type t =
      { val_ident : string
      ; val_alias : string option
      }

    (** [pattern] defines then [Ast_pattern.t] for the 
        [Value.t] payload within the [%%open ...] extension hook.
        
        We define the following syntax for a value:
          value  ::= ident [attr] 
          attrs ::= [@as ident]
          ident ::= Lident string 
    *)
    let pattern () =
      let open Ast_pattern in
      let ident () = pexp_ident (lident __) in
      let as_attr =
        attribute ~name:(string "as") ~payload:(pstr (pstr_eval (ident ()) nil ^:: nil))
      in
      let attrs = as_attr ^:: nil in
      let value = alt_option (pexp_attributes attrs (ident ())) (ident ()) in
      value |> map2 ~f:(fun val_alias val_ident -> { val_ident; val_alias })


    let expand mod_ident ~loc { val_ident; val_alias } =
      let ident = val_alias |> Option.value ~default:val_ident in
      let (module B) = Ast_builder.make loc in
      let open B in
      pstr_value
        Nonrecursive
        [ value_binding
            ~pat:(ppat_var (Located.mk ident))
            ~expr:(pexp_ident (Located.mk (Ldot (mod_ident, val_ident))))
        ]
  end

  type t =
    { open_mod_ident : Longident.t
    ; open_values : Value.t list
    }

  (** [pattern] defines then [Ast_pattern.t] for the 
      [Open.t] payload within the [%%open ...] extension hook.
    
    We define the following syntax for the 
    payload of the [%%open ...] extension hook:
      payload ::= mod_ident.( items ) 
      items   ::= item | item, items
      item    ::= value
 *)
  let pattern () =
    let open Ast_pattern in
    let item = Value.pattern in
    let items = item () |> map1 ~f:(fun item -> [ item ]) ||| pexp_tuple (many (item ())) in
    let mod_ident = open_infos ~override:fresh ~expr:(pmod_ident __) in
    pstr (pstr_eval (pexp_open mod_ident items) nil ^:: nil)
    |> map2 ~f:(fun open_mod_ident open_values -> { open_mod_ident; open_values })


  let expand ~loc { open_mod_ident; open_values } =
    let (module B) = Ast_builder.make loc in
    let open B in
    let value_bindings = List.map ~f:(Value.expand ~loc open_mod_ident) open_values in
    pstr_open (open_infos ~override:Fresh ~expr:(pmod_structure value_bindings))
end

let pattern = Payload.pattern ()
let expand ~ctxt payload = Payload.expand ~loc:(Expansion_context.Extension.extension_point_loc ctxt) payload
let open_extension = Extension.V3.declare name Extension.Context.structure_item pattern expand
let open_rule = Context_free.Rule.extension open_extension
let () = Driver.register_transformation ~rules:[ open_rule ] name
