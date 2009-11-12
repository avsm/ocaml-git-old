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
open Printf

let _ = 
  let gitdir = Sys.getcwd () in
  let cmd = new Cmd.git () in
  let stdout s =
    Lwt_stream.iter (fun s -> eprintf "stdout: %s\n" s) s in
  let t =
    lwt i = cmd#exec ~stdout "log" [ `BoolOpt ("raw",true)] in
    eprintf "retcode: %d\n" i;
    let repo = new Repo.repo ~path:gitdir in
    lwt h = repo#heads () in
    Lwt_util.iter (fun (k,cref) -> 
      let id = Git_types.string_of_id cref in
      eprintf "heads: %s -> %s\n%!" k id; 
      lwt cs = Commit.find_all ~repo ~cref () in
     (* eprintf "commitx: %s\n%!" (String.concat ", " (List.map (fun x -> x#id_abbrev) cs)); *)
      return ()
    ) h
  in
  Lwt_main.run t
