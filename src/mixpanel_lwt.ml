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
