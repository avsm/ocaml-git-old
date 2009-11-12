exception InvalidRepository of string
val repo : ?debug: bool -> string -> Git_types.repo Lwt.t
