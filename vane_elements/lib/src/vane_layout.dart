// Copyright (c) 2014, Robert Åkerblom-Andersson <Robert@dartvoid.com>

library vane_elements.vane_layout;

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:vane_elements/src/vane_router.dart';

@CustomTag('vane-layout')
class VaneLayout extends PolymerElement {
  /// Set page title, default from HTML if not set
  String title = "";

  // NEW
  List<String> paths = new List<String>();
  List<int> weights = new List<int>();

  ObservableMap<String, String> parameters = new ObservableMap<String, String>();

  /// Path
  /// TODO: Should default path be '' or '/'?
  String _path = '';

  /// Layout weight, a higher value gives higher priority if two layouts match
  /// the same path
  int _weight = 0;

  /// Enable disable layout, state is kept during the life of the browser
  /// window session (stored in session storage)
  bool _enabled = true;

  /// Session storage
  Storage _sessionStorage = window.sessionStorage;

  // TODO: How do we handle "default" view? Is that "public"? Is it "primary"?

  /// Layout router (never more than one layer router)
  static VaneRouter router;

  /// Scene routers (one router per layout)
  static Map<String, VaneRouter> sceneRouters = new Map<String, VaneRouter>();

  /// Constructor used to create instance of VaneServe.
  VaneLayout.created() : super.created() {
    // Override default value for hidden
    this.hidden = true;
  }

  /// Called when an instance of vane-serve is inserted into the DOM.
  attached() {
    super.attached();

    // TODO: Still under testing...
    // TODO: Does this only run once? So not when switching between layouts?
    // TODO: Or should this be done by the router?
    if(title != "") {
      document.title = title;
    }
  }

  /// Prepare scene, first prepare polymer element and then setup vane routing
  prepareElement() {
    super.prepareElement();
    bool multi = false;

    // Always hide as default value
    // TODO: Should we instead override this paramter in body of class?
    //         bool hidden = true; ??
//    this.hidden = true;

    // Create and instantiate layout router (always only one)
    if(router == null) {
      router = new VaneRouter(layoutRouter: true);
      router.setup();
    }

    // Set local var multi to true in case we register more routes
    if(paths.length > 1) {
      multi = true;
    }

    // Register new routes
    for(var i = 0; i < paths.length; i++) {
      // Route for this layout
      ViewRoute route = new ViewRoute();

      // Setup route
      route.name = this.element.name;
      route.hash = this.hashCode;
      route.path = paths[i];
      route.weight = weights[i];
      route.multi = multi;

      print(" --> Adding route: ${route.name} (${route.multi})");

      // Register route
      router.register(route);
    }

    // Listen to _stateStream for state changes
    router.listen((SceneState state) {
      if(this.element.name == state.name && this.hashCode == state.hash) {
        if(state.hidden == true) {
          print("${this.element.name}: hiding now!");
        } else {
          print("${this.element.name}: showing now!");
        }

        // Update hidden attribute
        this.hidden = state.hidden;

        // Setup paramters from url match
        if(state.match != null && state.match.parameters.isNotEmpty == true) {
          // Add parameters
          parameters.addAll(state.match.parameters);
        }

        // Forward route event to the scene router for this layout
        // TODO: Optimize and only do this if state goes from hidden to show,
        // if from show to hidden, do we really need to do that? All childs
        // will be hidden either way since they are inside the hidden layout...
        // NOTE: I think we do this optimazation now as we check state.match!?!
        if(sceneRouters[this.element.name] != null) {
//          print("-> Forwarding event to scenes in layout ${this.element.name}");

          if(state.match != null) {
            String query = '';
            if(state.match.rest.query != "") {
              query = '?${state.match.rest.query}';
            }

            if(state.match.rest.path.isEmpty == true) {
              sceneRouters[this.element.name].routeEvent.sink.add(new RouteEvent(path: '/'));
            } else {
              sceneRouters[this.element.name].routeEvent.sink.add(new RouteEvent(path: '${state.match.rest.path}${query}'));
            }
          }
        }
      }
    });
  }

  // TODO: Mixin to different classes? Cant do that? "router" is static inside
  // VaneLayout...
  void load(Event event, DetailsElement detail, HtmlElement target) {
    String path;

    // Prevent default behavior
    event.preventDefault();

    // Check first if "data-path" attribute is set, if it is, use it
    path = target.dataset["path"];
    if(path == null) {
      // If target element is anchor link, try to use the href field
      if(target is AnchorElement) {
        path = target.href;
      } else {
        // TODO: Change example to button, a element should use href
        throw new Exception("Missing path variable, please add 'data-path=\"[path]\"' to your element. \nEg. '<a href=\"#\" on-click=\"{{load}}\" data-path=\"/about\">About</a>'");
      }
    }

    // Push state change to HTML5 history
    window.history.pushState("", "", "${path}");

    // Load path with client router
    router.loadUrl(path: path);
  }

}


/// TODO: Move VaneRouter into VaneLayout? To hide the streams as private variables?
///       VaneRouter is not a polymer element so it might be okay to move it into
///       the same file.
///
///       OR
///
///       Should we try to do some smart thing with import/export of libraries?
///       Can we do some good import/export thing?
///


