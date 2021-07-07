# ocaml-mixpanel

Binding to
[mixpanel](https://developer.mixpanel.com/docs/javascript-full-api-reference)

## What does ocaml-mixpanel do

This plugin provides function that give the opportunity to use
"Mixpanel" in your ocalm projects.

> Mixpanel is a product analytics tool that enables you to capture data on how users interact with your digital product. Mixpanel then lets you analyze this product data with simple, interactive reports that let you query and visualize the data with just a few clicks.

Source: [mixpanel.com](https://developer.mixpanel.com/docs/what-is-mixpanel)

## How to install and compile your project by using this plugin ?

You can use opam by pinning the repository with:
```Shell
opam pin add mixpanel https://github.com/besport/ocaml-mixpanel.git
```

to compile your project, use:
```Shell
dune build @install
```

Finally, install the cordova plugin "mixpanel" with:
```Shell
cordova plugin add mixpanel
```


## How to use it?

### Mixpanel.available
You can use this function to know if the object "Mixpanel" is available
in your project, it is recommended to use it before to call the
functions that depend on the server Mixpanel, if "available" retrun
"false" your should probably cancel your call to the function (or else
their will be a chance that program became stuck: waiting a reponse of
Mixpanel that could never came).

### Mixpanel.init
> This function initializes a new instance of the Mixpanel tracking
object. All new instances are added to the main mixpanel object as sub
properties (such as mixpanel.library_name) and also returned by this
function.

Source: [mixpanel API](https://developer.mixpanel.com/docs/javascript-full-api-reference)

The optional argument "config" in an object of type "config", all it's
optional argument represent a config name and the value of the
configuration option we want to override.
Example:
```Shell
let token = "new token" in
let config =
Mixpanel.config ~cookiesName:"Cookies"
                ~loaded:(function
                        |_ -> print_endline "Hello World")
in
let name = "library_name" in
Mixpanel.init ~token ~config ~name
```
  [See the default config options](https://github.com/mixpanel/mixpanel-js/blob/8b2e1f7b/src/mixpanel-core.js#L87-L110)

### What is the type Properties.t?
The type "Properties.t" is an associative array of properties to store about the user (for
example "{'Gender': 'Male', 'Age': 21}"), this type is used for
several function arguments.
You can create a "Properties.t" object with the function
"Properties.create" that can convert a list of (string * string) into a "Properties.t" object:
```Shell
let props = [("Gender", "Male");("Age", "21")] in
let properties = Mixpanel.Properties.create props
```

### Mixpanel.track
The main function of this plugin is "track", like its name suggest, it
track an event and send it to the "Mixpanel" server, where it could be
analyzed later.

The optional argument "properties" is an object of type "Properties.t".
The optional argument "options" in an object of type "track_opt" that
can have 2 value "Transport" or "Send_Immediately"
```Shell
Mixpanel.track ~event:"Tracked" ~properties ()
Mixpanel.track ~event:"Tracked" ~properties:(Mixpanel.Properties.create [("Gender", "Male");("Age", "21")]) ()
```

The optionnal argument "callback" represent a function that will be
executed at the end of the "track", this function must have one
argument of type "Ojs.t": it represents the value returned by the
execution of "Mixpanel.track".

"Mixpanel.track" return either a boolean "false" if the track failed
or an object if it suceed, this is why the function given in "callback"
takes an  object "Ojs.t" that represent it.
You can use the function "Ojs.type_of_payload" to identify the type of
the value returned:
```Shell
Mixpanel.track ~event:"Event name" ~properties
               ~callback:(function payload ->
                                   if String.equal (Ojs.type_of payload)
                                   "boolean" then print_endline "Track
                                   Failed"
                                   else print_endline "Track Succeed")
               ()
```
#### Mixpanel.Lwt.track
The module "Lwt" provide an implementation of "track" that return a
"promise" of a result, under the form of an "Ojs.t Lwt.t" object. This
version of "track" can't receive a "callback" argument because it is
used to "wakeup" the result, indeed: this function will return an order
to "wait" until the "Mixpanel.track" is done. Once the "track" is done,
the callback execution will put an end to the "wait".
Exemple:
```Shell
print_endline "Wait";
let%lwt _ = Mixpanel.Lwt.track ~event:"Track LWT" () in
print_endline "Wake Up";
```
        => In this example the "Wake Up" line won't be printed before
        the "track" is sent to Mixpanel.

[Learn more about Lwt](https://ocsigen.org/lwt/latest/manual/manual)

Warning: if the "track" to Mixpanel failed (if it returns a "false"),
this function will return an exception "Track_Failed".

### Mixpanel.get_distinct_id
This function returns the current "distinct id" of the user.

> get_distinct_id() can only be called after the Mixpanel library has
  finished loading. You can handle this automatically in init() with
  the "~loaded" parametter of "config". For exemple, we can see bellow a
  case were "distinct_id" is set after the mixpanel library has finish loaded \n
  ```Shell
  Mixpanel.init ~token:"YOUR PROJECT TOKEN"
                ~config:( Mixpanel.config
                          ~loaded: (function mixpanel ->
                                   distinct_id = mixpanel.get_distinct_id()))
                ()
  ```

  Source: [mixpanel API](https://developer.mixpanel.com/docs/javascript-full-api-reference)

### Mixpanel.register
This function will add the properties given in argument to all futur
"Mixpanel.tracks" raised in your application.
For example:
  ```Shell
  let plus = Mixpanel.Properties.create [("Regitered");(true)] in
  Mixpanel.register ~properties:plus ();
  MMixpanel.track ~event:"Track" ~properties:(Mixpanel.Properties.create [("Gender", "Male");("Age", "21")]) ()
  ```
  That example will create a track called "Track" with the
  propertie "Registered:true" in addition to "Gender" and "Age"

### Mixpanel.people_set
This funciton will execute the function "mixpanel.people.set" from the
API. This function works a little bit like "track", in difference
that the "properites" given in argument will insteade be added to the
Mixpanel profil of the current user.

### Mixpanel.identify
[See mixpanel API](https://developer.mixpanel.com/docs/javascript-full-api-reference#mixpanelidentify)

### Mixpanel.alias
This function will add the "alias" string given in argument to the
"alias name" list of the current user that can be seen on his profil on
Mixpanel.

### Mixpanel.reset

> Clears super properties and generates a new random distinct_id for this instance. Useful for clearing data when a user logs out.

Source : [mixpanel API](https://developer.mixpanel.com/docs/javascript-full-api-reference#mixpanelreset)

### Mixpanel.set_group
> Register the current user into one/many groups.

Source : [mixapnel API](https://developer.mixpanel.com/docs/javascript-full-api-reference#mixpanelset_group)

The second argument "group_ids" have to be a list (even if their is
only 1 element), in addition, even if the Mixpanel AST say that the list
can contain either "string" elements or "int" elements, in this plugin
you have to gave string argument only.
The optional argument "callback" is a function that will be called afte
the "set_group" execution is done.
