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
open Git
open Git_types
open OUnit

let git_dir = ref ""

let stderr = Lwt_stream.iter (fun x -> printf "stderr: %s\n%!" x)
let stdout = Lwt_stream.iter (fun x -> printf "stdout: *%s*\n%!" x)

let test_init () =
  let git = new Cmd.git ~dir:!git_dir () in
  lwt i = git#exec "log" [] in
  eprintf "retcode: %d\n%!" i;
  return ()

let test_heads () = 
  lwt repo = Repo.repo !git_dir in
  lwt heads = repo#heads () in
  List.iter (fun (name,id) -> printf "heads: %s %s\n%!" name (string_of_id id)) heads;
  return ()

let test_raw_log () =
  let git = new Cmd.git ~dir:!git_dir () in
  lwt i = git#exec "log" [ `BoolOpt ("raw",true)] in
  printf "retcode: %d\n" i;
  return ()

let test_commits () =
  lwt repo = Repo.repo !git_dir in
  lwt heads = repo#heads () in
  Lwt_util.iter (fun (k,cref) -> 
    let id = string_of_id cref in
    eprintf "heads: %s -> %s\n%!" k id; 
    lwt cs = Commit.find_all ~repo ~cref () in
    eprintf "commitx: %s\n%!" (String.concat ", " (List.map (fun x -> string_of_id x#id_abbrev ^ ": " ^ x#summary) cs)); 
    return ()
  ) heads

let (>::>>) a b =
  a >:: (fun () -> let x = Lwt_main.run (b ()) in printf "done\n%!"; x )

let suite = [
  "init" >::>> test_init;
  "heads" >::>> test_heads;
  "raw_log" >::>> test_raw_log;
  "commits" >::>> test_commits;
]

let _ = 
  git_dir := try Sys.getenv "GIT_TEST" with _ -> Sys.getcwd () in
  eprintf "Using repo: %s\n" !git_dir;
  run_test_tt_main ("Git" >::: suite)
