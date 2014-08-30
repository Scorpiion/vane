library vane_elements.vane_router;

import 'dart:html';
import 'dart:async';
import 'package:polymer/polymer.dart';
import 'package:uri/uri.dart';
import 'package:logging/logging.dart';

import 'package:vane/elements/vane_view/vane_view.dart';

class ViewState {
  String name;
  int hash;
  bool hidden;
}

class HashList {
  String path = "";
  List<int> hashes = new List<int>();
}

/**
 * Vane client router component
 */
@CustomTag('vane-router')
class VaneRouter extends PolymerElement {
  static StreamController routeStream = new StreamController.broadcast(onListen: () => print("Someone is listening"));
  static StreamController viewRegistration = new StreamController();
  static List<ViewRoute> routes = [];

  @published String logLevel = "";

  /// Constructor used to create instance of VaneServe.
  VaneRouter.created() : super.created() {
    switch(logLevel) {
      case 'ALL':
        Logger.root.level = Level.ALL;
        break;
      case 'OFF':
        Logger.root.level = Level.OFF;
        break;
      case 'FINEST':
        Logger.root.level = Level.FINEST;
        break;
      case 'FINER':
        Logger.root.level = Level.FINER;
        break;
      case 'FINE':
        Logger.root.level = Level.FINE;
        break;
      case 'CONFIG':
        Logger.root.level = Level.CONFIG;
        break;
      case 'INFO':
        Logger.root.level = Level.INFO;
        break;
      case 'WARNING':
        Logger.root.level = Level.WARNING;
        break;
      case 'SEVERE':
        Logger.root.level = Level.SEVERE;
        break;
      case 'SHOUT':
        Logger.root.level = Level.SHOUT;
        break;
      default:
        Logger.root.level = Level.CONFIG;
        break;
    }

    // Setup logger
    Logger.root.onRecord.listen((LogRecord rec) {
      if(rec.level == Level.SEVERE ||
         rec.level == Level.SHOUT ||
         rec.level == Level.WARNING) {
        var name = (rec.loggerName.length == 0) ? "" : " ${rec.loggerName}";
        window.console.error('${rec.time} ${rec.level.name}${name}: ${rec.message}');
      } else {
        var name = (rec.loggerName.length == 0) ? "" : " ${rec.loggerName}";
        window.console.info('${rec.time} ${rec.level.name}${name}: ${rec.message}');
      }
    });
  }

  /*
   * Optional lifecycle methods - uncomment if needed.
   */

  /// Called when an instance of vane-serve is inserted into the DOM.
  attached() {
    super.attached();

    window.onPopState.listen((PopStateEvent e) {
      print("Got pop state event, running VaneServe.load()");
      VaneRouter.load();
    });

    window.onHashChange.listen((HashChangeEvent e) {
      print("2 Got hash change oldUrl: ${e.oldUrl}");
      print("2 Got hash change newUrl: ${e.newUrl}");
      print("2 Got hash change path  : ${e.path}");
    });
  }

  static HashList nonMatches = new HashList();

  static void load({String path, List<int> registeredHashes}) {
    UriMatch match;
    bool foundMatch = false;
    ViewRoute route;

    // Load the path that's in the url field if none other is provided
    if(path == null) {
      path = window.location.pathname;
    }

    // Reset nonMatches hash list if we are checking a new path
    if(nonMatches.path != path) {
      nonMatches.path = path;
      nonMatches.hashes.clear();
    }

//    print("#####################################################");
//    print("Loading new page: $path");
//    print("#####################################################");

    for(var i = 0; i < routes.length; i++) {
      if(nonMatches.hashes.contains(routes[i].hash) == false) {
        ViewState state = new ViewState();

  //      print("");
  //      print('name     = ${routes[i].name}');
  //      print('path     = ${routes[i].path}');
  //      print('location = $path');
  //      print("");

        // Setup state object
        state.name = routes[i].name;
        state.hash = routes[i].hash;

        if(foundMatch == false) {
          match = routes[i].parser.match(Uri.parse(path));

          if(match != null) {
            state.hidden = false;
            foundMatch = true;
            route = routes[i];
          } else {
            state.hidden = true;
            nonMatches.hashes.add(state.hash);
          }
        } else if(routes[i].path == route.path ||
                  routes[i].app == true ||
                  routes[i].views.contains(route.name)) {
          state.hidden = false;
        } else {
          state.hidden = true;
          nonMatches.hashes.add(state.hash);
        }

        if(state.hidden) {
          print("Hide : ${state.name} (${routes[i].path})");
        } else {
          print(" Show : ${state.name} (${routes[i].path})");
        }

      // Send state to view
      routeStream.sink.add(state);
      }
    }
    print("");

    if(foundMatch == false) {
      print("Found no new path for ${path}, staying on current view");
    }
  }

  /// Called when an instance of vane-serve is removed from the DOM.
  detached() {
    super.detached();
  }

  /// Called when an attribute (such as  a class) of an instance of
  /// vane-serve is added, changed, or removed.
  attributeChanged(String name, String oldValue, String newValue) {
  }

  /// Called when vane-serve has been fully prepared (Shadow DOM created,
  /// property observers set up, event listeners attached).
  ready() {

    VaneRouter.viewRegistration.stream.listen((ViewRoute route) {
      // Create parser for path
      route.parser = new UriParser(new UriTemplate(route.path));

      // Check if route contain special "app pseudo view", equivalent to
      // a view with the path "/"
      while(route.views.remove("app")) {
        route.app = true;
      }

      // Add route to list of routes
      routes.add(route);

      /*
      print("");
      print("Before sort:");
      for(var i = 0; i < routes.length; i++) {
        print(routes[i].path);
      }
       */

      // Sort routes
      routes.sort();

      /*
      print("");
      print("After sort:");
      for(var i = 0; i < routes.length; i++) {
        print(routes[i].path);
      }
       */

      // Reverse list so that the longest paths comes first
      routes = new List.from(routes.reversed);

      /*
      print("");
      print("After reverse:");
      for(var i = 0; i < routes.length; i++) {
        print(routes[i].path);
      }
       */

      // Load view
      VaneRouter.load();
    });

    // Check current url and load the correct view
    VaneRouter.load();
  }
}

