# ocaml-mixpanel

Binding to
[mixpanel](https://developer.mixpanel.com/docs/javascript-full-api-reference)

## What does ocaml-mixpanel do

This plugin provides function that give the opportunity to use
`Mixpanel` in your OCaml projects.

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

### `Mixpanel.available`
You can use this function to know if the object `Mixpanel` is available
in your project, it is recommended to use it before to call the
functions that depend on the server Mixpanel, if "available" retrun
"false" your should probably cancel your call to the function (or else
their will be a chance that program became stuck: waiting a reponse of
Mixpanel that could never came).

### `Mixpanel.script`
This function execute a pre-defined *Java Script* script in your app, it
is recommended to call this function in server side of your app befor to
use other function if this script is suitable for you. You can see what
this script do in the `base.mli` file.
This script is retruned in the form of an `[> Html_types.script ]
Tyxml_html.elt list` value. It require you to use the `TyXML` librarie,
you can see the [Ocsigen official
documentation](https://ocsigen.org/tyxml/latest/manual/intro) for more
details, more precisely [this
section](https://ocsigen.org/tyxml/4.0/api/Html_sigs.Make.T) for a
better understanding of what this function return.

### `Mixpanel.init`
> This function initializes a new instance of the Mixpanel tracking
object. All new instances are added to the main mixpanel object as sub
properties (such as mixpanel.library_name) and also returned by this
function.

Source: [Mixpanel API](https://developer.mixpanel.com/docs/javascript-full-api-reference)

The optional argument "config" in an object of type "config", all it's
optional argument represent a config name and the value of the
configuration option we want to override.
Example:
```Ocaml
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

### `Mixpanel.Lwt.init`
The module `Lwt` provides an implementation of `init` that puts your
application in "wait" status until the initialization is over.
All the possible properies of an object "config" have to be given
individually in this case as optional arguments, there was no other
solution found to provides user to gave an argument "loaded" while
maintaining the possibility to give a `config` argument.
This constraint had to be added because this function will use the
`loaded` property of "config" to wakeup the program, in practice a
"unit" will be add to the "loaded" that can gave a user in argument.

### What is the type `Properties.t`?
The type `Properties.t` is an associative array of properties to store
about the user (for example "{'Gender': 'Male', 'Age': 21}"), this type
is used for several function arguments.
You can create a `Properties.t` object with the function
`Properties.create` that can convert a list of `(string * string)` into
a
`Properties.t` object:
```Ocaml
let props = [("Gender", "Male");("Age", "21")] in
let properties = Mixpanel.Properties.create props
```

### `Mixpanel.track`
The main function of this plugin is "track", like its name suggest, it
track an event and send it to the "Mixpanel" server, where it could be
analyzed later.

The optional argument "properties" is an object of type `Properties.t`.
The optional argument "options" in an object of type "track_opt" that
can have 2 value "Transport" or "Send_Immediately"
```Ocaml
Mixpanel.track ~event:"Tracked" ~properties ()
Mixpanel.track ~event:"Tracked" ~properties:(Mixpanel.Properties.create [("Gender", "Male");("Age", "21")]) ()
```

The optionnal argument "callback" represent a function that will be
executed at the end of the "track", this function must have one
argument of type `Ojs.t`: it represents the value returned by the
execution of `Mixpanel.track`.

`Mixpanel.track` return either a boolean "false" if the track failed
or an object if it suceed, this is why the function given in "callback"
takes an  object `Ojs.t` that represent it.
You can use the function `Ojs.type_of_payload` to identify the type of
the value returned:
```Ocaml
Mixpanel.track ~event:"Event name" ~properties
               ~callback:(function payload ->
                                   if String.equal (Ojs.type_of payload)
                                   "boolean" then print_endline "Track
                                   Failed"
                                   else print_endline "Track Succeed")
               ()
```
#### `Mixpanel.Lwt.track`
The module `Lwt` provides an implementation of "track" that returns a
"promise" of a result, under the form of an "Ojs.t Lwt.t" object. This
version of "track" can't receive a "callback" argument because it is
used to "wakeup" the result, indeed: this function will return an order
to "wait" until the `Mixpanel.track` is done. Once the "track" is done,
the callback execution will put an end to the "wait".
Exemple:
```Ocaml
print_endline "Wait";
let%lwt _ = Mixpanel.Lwt.track ~event:"Track LWT" () in
print_endline "Wake Up";
```
        => In this example the "Wake Up" line won't be printed before
        the "track" is sent to Mixpanel.

[Learn more about Lwt](https://ocsigen.org/lwt/latest/manual/manual)

Warning: if the "track" to Mixpanel failed (if it returns a "false"),
this function will return an exception "Track_Failed".

### `Mixpanel.get_distinct_id`
This function returns the current "distinct id" of the user.

> get_distinct_id() can only be called after the Mixpanel library has
  finished loading. You can handle this automatically in init() with
  the "~loaded" parametter of "config". For exemple, we can see bellow a
  case were "distinct_id" is set after the mixpanel library has finish loaded \n
  ```Ocaml
  Mixpanel.init ~token:"YOUR PROJECT TOKEN"
                ~config:( Mixpanel.config
                          ~loaded: (function mixpanel ->
                                   distinct_id = mixpanel.get_distinct_id()))
                ()
  ```

  Source: [Mixpanel API](https://developer.mixpanel.com/docs/javascript-full-api-reference)

### `Mixpanel.register`
This function will add the properties given in argument to all futur
`Mixpanel.tracks` raised in your application.
For example:
  ```Ocaml
  let plus = Mixpanel.Properties.create [("Regitered");(true)] in
  Mixpanel.register ~properties:plus ();
  Mixpanel.track ~event:"Track" ~properties:(Mixpanel.Properties.create [("Gender", "Male");("Age", "21")]) ()
  ```
  That example will create a track called "Track" with the
  propertie "Registered:true" in addition to "Gender" and "Age"

### `Mixpanel.people_set`
This funciton will execute the function "mixpanel.people.set" from the
API. This function works a little bit like "track", in difference
that the "properites" given in argument will insteade be added to the
Mixpanel profil of the current user.

### `Mixpanel.identify`
> Identify a user with a unique ID to track activity across devices, tie
a user to their events, and create a user profile. If you never call
this method, unique visitors are tracked using a UUID generated the fist
time they visit the site.

[See Mixpanel API](https://developer.mixpanel.com/docs/javascript-full-api-reference#mixpanelidentify)

### `Mixpanel.alias`
This function will add the "alias" string given in argument to the
"alias name" list of the current user that can be seen on his profil on
Mixpanel.

### `Mixpanel.reset`

> Clears super properties and generates a new random distinct_id for this instance. Useful for clearing data when a user logs out.

Source : [Mixpanel API](https://developer.mixpanel.com/docs/javascript-full-api-reference#mixpanelreset)

### `Mixpanel.set_group`
> Register the current user into one/many groups.

Source : [Mixapnel API](https://developer.mixpanel.com/docs/javascript-full-api-reference#mixpanelset_group)

The second argument `group_ids` has to be a list (even if there is only
one element), in addition, even if the Mixpanel API says that the list
can contain either string elements or integer elements, in this
plugin you have to provide a string argument only.
The optional argument "callback" is a function that will be called after
the `set_group` execution is done.

### `Mixpanel.Group` module
This module contains functions for "group" management in Mixpanel

#### `Mixpanel.Group.get_group`

This function returns a `group_id` value that can be used in other
functions inside the `Group` module.

The second argument `group_id` has to be an object of type `Ojs.t`,
this is a type that you can construct with several types of data [see
more details on how to build Ojs.t objects](https://github.com/LexiFi/gen_js_api/blob/bee3b595898fdaf7db0366a9b1a009db9a6c6026/lib/ojs.mli)

[See Mixpanel API](https://developer.mixpanel.com/docs/javascript-full-api-reference#mixpanelget_group)

#### `Mixpanel.Group.set`
> Set properties on a group

This function takes a required argument `prop` of type `Properties.t`, it
represents the property that will be added in the group.

You can use this function right after an `Mixpanel.Group.get_group`
application:

```Ocaml
let prop = Mixpanel.Properties.create [("Gender", "Male")] in
    Mixpanel.Group.set
      (Mixpanel.Group.get_group ~group_key:"key" ~group_id:"id")
      ~prop ()
```

[See Mixpanel API](https://developer.mixpanel.com/docs/javascript-full-api-reference#mixpanelgroupset)

You can notice that in this library it is impossible to give a simple
string as parameter `prop` and the argument `to` isn't specified too
(it is indeed useless to give a `to` argument since it only makes sense
if the `prop` is a simple string: the `Properties.t` type can substitute
it).
