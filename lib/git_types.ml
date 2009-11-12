exception InvalidRepository of string

type commit_id = string

let id_of_string (x:string) : commit_id = x
let string_of_id (x:commit_id) : string = x

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
