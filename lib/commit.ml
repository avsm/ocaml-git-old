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

type args = {
  tree : string;
  parents: string list; 
  author: Actor.actor;
  author_date: float;
  committer: Actor.actor;
  committer_date: float;
  message: string list;
}

class commit args repo id : Git_types.commit =
  let id = Git_types.string_of_id id in
  object(self)

  val message_str = lazy(String.concat "\n" args.message)
  val id_abbrev = lazy(String.sub id 0 7)
  val summary = lazy(
    match args.message with
      [] -> ""
    | hd :: _ -> hd)

  method tree = args.tree
  method parents = args.parents
  method author = args.author
  method author_date = args.author_date
  method committer = args.committer
  method committer_date = args.committer_date
  method message = Lazy.force message_str
  method summary = Lazy.force summary

  method id = Git_types.id_of_string id
  method id_abbrev = Git_types.id_of_string (Lazy.force id_abbrev)

  end

let fsplit t s =
  match Pcre.split ~pat:" " ~max:2 s with
    [x;b] when x=t -> b
  | _ -> assert false

let sfsplit t s =
  lwt x = Lwt_stream.next s in
  return (fsplit t x)

let tsplit t s =
  let rex = Pcre.regexp "^([^ ]+) (.+) (\\d+) ([+-][0-9]+)$" in
  match Pcre.split ~rex s with
    [ ""; kind; actor; epochstr; tz ] ->
       if kind <> t then failwith (
        Printf.sprintf "Expected “%s” got “%s” in “%s”." t kind s);
       let epoch = float_of_string epochstr in
       let actor = Actor.of_string actor in
       actor, epoch
  | _ -> assert false

let junk_newline = 
  Lwt_stream.junk_while ((=) "")

let parse_one s =
  lwt rid = Lwt_stream.next s in
  let id = Git_types.id_of_string (fsplit "commit" rid) in
  lwt rtree = Lwt_stream.next s in
  let tree = fsplit "tree" rtree in
  lwt rparents = Lwt_stream.get_while
    (fun s -> try String.sub s 0 7 = "parent " with _ -> false) s in
  let parents = List.map (fsplit "parent") rparents in
  lwt rauthor = Lwt_stream.next s in
  let author, author_date = tsplit "author" rauthor in
  lwt rcomm = Lwt_stream.next s in
  let committer, committer_date = tsplit "committer" rcomm in
  junk_newline s >>
  lwt rmsg = Lwt_stream.get_while 
    (fun s -> try String.sub s 0 4 = "    " with _ -> false) s in
  let message = List.map (fun s -> String.sub s 4 (String.length s - 4)) rmsg in
  junk_newline s >>
  let args = 
    { tree=tree; parents=parents; author=author; author_date=author_date; 
      committer=committer; committer_date=committer_date; message=message } in
  return (id, args)

let parse_raw s =
  let rec getall acc =
    try_lwt
      lwt x = parse_one s in
      getall (x :: acc)
    with Lwt_stream.Empty ->
      return acc in
  getall []

let find_all ?max_count ?skip ~repo ~cref () =
  let cref = Git_types.string_of_id cref in
  let mkmc c = `StrOpt ("max_count", string_of_int c) in
  let mksk c = `StrOpt ("skip", string_of_int c) in
  let opts =
     `Bare cref ::
     `StrOpt ("pretty", "raw") ::
     (match max_count,skip with
      | None , None -> []
      | Some mc, None -> [ mkmc mc ]
      | None, Some sk -> [ mksk sk ]
      | Some mc, Some sk -> [ mkmc mc; mksk sk ]) in
  let commits = ref [] in
  let stdout s =
    lwt items = parse_raw s in
    let i = List.map (fun (id,args) -> new commit args repo id) items in
    return (commits := i) in
  let git : Cmd.git = repo#git in
  git#exec ~stdout "rev-list" opts >>
  return (!commits)

let of_id ~repo ~cref () =
  lwt r = find_all ~max_count:1 ~repo ~cref () in
  match r with
  | [c] -> return (Some c)
  | []  -> return None
  | _   -> assert false
