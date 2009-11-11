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

class commit repo id =
  object(self)

  method id_short =
    String.sub id 0 7

  method summary = ()   

  end

let find_all ?(opts=[]) ?(path="") ~repo ~cref () =
  let opts =
     `Bare cref ::
     (`Bare "--") ::
     (`Bare path) ::
     (`StrOpt ("pretty", "raw")) ::
     opts in

  let commits = ref [] in
  let stdout s = 
    lwt l = Lwt_stream.fold
      (fun s a -> s :: a) s [] in
    return (commits := l) in

  let git : Cmd.git = repo#git in
  git#exec ~stdout "rev-list" opts >>
  return (!commits)

