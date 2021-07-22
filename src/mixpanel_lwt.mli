val track :
  event:string ->
  ?properties:(string * string) list ->
  ?options:Base.track_opt ->
  ?options_transport:string ->
  ?options_send_immediatly:bool ->
  unit ->
  Ojs.t Lwt.t

val init :
  token:string ->
  ?api_host:string ->
  ?app_host:string ->
  ?autotrack:bool ->
  ?cdn:string ->
  ?cross_subdomain_cookie:bool ->
  ?persistence:string ->
  ?persistence_name:string ->
  ?cookie_name:string ->
  ?store_google:bool ->
  ?save_referrer:bool ->
  ?test:bool ->
  ?verbose:bool ->
  ?img:bool ->
  ?track_links_timeout:int ->
  ?cookie_expiration:int ->
  ?upgrade:bool ->
  ?disable_persistence:bool ->
  ?disable_cookie:bool ->
  ?secure_cookie:bool ->
  ?ip:bool ->
  ?property_blacklist:string list ->
  ?name:string ->
  unit ->
  unit Lwt.t
