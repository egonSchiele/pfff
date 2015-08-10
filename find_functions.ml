open Common
open Printf

open Ast_php

module Ast = Ast_php
module V = Visitor_php

module PI = Parse_info

let apply_patch = ref false
let flag = ref "payments.intl.seller"

let remove_all_tokens_visitor = V.mk_visitor { V.default_visitor with
  V.kinfo = begin fun (k, _) tok ->
    tok.PI.transfo <- PI.Remove;
    k tok
  end
}

let main files_or_dirs =
  let files = Lib_parsing_php.find_source_files_of_dir_or_files files_or_dirs in

  Flag_parsing_php.show_parsing_error := true;
  Flag_parsing_php.verbose_lexing := true;

  files +> Common2.index_list_and_total +> List.iter (fun (file, i, total) ->
    pr2 (spf "processing: %s (%d/%d)" file i total);

    (* step1: parse the file *)
    let (ast, tokens) = Parse_php.ast_and_tokens file in

    (* step2: visit the AST and annotate the relevant tokens in AST leaves *)
    let visitor = V.mk_visitor { V.default_visitor with

      V.kfunc_def = (fun (k, _) stmt ->
        match stmt with
        | FuncDef (def) -> k stmt
        | _ -> k stmt
      );
    }
    in
    visitor (Program ast);

    (* step3: unparse the annotated AST and show the diff *)
    let s =
      Unparse_php.string_of_program_with_comments_using_transfo (ast, tokens) in

    (*
    let diff = Common.cmd_to_list (spf "diff -u %s %s" file tmpfile) in
    diff +> List.iter pr;

    if !apply_patch
    then Common.write_file ~file:file s;
    *)
    print_endline s
  )

let _ = main (Array.to_list Sys.argv)
