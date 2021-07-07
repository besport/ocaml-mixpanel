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

let set_group ~group_key ~group_ids ?callback () =
  let (wait, wakeup) = Lwt.wait () in
  let new_callback =
    match callback with
    | None -> ( function payload -> Lwt.wakeup wakeup payload )
    | Some x -> (
        function
        | payload ->
            Lwt.wakeup wakeup payload ;
            x payload )
  in
  Base.set_group ~group_key ~group_ids ~callback:new_callback () ;
  wait
