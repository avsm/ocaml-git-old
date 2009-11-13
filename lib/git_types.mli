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

exception InvalidRepository of string

type commit_id
val id_of_string : string -> commit_id
val string_of_id : commit_id -> string

type arg =
    [ `Bare of string
    | `BoolOpt of string * bool
    | `StrOpt of string * string ]

class type git =
  object
    method exec :
      ?stdout:(string Lwt_stream.t -> unit Lwt.t) ->
      ?stderr:(string Lwt_stream.t -> unit Lwt.t) ->
      string -> arg list -> int Lwt.t
  end

class type actor =
  object
    method email : string option
    method name : string
    method str : string
  end

class type repo = 
  object
    method description : string Lwt_stream.t Lwt.t
    method git : git
    method heads : ?opts:arg list -> unit -> (string * commit_id) list Lwt.t
    method set_description : string Lwt_stream.t -> unit Lwt.t
  end

class type commit =
  object
    method author : actor
    method author_date : float
    method committer : actor
    method committer_date : float
    method id : commit_id
    method id_abbrev : commit_id
    method message : string
    method parents : string list
    method summary : string
    method tree : string
  end
