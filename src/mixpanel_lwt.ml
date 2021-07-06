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

let init ~token ?api_host ?app_host ?autotrack ?cdn ?cross_subdomain_cookie
    ?persistence ?persistence_name ?cookie_name ?loaded ?store_google
    ?save_referrer ?test ?verbose ?img ?track_links_timeout ?cookie_expiration
    ?upgrade ?disable_persistence ?disable_cookie ?secure_cookie ?ip
    ?property_blacklist ?name () =
  let (wait, wakeup) = Lwt.task () in
  let new_loaded _ =
    match loaded with
    | None -> Lwt.wakeup wakeup true
    | Some x ->
        Lwt.wakeup wakeup true ;
        x
  in
  let config =
    Base.config
      ~loaded:new_loaded
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
  Base.init ~token ~config ?name () ;
  wait
