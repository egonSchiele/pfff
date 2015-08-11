(* modified from demos/show_function_class_names.ml *)
(* DELETE the function with the given name *)
open Common
open Ast_php
open Lib_parsing_php

module Ast = Ast_php
module V = Visitor_php
module PI = Parse_info

(* remove all tokens of this function *)
let remove_all_tokens_visitor toks = toks +> List.iter (fun tok ->
        tok.PI.transfo <- PI.Remove;
    )

(* visit the AST and remove the body of the specified function *)
let visitor func_to_delete = V.mk_visitor { V.default_visitor with
  V.kfunc_def = (fun (k, _) stmt ->
    match stmt with
    | func ->
        if Ast_php.str_of_ident func.f_name <> func_to_delete
        then k stmt
        (* the very useful ii_of_any function breaks a function into a list of tokens.
         * But it needs an `any` type! `entity` and `any` types are defined in lang_php/parsing/ast_php.ml.
         * First we use the FunctionE constructor to make this func an `entity`. Then we
         * use the Entity constructor to make it an `any`. *)
        else remove_all_tokens_visitor (Lib_parsing_php.ii_of_any (Entity (FunctionE func)))
    | _ -> k stmt
    );
}

let delete_function file func_to_delete =
  (* parse the file *)
  let (ast, tokens) = Parse_php.ast_and_tokens file in
    visitor func_to_delete (Program ast);

    (* unparse the annotated AST and print it out *)
    print_endline (Unparse_php.string_of_program_with_comments_using_transfo (ast, tokens))

let main =
  delete_function Sys.argv.(1) Sys.argv.(2)
