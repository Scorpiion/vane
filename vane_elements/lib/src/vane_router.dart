// Copyright (c) 2014, Robert Åkerblom-Andersson <Robert@dartvoid.com>

library vane_elements.vane_router;

import 'dart:html';
import 'dart:async';
import 'package:uri/uri.dart';

class SceneState {
  String name;
  int hash;
  bool hidden;

  UriMatch match;
}

class HashList {
  String path = "";
  List<int> hashes = new List<int>();
}

/**
 * Vane client router component
 */
class VaneRouter  {
  List<ViewRoute> routes = [];
  HashList nonMatches = new HashList();

  // TODO: Make these private?
  bool isLayoutRouter = false;
  bool isSceneRouter = false;
  bool isElementRouter = false;

  /// Constructor used to create instance of VaneServe.
  VaneRouter({bool layoutRouter: false, bool sceneRouter: false, bool elementRouter: false}) {
    if(layoutRouter == true) {
      // Set type of router
      isLayoutRouter = true;

      // Setup push state listener (is only trigger on browser actions, like
      // the user presses the back button)
      window.onPopState.listen((PopStateEvent e) {
        // Create new route event (include query part of url as well)
        routeEvent.sink.add(new RouteEvent(path: window.location.href.replaceFirst(window.location.origin, '')));
      });
    } else if(sceneRouter == true) {
      // TODO: Maybe rename [sceneRouter] or [isSceneRouter] and use it direct?
      isSceneRouter = true;
    } else if(elementRouter == true) {
      // TODO: Maybe rename [sceneRouter] or [isSceneRouter] and use it direct?
      isElementRouter = true;
    } else {
      throw new Exception("Must set a router type, layoutRouter, sceneRouter or elementRouter");
    }
  }

  /// Stream used to add new routes, all elements [VaneLayout], [VaneScene] and
  /// [VaneElement] uses this stream to register their settings with the router.
  StreamController _registration = new StreamController( /* onListen: () => print("Adding listener to _registration stream") */ );

  /// Stream used to send out events to listening router, for the layout
  /// router these events comes from changes in the url. Scene routers get
  /// their events from the layout router. Element routers get their evens from
  /// their respective scene router.
  StreamController routeEvent = new StreamController.broadcast( /* onListen: () => print("Adding listener to _routeEvent stream") */ );

  /// Stream used to send out events to subscribed elements [VaneLayout],
  /// [VaneScene] or [VaneElement]. Tells elements if their should change their
  /// state or not.
  StreamController stateStream = new StreamController.broadcast( /* onListen: () => print("Adding listener to _stateStream") */ );

  /// Register route
  void register(ViewRoute route) {
    _registration.sink.add(route);
  }

  void enableRoute(String name, bool state, {int hash: 0}) {
    for(var route in routes) {
      if(route.name == name && (route.hash == hash || hash == 0)) {
        route.enabled = state;
      }
    }
  }

  /// Listen to router
  StreamSubscription listen(void onData(SceneState state),
                            { Function onError,
                              void onDone(),
                              bool cancelOnError }) {
    return stateStream.stream.listen(onData,
                                     onError: onError,
                                     onDone: onDone,
                                     cancelOnError: cancelOnError);
  }

  void setup() {
    // Setup registration
    _registration.stream.listen((ViewRoute route) {
      // Create parser for path
      route.parser = new UriParser(new UriTemplate(route.path));

      // Add route to list of routes
      routes.add(route);

//      print("\nBefore sort:");
//      for(var i = 0; i < routes.length; i++) {
//        print(routes[i].path);
//      }

      // Sort routes
      routes.sort();

//      print("\nAfter sort:");
//      for(var i = 0; i < routes.length; i++) {
//        print(routes[i].path);
//      }

      // Reverse list so that the longest paths comes first
      routes = new List.from(routes.reversed);

//      print("\nAfter reverse:");
//      for(var i = 0; i < routes.length; i++) {
//        print(routes[i].path);
//      }

      // Load current url each time a new layout is registered
      if(isLayoutRouter == true) {
        // Load current url
        loadUrl();
      }
    });

    // Setup route event stream
    routeEvent.stream.listen((RouteEvent event) {
      UriMatch match;
      bool foundMatch = false;
      int matchedRoute = -1;
      SceneState matchedState;

      // Reset nonMatches hash list if we are checking a new path
      if(nonMatches.path != event.path || event.force == true) {
        nonMatches.path = event.path;
        nonMatches.hashes.clear();
      }

      // Check for semicolon and replace for ampersand, eg "?var1=a;var2=b"
      if(event.path.contains(';') == true) {
        event.path = event.path.replaceAll(';', '&');
      }

      // Search for a match among routes
      for(var i = 0; i < routes.length; i++) {
        print(" ##> Checking route: ${routes[i].name} , ${routes[i].path} (weight: ${routes[i].weight}, multi: ${routes[i].multi}) (${routerType})");
        if(nonMatches.hashes.contains(routes[i].hash) == false || routes[i].multi == true) {
          SceneState state = new SceneState();

          print(" --> Checking route: ${routes[i].name} , ${routes[i].path} (weight: ${routes[i].weight}, multi: ${routes[i].multi}) (${routerType})");

          // Setup common state object parameters
          state.name = routes[i].name;
          state.hash = routes[i].hash;

          // If the routes have the same weight, only try to match the url if
          // we don't have not already found a match. If the route have a higher
          // weight value then let the route "compete" to be showed.
          if(routes[i].enabled == true && foundMatch == false) {
            match = routes[i].parser.match(Uri.parse(event.path));

            print("");
            print(Uri.parse(event.path));
            print(routes[i].path);
            print("");


            if(match != null) {
              // Match, show
              foundMatch = true;
              matchedRoute = i;
              state.hidden = false;
              state.match = match;

              // Save state object in case a new element take over the view
              matchedState = state;
            } else {
              // Not a match, hide
              state.hidden = true;
              nonMatches.hashes.add(state.hash);
            }
          } else if(routes[i].enabled == true && foundMatch == true && routes[i].weight > routes[matchedRoute].weight) {
            match = routes[i].parser.match(Uri.parse(event.path));
            if(match != null) {
              // Hide previously showed element
              matchedState.hidden = true;
              nonMatches.hashes.add(matchedState.hash);

              // Broadcast state change
              stateStream.sink.add(matchedState);

              // Match, show the new winning element
              foundMatch = true;
              matchedRoute = i;
              state.hidden = false;
              state.match = match;

              // Save state object in case a new element take over the view
              matchedState = state;
            } else {
              // Not a match, hide
              state.hidden = true;
              nonMatches.hashes.add(state.hash);
            }
          } else {
            // Hide all disabled routes and routes with less weight than the
            // currently matched route
            state.hidden = true;
            nonMatches.hashes.add(state.hash);
          }

          if(state.hidden) {
            print(" --> Hide route: ${state.name} (${routes[i].path})");
          } else {
            print(" --> Show route: ${state.name} (${routes[i].path})");
          }

          // Broadcast state change, always do this except if the route is a
          // multi route, and it has already been matched successfully.
          if(routes[i].multi == false) {
            stateStream.sink.add(state);
          } else if(matchedRoute == i) {
            stateStream.sink.add(state);
          } else if(foundMatch == true && routes[i].hash != routes[matchedRoute].hash) {
            stateStream.sink.add(state);
          }
        }
      }
    });
  }

  /// Load current path
  void loadUrl({String path, bool force: false}) {
    print("path = $path");
    // Create new route event with pathname
    if(path == null) {
      routeEvent.sink.add(new RouteEvent(path: window.location.href.replaceFirst(window.location.origin, ''), force: force));
    } else {
      routeEvent.sink.add(new RouteEvent(path: path, force: force));
    }
  }

  /// Used for debugging
  String get routerType {
    if(isLayoutRouter == true) {
      return 'layoutRouter';
    } else if(isSceneRouter == true) {
      return 'sceneRouter';
    } else {
      return 'elementRouter';
    }
  }
}

class RouteEvent {
  String path;
  bool force;

  RouteEvent({this.path: '', this.force: false});
}

class ViewRoute extends Comparable {
  String name;
  int hash;
  String path;
  UriParser parser;

  int weight = 0; // New
  bool enabled = true; // New
  bool multi = false; // New

  int compareTo(ViewRoute other) {
    // Here we use String.compareTo() as a base for our compareTo(). We extend
    // it by replacing "{" with "!" ("!" in particular because of it's low ascii
    // representation, it is below a-z and 0-9 while "{" is above and hence
    // changing the result of the string sort making it so that paths with
    // variables in them gets sorted before those that don't have variables
    // but are similar otherwise. Consider "/users/points" and "/users/{user}",
    // normaly after sort and a reverse on the sorted list (we want longer paths first)
    // "/users/{user}" comes first. With this temp replacment during sort
    // "/users/points" comes before "/users/{user}".
    // Note: It is assumed that a list of routes should first be sorted with
    // the sort function provided here and then after that be reversed to get
    // the right list for url matching.
    return parser.template.template.replaceAll(r'{', "!")
        .compareTo(other.parser.template.template.replaceAll(r'{', "!"));
  }
}

