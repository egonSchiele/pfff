(* modified from demos/show_function_class_names.ml *)
open Common
open Ast_php

let pr_func_def func_def =
  let s = Ast_php.str_of_ident func_def.f_name in
  pr2 s

let show_function_calls file =
  let ast = Parse_php.parse_program file in

    ast +> List.iter (fun toplevel ->
      match toplevel with
      | FuncDef func_def ->
        pr_func_def func_def
      | ClassDef class_def ->
        (unbrace class_def.c_body) +> List.iter (fun class_stmt ->
          match class_stmt with
            | Method func_def->
              pr_func_def func_def
            | _ -> ()
         )
      | _ -> ()
    )

let main =
  show_function_calls Sys.argv.(1)
