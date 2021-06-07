val track :
  event:string ->
  ?properties:(string * string) list ->
  ?options:Base.track_opt ->
  ?options_transport:string ->
  ?options_send_immediatly:bool ->
  unit ->
  Ojs.t Lwt.t
