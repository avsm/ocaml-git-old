(*pp camlp4o -I `ocamlfind query lwt.syntax` pa_lwt.cmo *)
(*
 * Copyright (c) 2009 Anil Madhavapeddy <anil@recoil.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

open Lwt
open Lwt_process
open Printf

let default_git_cmd = "git"

class git ?(debug=false) ?(cmd=default_git_cmd) ?dir () : Git_types.git =
  let dir = match dir with None -> Sys.getcwd () | Some d -> d in
  object(self)
  
  val work_tree = "--work-tree=" ^ dir
  val git_dir = "--git-dir=" ^ (Filename.concat dir ".git")

  method exec ?stdout ?stderr base (args: Git_types.arg list) =
    let argmap = git_dir :: work_tree :: base :: List.map (function
        `Bare x -> x
      | `StrOpt (k,v) -> sprintf "--%s=%s" k v
      | `BoolOpt (k,v) -> if v then "--" ^ k else ""
    ) args in

    let c = "git", Array.of_list (cmd :: argmap) in
    if debug then 
      eprintf "exec: %s\n%!" (String.concat " " (cmd :: argmap));

    with_process_full c
      (fun pf ->
        let sout = match stdout with
           None -> return ()
         | Some fn -> 
            fn (Lwt_io.read_lines pf#stdout) 
        in
        let serr = match stderr with
           None -> return ()
         | Some fn -> fn (Lwt_io.read_lines pf#stderr) in
        let sin = Lwt_io.close pf#stdin in
        join [sout; serr; sin] >>
        lwt status = pf#close in
        match status with
          Unix.WEXITED r -> return r
        | _ -> return (-1)
      )

  end
