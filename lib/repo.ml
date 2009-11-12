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
open Lwt_io

exception InvalidRepository of string

let is_dir path = try Sys.is_directory path with _ -> false 

(* XXX: using \001 as separator since Pcre fails with \000 *)
let null = String.make 1 (Char.chr 1)

class repo ~path : Git_types.repo =
  
  let wd =
    (* TODO: work back through the path to find a .git subdir *)
    if is_dir path then path else raise (InvalidRepository path) in

  let gitdir = 
    (* TODO: initialize the repo if the .git doesnt exist *)
    let f = Filename.concat wd ".git" in
    if is_dir f then f else raise (InvalidRepository f) in

  let gitfile f =
    Filename.concat gitdir f in

  let gitobj = new Cmd.git ~dir:wd () in

  object(repo)

    method description =
      with_file ~mode:input (gitfile "description") 
        (fun ic -> 
           return (read_lines ic))
   
    method set_description lines =
      with_file ~mode:output (gitfile "description")
        (fun oc ->
           write_lines oc lines)

    method git = gitobj

    method heads ?(opts=[]) () =
      let opts =
        `Bare "refs/heads" ::
        `StrOpt ("sort", "committerdate")  ::
        `StrOpt ("format", "%(refname)%01%(objectname)") ::
         opts in

      let heads = ref [] in
      let stdout s =
        lwt l = Lwt_stream.fold
          (fun s a ->
            match Pcre.split ~pat:null ~max:2 s with
            | [name;id] -> (name, Git_types.id_of_string id) :: a
            | _ -> a
          ) s [] in
         return (heads := l) in
      let git : Cmd.git = repo#git in
      git#exec ~stdout "for-each-ref" opts >>
      return (!heads)

  end
