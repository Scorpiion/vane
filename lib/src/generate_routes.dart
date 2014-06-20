part of vane;

List<_VaneRoute> generateRoutes(List<ClassMirror> controllerMirrors) {
  List<_VaneRoute> routes = new List<_VaneRoute>();

  for(var controllerMirror in controllerMirrors) {
    _VaneRoute route = new _VaneRoute();

//    print("Adding routes for controller: ${realname(controllerMirror)}");

    route.name = realname(controllerMirror);
    route.mirror = controllerMirror;

    // Setup base route if declared
    for(var meta in controllerMirror.metadata) {
      if(meta.reflectee is Route) {
        route.baseRoute = parseRoute(meta);
      }
    }

    // Add handler routes
    for(var method in controllerMirror.declarations.values.where((mirror)
        => mirror is MethodMirror && mirror.isRegularMethod)) {
      // Check if the method have a @Route annotation
      if(method.metadata.any((meta) => meta.reflectee is Route) == true) {
        _Handler handler = new _Handler();

        // Save handler route
        for(var meta in method.metadata) {
          if(meta.reflectee is Route) {
//            print(" Adding handler: ${realname(method)}");
            handler.name = realname(method);
            handler.route = parseRoute(meta, route.baseRoute);
            handler.parser = new UriParser(new UriTemplate(handler.route.path));
            for(VariableMirror parameter in method.parameters) {
//              print("  Parameter = ${realname(parameter)}");
              handler.parameters.add(realname(parameter));
            }
          }
        }

        // Save handler to route
        route.handlers.add(handler);
      }
    }

    // Setup pipeline
    var middlewares = parsePipeline(controllerMirror);
    if(middlewares == null) {
      exit(-1);
    }

    route.pre = middlewares.pre;
    route.post = middlewares.post;

    // Save route to controller
    routes.add(route);
  }

  return routes;
}

