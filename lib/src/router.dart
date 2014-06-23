// Copyright (c) 2014, Robert Åkerblom-Andersson <Robert@dartvoid.com>

part of vane;

class RouteMatch {
  UriMatch match;
  _VaneRoute matchedRoute;
  _Handler matchedHandler;
  bool foundMatch;
}

class Router {
  Controllers controllers;
  List<_VaneRoute> routes;

  Router() {
    controllers = scanControllers();
    routes = generateRoutes(controllers);
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
    InstanceMirror vaneController;
    InstanceMirror podoController;
    LibraryMirror funcController;
    List<String> handlerParams = new List<String>();

    // Setup paramters
    for(var i = 0; i < match.matchedHandler.parameters.length; i++) {
      if(match.match.parameters.keys.contains(match.matchedHandler.parameters[i])) {
        handlerParams.add(match.match.parameters[match.matchedHandler.parameters[i]]);
      } else {
        handlerParams.add("");
      }
    }

    // Setup controller specific settings and invoke controller
    switch(match.matchedRoute.type) {
      case _vane:
        print("Serving request ${match.match.input} with vane handler ${match.matchedRoute.name}.${match.matchedHandler.name}");

        // Create new instance of vane controller
        vaneController = match.matchedRoute.classMirror.newInstance(const Symbol(""), []);

        // Pipeline index
        int pIndex = 0;

        // Setup pre middlewares and their pipeline variables
        for(var i = 0; i < match.matchedRoute.pre.length; i++) {
          vaneController.reflectee.pre.add(match.matchedRoute.pre[i].newInstance(const Symbol(""), []).reflectee);

          // Setup pipeline variables
          vaneController.reflectee.pre[i]._index = pIndex;
          if(i == 0) {
            vaneController.reflectee.pre[i]._first = true;
          }
          pIndex++;
        }

        // Setup pipeline variables for main controller
        vaneController.reflectee._index = pIndex;
        if(pIndex == 0) {
          vaneController.reflectee._first = true;
        }
        if(pIndex == (match.matchedRoute.post.length + match.matchedRoute.pre.length)) {
          vaneController.reflectee._last = true;
        }
        pIndex++;

        // Setup post middlewares and their pipeline variables
        for(var i = 0; i < match.matchedRoute.post.length; i++) {
          vaneController.reflectee.post.add(match.matchedRoute.post[i].newInstance(const Symbol(""), []).reflectee);

          // Setup pipeline variables
          vaneController.reflectee.post[i]._index = pIndex;
          if(i == (match.matchedRoute.post.length - 1)) {
            vaneController.reflectee.post[i]._last = true;
          }
          pIndex++;
        }

        // Get handler function
        var handler = vaneController.getField(new Symbol(match.matchedHandler.name));

        // Run handler
        vaneController.invoke(new Symbol("call"), [request, handler.reflectee, handlerParams]);

        break;

      case _podo:
        print("Serving request ${match.match.input} with podo handler ${match.matchedRoute.name}.${match.matchedHandler.name}");

        // Create new instance of podo controller
        podoController = match.matchedRoute.classMirror.newInstance(const Symbol(""), []);

        // Run handler (-1 because of the HttpRequest that is always present)
        switch(handlerParams.length - 1) {
          case 0 : podoController.invoke(new Symbol(match.matchedHandler.name), [request]); break;
          case 1 : podoController.invoke(new Symbol(match.matchedHandler.name), [request, handlerParams[1]]); break;
          case 2 : podoController.invoke(new Symbol(match.matchedHandler.name), [request, handlerParams[1], handlerParams[2]]); break;
          case 3 : podoController.invoke(new Symbol(match.matchedHandler.name), [request, handlerParams[1], handlerParams[2], handlerParams[3]]); break;
          case 4 : podoController.invoke(new Symbol(match.matchedHandler.name), [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4]]); break;
          case 5 : podoController.invoke(new Symbol(match.matchedHandler.name), [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5]]); break;
          case 6 : podoController.invoke(new Symbol(match.matchedHandler.name), [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6]]); break;
          case 7 : podoController.invoke(new Symbol(match.matchedHandler.name), [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6], handlerParams[7]]); break;
          case 8 : podoController.invoke(new Symbol(match.matchedHandler.name), [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6], handlerParams[7], handlerParams[8]]); break;
          case 9 : podoController.invoke(new Symbol(match.matchedHandler.name), [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6], handlerParams[7], handlerParams[8], handlerParams[9]]); break;
          case 10: podoController.invoke(new Symbol(match.matchedHandler.name), [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6], handlerParams[7], handlerParams[8], handlerParams[9], handlerParams[10]]); break;
          case 11: podoController.invoke(new Symbol(match.matchedHandler.name), [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6], handlerParams[7], handlerParams[8], handlerParams[9], handlerParams[10], handlerParams[11]]); break;
          case 12: podoController.invoke(new Symbol(match.matchedHandler.name), [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6], handlerParams[7], handlerParams[8], handlerParams[9], handlerParams[10], handlerParams[11], handlerParams[12]]); break;
          case 13: podoController.invoke(new Symbol(match.matchedHandler.name), [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6], handlerParams[7], handlerParams[8], handlerParams[9], handlerParams[10], handlerParams[11], handlerParams[12], handlerParams[13]]); break;
          case 14: podoController.invoke(new Symbol(match.matchedHandler.name), [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6], handlerParams[7], handlerParams[8], handlerParams[9], handlerParams[10], handlerParams[11], handlerParams[12], handlerParams[13], handlerParams[14]]); break;
          case 15: podoController.invoke(new Symbol(match.matchedHandler.name), [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6], handlerParams[7], handlerParams[8], handlerParams[9], handlerParams[10], handlerParams[11], handlerParams[12], handlerParams[13], handlerParams[14], handlerParams[15]]); break;
          case 16: podoController.invoke(new Symbol(match.matchedHandler.name), [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6], handlerParams[7], handlerParams[8], handlerParams[9], handlerParams[10], handlerParams[11], handlerParams[12], handlerParams[13], handlerParams[14], handlerParams[15], handlerParams[16]]); break;
          case 17: podoController.invoke(new Symbol(match.matchedHandler.name), [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6], handlerParams[7], handlerParams[8], handlerParams[9], handlerParams[10], handlerParams[11], handlerParams[12], handlerParams[13], handlerParams[14], handlerParams[15], handlerParams[16], handlerParams[17]]); break;
          case 18: podoController.invoke(new Symbol(match.matchedHandler.name), [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6], handlerParams[7], handlerParams[8], handlerParams[9], handlerParams[10], handlerParams[11], handlerParams[12], handlerParams[13], handlerParams[14], handlerParams[15], handlerParams[16], handlerParams[17], handlerParams[18]]); break;
          case 19: podoController.invoke(new Symbol(match.matchedHandler.name), [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6], handlerParams[7], handlerParams[8], handlerParams[9], handlerParams[10], handlerParams[11], handlerParams[12], handlerParams[13], handlerParams[14], handlerParams[15], handlerParams[16], handlerParams[17], handlerParams[18], handlerParams[19]]); break;
          case 20: podoController.invoke(new Symbol(match.matchedHandler.name), [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6], handlerParams[7], handlerParams[8], handlerParams[9], handlerParams[10], handlerParams[11], handlerParams[12], handlerParams[13], handlerParams[14], handlerParams[15], handlerParams[16], handlerParams[17], handlerParams[18], handlerParams[19], handlerParams[20]]); break;
          case 21: podoController.invoke(new Symbol(match.matchedHandler.name), [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6], handlerParams[7], handlerParams[8], handlerParams[9], handlerParams[10], handlerParams[11], handlerParams[12], handlerParams[13], handlerParams[14], handlerParams[15], handlerParams[16], handlerParams[17], handlerParams[18], handlerParams[19], handlerParams[20], handlerParams[21]]); break;
          case 22: podoController.invoke(new Symbol(match.matchedHandler.name), [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6], handlerParams[7], handlerParams[8], handlerParams[9], handlerParams[10], handlerParams[11], handlerParams[12], handlerParams[13], handlerParams[14], handlerParams[15], handlerParams[16], handlerParams[17], handlerParams[18], handlerParams[19], handlerParams[20], handlerParams[21], handlerParams[22]]); break;
          case 23: podoController.invoke(new Symbol(match.matchedHandler.name), [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6], handlerParams[7], handlerParams[8], handlerParams[9], handlerParams[10], handlerParams[11], handlerParams[12], handlerParams[13], handlerParams[14], handlerParams[15], handlerParams[16], handlerParams[17], handlerParams[18], handlerParams[19], handlerParams[20], handlerParams[21], handlerParams[22], handlerParams[23]]); break;
          case 24: podoController.invoke(new Symbol(match.matchedHandler.name), [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6], handlerParams[7], handlerParams[8], handlerParams[9], handlerParams[10], handlerParams[11], handlerParams[12], handlerParams[13], handlerParams[14], handlerParams[15], handlerParams[16], handlerParams[17], handlerParams[18], handlerParams[19], handlerParams[20], handlerParams[21], handlerParams[22], handlerParams[23], handlerParams[24]]); break;
          case 25: podoController.invoke(new Symbol(match.matchedHandler.name), [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6], handlerParams[7], handlerParams[8], handlerParams[9], handlerParams[10], handlerParams[11], handlerParams[12], handlerParams[13], handlerParams[14], handlerParams[15], handlerParams[16], handlerParams[17], handlerParams[18], handlerParams[19], handlerParams[20], handlerParams[21], handlerParams[22], handlerParams[23], handlerParams[24], handlerParams[25]]); break;
          default: print("Error, too many paramters for handler");
        }

        break;

      case _func:
        print("Serving request ${match.match.input} with func handler ${match.matchedHandler.name}");

        // Create library mirror for func controller
        funcController = match.matchedRoute.funcMirror.owner;

        // Run handler (-1 because of the HttpRequest that is always present)
        switch(handlerParams.length - 1) {
          case 0 : funcController.invoke(match.matchedRoute.funcMirror.simpleName, [request]); break;
          case 1 : funcController.invoke(match.matchedRoute.funcMirror.simpleName, [request, handlerParams[1]]); break;
          case 2 : funcController.invoke(match.matchedRoute.funcMirror.simpleName, [request, handlerParams[1], handlerParams[2]]); break;
          case 3 : funcController.invoke(match.matchedRoute.funcMirror.simpleName, [request, handlerParams[1], handlerParams[2], handlerParams[3]]); break;
          case 4 : funcController.invoke(match.matchedRoute.funcMirror.simpleName, [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4]]); break;
          case 5 : funcController.invoke(match.matchedRoute.funcMirror.simpleName, [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5]]); break;
          case 6 : funcController.invoke(match.matchedRoute.funcMirror.simpleName, [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6]]); break;
          case 7 : funcController.invoke(match.matchedRoute.funcMirror.simpleName, [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6], handlerParams[7]]); break;
          case 8 : funcController.invoke(match.matchedRoute.funcMirror.simpleName, [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6], handlerParams[7], handlerParams[8]]); break;
          case 9 : funcController.invoke(match.matchedRoute.funcMirror.simpleName, [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6], handlerParams[7], handlerParams[8], handlerParams[9]]); break;
          case 10: funcController.invoke(match.matchedRoute.funcMirror.simpleName, [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6], handlerParams[7], handlerParams[8], handlerParams[9], handlerParams[10]]); break;
          case 11: funcController.invoke(match.matchedRoute.funcMirror.simpleName, [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6], handlerParams[7], handlerParams[8], handlerParams[9], handlerParams[10], handlerParams[11]]); break;
          case 12: funcController.invoke(match.matchedRoute.funcMirror.simpleName, [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6], handlerParams[7], handlerParams[8], handlerParams[9], handlerParams[10], handlerParams[11], handlerParams[12]]); break;
          case 13: funcController.invoke(match.matchedRoute.funcMirror.simpleName, [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6], handlerParams[7], handlerParams[8], handlerParams[9], handlerParams[10], handlerParams[11], handlerParams[12], handlerParams[13]]); break;
          case 14: funcController.invoke(match.matchedRoute.funcMirror.simpleName, [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6], handlerParams[7], handlerParams[8], handlerParams[9], handlerParams[10], handlerParams[11], handlerParams[12], handlerParams[13], handlerParams[14]]); break;
          case 15: funcController.invoke(match.matchedRoute.funcMirror.simpleName, [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6], handlerParams[7], handlerParams[8], handlerParams[9], handlerParams[10], handlerParams[11], handlerParams[12], handlerParams[13], handlerParams[14], handlerParams[15]]); break;
          case 16: funcController.invoke(match.matchedRoute.funcMirror.simpleName, [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6], handlerParams[7], handlerParams[8], handlerParams[9], handlerParams[10], handlerParams[11], handlerParams[12], handlerParams[13], handlerParams[14], handlerParams[15], handlerParams[16]]); break;
          case 17: funcController.invoke(match.matchedRoute.funcMirror.simpleName, [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6], handlerParams[7], handlerParams[8], handlerParams[9], handlerParams[10], handlerParams[11], handlerParams[12], handlerParams[13], handlerParams[14], handlerParams[15], handlerParams[16], handlerParams[17]]); break;
          case 18: funcController.invoke(match.matchedRoute.funcMirror.simpleName, [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6], handlerParams[7], handlerParams[8], handlerParams[9], handlerParams[10], handlerParams[11], handlerParams[12], handlerParams[13], handlerParams[14], handlerParams[15], handlerParams[16], handlerParams[17], handlerParams[18]]); break;
          case 19: funcController.invoke(match.matchedRoute.funcMirror.simpleName, [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6], handlerParams[7], handlerParams[8], handlerParams[9], handlerParams[10], handlerParams[11], handlerParams[12], handlerParams[13], handlerParams[14], handlerParams[15], handlerParams[16], handlerParams[17], handlerParams[18], handlerParams[19]]); break;
          case 20: funcController.invoke(match.matchedRoute.funcMirror.simpleName, [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6], handlerParams[7], handlerParams[8], handlerParams[9], handlerParams[10], handlerParams[11], handlerParams[12], handlerParams[13], handlerParams[14], handlerParams[15], handlerParams[16], handlerParams[17], handlerParams[18], handlerParams[19], handlerParams[20]]); break;
          case 21: funcController.invoke(match.matchedRoute.funcMirror.simpleName, [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6], handlerParams[7], handlerParams[8], handlerParams[9], handlerParams[10], handlerParams[11], handlerParams[12], handlerParams[13], handlerParams[14], handlerParams[15], handlerParams[16], handlerParams[17], handlerParams[18], handlerParams[19], handlerParams[20], handlerParams[21]]); break;
          case 22: funcController.invoke(match.matchedRoute.funcMirror.simpleName, [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6], handlerParams[7], handlerParams[8], handlerParams[9], handlerParams[10], handlerParams[11], handlerParams[12], handlerParams[13], handlerParams[14], handlerParams[15], handlerParams[16], handlerParams[17], handlerParams[18], handlerParams[19], handlerParams[20], handlerParams[21], handlerParams[22]]); break;
          case 23: funcController.invoke(match.matchedRoute.funcMirror.simpleName, [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6], handlerParams[7], handlerParams[8], handlerParams[9], handlerParams[10], handlerParams[11], handlerParams[12], handlerParams[13], handlerParams[14], handlerParams[15], handlerParams[16], handlerParams[17], handlerParams[18], handlerParams[19], handlerParams[20], handlerParams[21], handlerParams[22], handlerParams[23]]); break;
          case 24: funcController.invoke(match.matchedRoute.funcMirror.simpleName, [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6], handlerParams[7], handlerParams[8], handlerParams[9], handlerParams[10], handlerParams[11], handlerParams[12], handlerParams[13], handlerParams[14], handlerParams[15], handlerParams[16], handlerParams[17], handlerParams[18], handlerParams[19], handlerParams[20], handlerParams[21], handlerParams[22], handlerParams[23], handlerParams[24]]); break;
          case 25: funcController.invoke(match.matchedRoute.funcMirror.simpleName, [request, handlerParams[1], handlerParams[2], handlerParams[3], handlerParams[4], handlerParams[5], handlerParams[6], handlerParams[7], handlerParams[8], handlerParams[9], handlerParams[10], handlerParams[11], handlerParams[12], handlerParams[13], handlerParams[14], handlerParams[15], handlerParams[16], handlerParams[17], handlerParams[18], handlerParams[19], handlerParams[20], handlerParams[21], handlerParams[22], handlerParams[23], handlerParams[24], handlerParams[25]]); break;
          default: print("Error, too many paramters for handler");
        }

        break;

      default:
        // Error, should never happend...
    }
  }
}

