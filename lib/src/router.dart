part of vane;

class RouteMatch {
  UriMatch match;
  _VaneRoute matchedRoute;
  _Handler matchedHandler;
  bool foundMatch;
}

class Router {
  List<_VaneRoute> routes;
  List<ClassMirror> controllerMirrors;

  Router() {
    controllerMirrors = getControllerMirrors();
    routes = generateRoutes(controllerMirrors);
  }

  RouteMatch matchRequest(HttpRequest request) {
    RouteMatch match = new RouteMatch();
    _VaneRoute matchedRoute;
    _Handler matchedHandler;

    // Check request uri against routes
    for(var route in routes) {
//      print("Checking controller: ${route.name}");
      for(var handler in route.handlers) {
//        print(" Checking handler: ${handler.name}");
//        print(" Checking path: ${handler.parser.template}");

        match.match = handler.parser.match(request.uri);
        if(match.match != null) {
          match.foundMatch = true;
          match.matchedHandler = handler;
          match.matchedRoute = route;
          // Break out from inner loop
          break;
        }
      }
      if(match.match != null) {
        // Break out from outer loop
        break;
      }
    }

    return match;
  }

  void serve(HttpRequest request, RouteMatch match) {
    print("Serving request ${match.match.input} with handler ${match.matchedRoute.name}.${match.matchedHandler.name}");

    // Create new instance of controller
    var ob = match.matchedRoute.mirror.newInstance(const Symbol(""), []);

    // Setup pipeline
    match.matchedRoute.pre.forEach((middlewareMirror) =>
        ob.reflectee.pre.add(middlewareMirror.newInstance(const Symbol(""), []).reflectee));
    match.matchedRoute.post.forEach((middlewareMirror) =>
        ob.reflectee.post.add(middlewareMirror.newInstance(const Symbol(""), []).reflectee));

    // Setup paramters
    List<String> handlerParams = new List();
    for(var i = 0; i < match.matchedHandler.parameters.length; i++) {
      if(match.match.parameters.keys.contains(match.matchedHandler.parameters[i])) {
        handlerParams.add(match.match.parameters[match.matchedHandler.parameters[i]]);
      } else {
        handlerParams.add("");
      }
    }

    // Get handler function
    var handler = ob.getField(new Symbol(match.matchedHandler.name));

    // Run handler
    ob.invoke(new Symbol("call"), [request, handler.reflectee, handlerParams]);
  }
}

