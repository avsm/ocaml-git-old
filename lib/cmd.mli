val default_git_cmd : string
class git : ?debug:bool -> ?cmd:string -> ?dir:string -> unit -> Git_types.git
