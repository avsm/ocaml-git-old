
val find_all :
  ?max_count:int ->
  ?skip:int ->
  repo:Git_types.repo -> cref:Git_types.commit_id -> unit -> Git_types.commit list Lwt.t

val of_id :
  repo:Git_types.repo -> cref:Git_types.commit_id -> unit -> Git_types.commit option Lwt.t
