exception Track_Failed

let track ~event ?properties ?options ?options_transport
    ?options_send_immediatly () =
  let (wait, wakeup) = Lwt.wait () in
  let prop = Option.map (fun ls -> Base.Properties.create ls) properties in
  Base.track
    ~event
    ?properties:prop
    ?options
    ?options_transport
    ?options_send_immediatly
    ~callback:(function
      | payload ->
          Lwt.wakeup wakeup payload ;
          if
            String.equal (Ojs.type_of payload) "boolean"
            && Ojs.bool_of_js payload == false
          then raise Track_Failed)
    () ;
  wait

let promise (f : _ -> unit) =
  let (promise, resolver) = Lwt.task () in
  f @@ Lwt.wakeup resolver ;
  promise

let init ~token ?api_host ?app_host ?autotrack ?cdn ?cross_subdomain_cookie
    ?persistence ?persistence_name ?cookie_name ?store_google ?save_referrer
    ?test ?verbose ?img ?track_links_timeout ?cookie_expiration ?upgrade
    ?disable_persistence ?disable_cookie ?secure_cookie ?ip ?property_blacklist
    ?name () =
  promise @@ fun wakeup ->
  let config =
    Base.config
      ~loaded:wakeup
      ?api_host
      ?app_host
      ?autotrack
      ?cdn
      ?cross_subdomain_cookie
      ?persistence
      ?persistence_name
      ?cookie_name
      ?store_google
      ?save_referrer
      ?test
      ?verbose
      ?img
      ?track_links_timeout
      ?cookie_expiration
      ?upgrade
      ?disable_persistence
      ?disable_cookie
      ?secure_cookie
      ?ip
      ?property_blacklist
      ()
  in
  Base.init ~token ~config ?name ()
