val track :
  event:string ->
  ?properties:(string * string) list ->
  ?options:Base.track_opt ->
  ?options_transport:string ->
  ?options_send_immediatly:bool ->
  unit ->
  Ojs.t Lwt.t

val set_group :
  group_key:string ->
  group_ids:string list ->
  ?callback:(Ojs.t -> unit) ->
  unit ->
  Ojs.t Lwt.t
