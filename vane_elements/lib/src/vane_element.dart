// Copyright (c) 2014, Robert Åkerblom-Andersson <Robert@dartvoid.com>

library vane_elements.vane_element;

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:vane_elements/src/vane_router.dart';
import 'package:vane_elements/src/vane_scene.dart';

/**
 * Vane element
 */
@CustomTag('vane-element')
class VaneElement extends PolymerElement {
  /// TODO: Should default path be '' or '/'?

  /// Mandatory scene variable (used for routing)
  String scene = "scene";

  String layout = '';
  String path = '';
  ObservableMap<String, String> parameters = new ObservableMap<String, String>();

  /// Constructor used to create instance of VaneElement
  VaneElement.created() : super.created() {
    // Override default value for hidden
    this.hidden = true;
  }

  /// Get scene router
  VaneRouter get router => VaneScene.elementRouters[scene];

  /// Get scene router
  void set router(VaneRouter router) {
    VaneScene.elementRouters[scene] = router;
  }

  /// Prepare scene, first prepare polymer element and then setup vane routing
  prepareElement() {
    super.prepareElement();

    // Setup route object
    ViewRoute route = new ViewRoute();
    route.name = this.element.name;
    route.hash = this.hashCode;
    route.path = path;

    // Create a new router for scene 'scene' if does not already exists
    if(VaneScene.elementRouters[scene] == null) {
      VaneScene.elementRouters[scene] = new VaneRouter(sceneRouter: true);
      VaneScene.elementRouters[scene].setup();
    }

    // Create and instantiate scene router (one per layout)
    if(router == null) {
      router = new VaneRouter(elementRouter: true);
      router.setup();
    }

    // Register route
//    print('Adding route ${route.name}+${route.path} to viewRegistration.sink <<-- Newly implemented');
    VaneScene.elementRouters[scene].register(route);

    // Listen to stateStream and show/hide when told
    VaneScene.elementRouters[scene].stateStream.stream.listen((SceneState state) {

      print("\n ---> Got event on VaneScene.router.listen()!!!!!!!!!! (${this.element.name})\n");

      // TODO: Optimazation, it seems a scene gets s "hide" state sent to it
      // even if it is not on the matched layout, seems unneccecery since its
      // alreayd hidden anyways (it's layout is hidden )

//      print(" ---> Got event on VaneScene.router.listen()!!!!!!!!!! (${this.element.name})");
//      print(" this.element.name = ${this.element.name}");
//      print(" state.name        = ${state.name}");

      if(this.element.name == state.name && this.hashCode == state.hash) {
        this.hidden = state.hidden;

        // Setup paramters from url match
        if(state.match != null && state.match.parameters.isNotEmpty == true) {
          // Add parameters
          parameters.addAll(state.match.parameters);
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
    VaneScene.elementRouters[scene].loadUrl(path: path);
  }

}

