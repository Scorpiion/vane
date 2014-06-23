// Copyright (c) 2014, Robert Åkerblom-Andersson <Robert@dartvoid.com>

part of vane;

class RouteMatch {
  UriMatch match;
  _VaneRoute matchedRoute;
  _Handler matchedHandler;
  bool foundMatch;
}

class Router {
  List<ClassMirror> controllerMirrors;
  List<_VaneRoute> routes;

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
    var controller = match.matchedRoute.mirror.newInstance(const Symbol(""), []);

    // Pipeline index
    int pIndex = 0;

    // Setup pre middlewares and their pipeline variables
    for(var i = 0; i < match.matchedRoute.pre.length; i++) {
      controller.reflectee.pre.add(match.matchedRoute.pre[i].newInstance(const Symbol(""), []).reflectee);

      // Setup pipeline variables
      controller.reflectee.pre[i]._index = pIndex;
      if(i == 0) {
        controller.reflectee.pre[i]._first = true;
      }
      pIndex++;
    }

    // Setup pipeline variables for main controller
    controller.reflectee._index = pIndex;
    if(pIndex == 0) {
      controller.reflectee._first = true;
    }
    if(pIndex == (match.matchedRoute.post.length + match.matchedRoute.pre.length)) {
      controller.reflectee._last = true;
    }
    pIndex++;

    // Setup post middlewares and their pipeline variables
    for(var i = 0; i < match.matchedRoute.post.length; i++) {
      controller.reflectee.post.add(match.matchedRoute.post[i].newInstance(const Symbol(""), []).reflectee);

      // Setup pipeline variables
      controller.reflectee.post[i]._index = pIndex;
      if(i == (match.matchedRoute.post.length - 1)) {
        controller.reflectee.post[i]._last = true;
      }
      pIndex++;
    }

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
    var handler = controller.getField(new Symbol(match.matchedHandler.name));

    // Run handler
    controller.invoke(new Symbol("call"), [request, handler.reflectee, handlerParams]);
  }
}

