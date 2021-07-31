open Ppxlib

module Value = struct
  type t =
    { val_ident : string
    ; val_alias : string option
    }
  [@@deriving eq, show]
end

module Type = struct
  type kind =
    | Kind_open
    | Kind_closed
  [@@deriving eq, show]

  type t =
    { type_ident : string
    ; type_alias : string option
    ; type_kind : kind
    }
  [@@deriving eq, show]
end

module Item = struct
  type t =
    | Type of Type.t
    | Value of Value.t
  [@@deriving eq, show]
end

module Payload = struct
  type t =
    { open_mod_ident : Longident.t
    ; open_items : Item.t list
    }
  [@@deriving eq, show]
end