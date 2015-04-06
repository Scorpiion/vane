// Copyright (c) 2014, Robert Åkerblom-Andersson <Robert@dartvoid.com>

library vane_elements.vane_scene;

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:vane_elements/src/vane_router.dart';
import 'package:vane_elements/src/vane_layout.dart';

@CustomTag('vane-scene')
class VaneScene extends PolymerElement {

  bool _sceneEnabled = true;
  bool _layoutEnabled = true;

  /// TODO: Should default path be '' or '/'?

  String layout = '';
  String path = '';
  ObservableMap<String, String> parameters = new ObservableMap<String, String>();

  /// Scene routers (one router per scene)
  static Map<String, VaneRouter> elementRouters = new Map<String, VaneRouter>();

  /// Constructor used to create instance of VaneView.
  VaneScene.created() : super.created() {
    // Override default value for hidden
    this.hidden = true;
  }

  void set sceneEnabled(bool state) {
    // If scene was enabled and are beeing disabled
    if(_sceneEnabled == true && state == false) {
      // Update _sceneEnabled
      _sceneEnabled = false;

      // Disable route
      VaneLayout.sceneRouters[layout].enableRoute(this.element.name, false, hash: this.hashCode);

      // Trigger router to check routes
      VaneLayout.sceneRouters[layout].loadUrl(force: true);
    }

    // If scene was disabled and are beeing enabled
    if(_sceneEnabled == false && state == true) {
      // Update _sceneEnabled
      _sceneEnabled = true;

      // Enable route
      VaneLayout.sceneRouters[layout].enableRoute(this.element.name, true, hash: this.hashCode);

      // Trigger router to check routes
      VaneLayout.sceneRouters[layout].loadUrl(force: true);
    }
  }

  bool get sceneEnabled => _sceneEnabled;

  void set layoutEnabled(bool state) {
    // If layout was enabled and are beeing disabled
    if(_layoutEnabled == true && state == false) {
      // Update _layoutEnabled
      _layoutEnabled = false;

      // Disable route
      VaneLayout.router.enableRoute(layout, false);

      // Trigger router to check routes
      VaneLayout.router.loadUrl(force: true);
    }

    // If layout was disabled and are beeing enabled
    if(_layoutEnabled == false && state == true) {
      // Update _layoutEnabled
      _layoutEnabled = true;

      // Enable route
      VaneLayout.router.enableRoute(layout, true);

      // Trigger router to check routes
      VaneLayout.router.loadUrl(force: true);
    }
  }

  bool get layoutEnabled => _layoutEnabled;

  /// Prepare scene, first prepare polymer element and then setup vane routing
  prepareElement() {
    super.prepareElement();

    // Setup route object
    ViewRoute route = new ViewRoute();
    route.name = this.element.name;
    route.hash = this.hashCode;
    route.path = path;

    // Create a new router for layout 'layout' if does not already exists
    if(VaneLayout.sceneRouters[layout] == null) {
      VaneLayout.sceneRouters[layout] = new VaneRouter(sceneRouter: true);
      VaneLayout.sceneRouters[layout].setup();
    }

    // Register route
//    print('Adding route ${route.name}+${route.path} to viewRegistration.sink <<-- Newly implemented');
    VaneLayout.sceneRouters[layout].register(route);

    // Listen to stateStream and show/hide when told
    VaneLayout.sceneRouters[layout].stateStream.stream.listen((SceneState state) {


      // TODO: Optimazation, it seems a scene gets s "hide" state sent to it
      // even if it is not on the matched layout, seems unneccecery since its
      // alreayd hidden anyways (it's layout is hidden )

//      print(" ---> Got event on VaneScene.router.listen()!!!!!!!!!! (${this.element.name})");
//      print(" this.element.name = ${this.element.name}");
//      print(" state.name        = ${state.name}");

      if(this.element.name == state.name && this.hashCode == state.hash) {
        if(state.hidden == true) {
          print("${this.element.name}: hiding now!");
        } else {
          print("${this.element.name}: showing now!");
        }

        print("\n${this.element.name}: this.element.name = ${this.element.name}, state.name = ${state.name}");

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
        if(elementRouters[this.element.name] != null) {
//          print("-> Forwarding event to scenes in layout ${this.element.name}");

          if(state.match != null) {
            String query = '';
            if(state.match.rest.query != "") {
              query = '?${state.match.rest.query}';
            }

            if(state.match.rest.path.isEmpty == true) {
              elementRouters[this.element.name].routeEvent.sink.add(new RouteEvent(path: '/'));
            } else {
              elementRouters[this.element.name].routeEvent.sink.add(new RouteEvent(path: '${state.match.rest.path}${query}'));
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
    // TODO: Correct or not? Or should this go to the Layout router?
    VaneLayout.sceneRouters[layout].loadUrl(path: path);
  }

}

