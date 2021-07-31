%{
open Ppxlib
open Parsed

%}

// Special characters
%token LPAREN RPAREN DOT COMMA

// Keywords
// %token EXPOSING
%token TYPE
// %token MODULE
%token AS

%token EOF

// Identifiers
%token <string> LOWER_IDENT
%token <string> UPPER_IDENT


%start payload

%type <Payload.t> payload
%type <Payload.t> open_payload
%type <Item.t> open_item
%type <Value.t> val_item
%type <Type.t> type_item
%type <Type.kind> type_item_kind

%%

payload:
  | open_payload EOF  { $1 }

open_payload:
  | mod_longident DOT LPAREN separated_list(COMMA, open_item) RPAREN { Payload.{ open_mod_ident=$1; open_items=$4 } } 

open_item:
  | type_item { Item.Type $1 }
  | val_item  { Item.Value $1 }


val_item:
  | val_ident as_(val_ident) { Value.{ val_ident=$1; val_alias=$2 } }

type_item:
  | TYPE type_ident type_item_kind as_(type_ident)  { Type.{ type_ident=$2; type_kind=$3; type_alias=$4 } }

/* Type Kinds
 * ----------
 * There are 2 type kinds in ppx-open. Namely, closed and open. 
 *
 * They correspond to the following expansions:
 *  - [Foo.(type t (..) as foo)] expands to
 *    [type foo = Foo.t = <constructors of foo here>]
 *  - Foo.(type t as foo) expands to
 *    [type foo = Foo.t]
 * 
 * Note that the expansion of either requries type-level information 
 * (and hence cannot use type information local to the current compilation unit (ml file))
 */

type_item_kind:
  |                         { Type.Kind_closed }
  | LPAREN DOT DOT RPAREN   { Type.Kind_open   }

/* Aliases
 * -------
 * Aliases are defined by the grammar:
 *  alias ::= as ident
 *        | epsilon
 *
 * They are an optional attribute to all items (vals, types, modules and module types) 
 * in the open payload.
 */

as_(ident):
  | option(AS ident { $2 }) { $1 }

/* Long Identifiers
 * ----------------
 * We require long identifiers to parse aliases, type identifiers, module identifiers, etc. 
 * The following specification mimics the OCaml parser implementation 
 * with some opinionated changes. 
 *
 * TODO: value operators
 */

longident_(prefix, final):
  | final             { Lident $1 }
  | prefix DOT final  { Ldot ($1, $3) }

val_ident:
  | LOWER_IDENT { $1 }
  // | LPAREN val_operator RPAREN  { $1 }

type_ident:
  | LOWER_IDENT { $1 }

// mod_ident:
//   | UPPER_IDENT { $1 }

mod_longident:
  | longident_(mod_longident, UPPER_IDENT) { $1 }




