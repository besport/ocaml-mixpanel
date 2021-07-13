type track_opt =
  | Transport [@js "_transport"]
  | Send_Immediately [@js "_send_immediately"]
[@@js.enum]

[@@@js.stop]

module Properties : sig
  type t

  val create : (string * string) list -> t
end

[@@@js.start]

[@@@js.implem
module Properties = struct
  type t = Ojs.t

  let create ls =
    Ojs.obj
      (Array.of_list (List.map (fun (k, v) -> (k, Ojs.string_to_js v)) ls))

  let t_to_js x = Ojs.t_to_js x
end]

[@@@ocamlformat "disable=true"]

val track :
  event:string ->
  ?properties:(Properties.t [@js.default Properties.create []]) ->
  ?options:track_opt ->
  ?options_transport:string ->
  ?options_send_immediatly:bool ->
  ?callback:(Ojs.t -> unit) ->
  unit ->
  unit
  [@@js.global "mixpanel.track"]

[@@@ocamlformat "disable=false"]

val get_distinct_id : unit -> string [@@js.global "mixpanel.get_distinct_id"]

val register : properties:Properties.t -> ?days:int -> unit -> unit
  [@@js.global "mixpanel.register"]

val people_set :
  properties:Properties.t ->
  ?_to:string ->
  ?callback:(unit -> unit) ->
  unit ->
  unit
  [@@js.global "mixpanel.people.set"]

type config

val config :
  ?api_host:string ->
  ?app_host:string ->
  ?autotrack:bool ->
  ?cdn:string ->
  ?cross_subdomain_cookie:bool ->
  ?persistence:string ->
  ?persistence_name:string ->
  ?cookie_name:string ->
  ?loaded:(unit -> unit) ->
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
  unit ->
  config
  [@@js.builder] [@@js.verbatim_names]

val init : token:string -> ?config:config -> ?name:string -> unit -> unit
  [@@js.global "mixpanel.init"]

val identify : ?unique_id:string -> unit -> unit
  [@@js.global "mixpanel.identify"]

val alias : alias:string -> ?original:string -> unit -> unit
  [@@js.global "mixpanel.alias"]

val reset : unit -> unit [@@js.global "mixpanel.reset"]

[@@@js.stop]

val available : unit -> bool

[@@@js.start]

[@@@js.implem
let available () =
  Js_of_ocaml.Js.Optdef.test Js_of_ocaml.Js.Unsafe.global##.mixpanel]
