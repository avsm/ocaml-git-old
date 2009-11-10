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

(* XXX: using \001 as separator since Pcre fails with \000 *)
let null = String.make 1 (Char.chr 1)

let find_all ?(opts=[]) repo =
  let opts =
    `Bare "refs/heads" ::
    `StrOpt ("sort", "committerdate")  :: 
    `StrOpt ("format", "%(refname)%01%(objectname)") ::
    opts in
  
  let stdout s =
    Lwt_stream.iter 
     (fun s ->
        eprintf "find_all: %s\n%!" s;
        match Pcre.split ~pat:null ~max:2 s with
          [name;ids] ->
            eprintf "   name=%s ids=%s\n%!" name ids;
        | _ -> ()
     ) s in
  let git : Cmd.git = repo#git in
  git#exec ~stdout "for-each-ref" opts
