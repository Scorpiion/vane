// Copyright (c) 2014, Robert Åkerblom-Andersson <Robert.nr1@gmail.com>

part of vane;

List<_VaneRoute> generateServerRoutes(Controllers controllers) {
  List<_VaneRoute> routes = new List<_VaneRoute>();

  // Setup vane controllers
  for(var mirror in controllers.vaneControllers) {
    String controller;
    Route baseMetaRoute;
    _Middlewares middlewares;

    Logger.root.fine("Adding routes for controller ${realname(mirror)}");

    // Add name and mirror to route
    controller = realname(mirror);

    // Setup base route if declared
    for(var meta in mirror.metadata) {
      if(meta.reflectee is Route) {
        baseMetaRoute = parseRoute(meta);
      }
    }

    // Setup pipeline
    middlewares = parsePipeline(mirror);
    if(middlewares == null) {
      // TODO: Should we really use exit() here, maybe just ignore the
      //       controller with a bad middleware setup and continue instead?
      exit(-1);
    }

    // Create a new route object for each handler method (better for runtime
    // performance to give each handler their own route object since it makes
    // matching easier)
    for(MethodMirror method in mirror.declarations.values.where((method) => method is MethodMirror && method.isRegularMethod)) {
      // Check if the method have a @Route annotation
      if(method.metadata.any((meta) => meta.reflectee is Route) == true) {
        for(var meta in method.metadata) {
          if(meta.reflectee is Route) {
            _VaneRoute route = new _VaneRoute();
            route.controller = controller;
            route.type = _vane;
            route.classMirror = mirror;

            route.method = realname(method);
            route.metaRoute = parseRoute(meta, baseMetaRoute);
            route.parser = new UriParser(new UriTemplate(route.metaRoute.path));
            for(VariableMirror parameter in method.parameters) {
              Logger.root.fine("  Parameter = ${realname(parameter)}");
              route.parameters.add(realname(parameter));
            }

            // Save middleware
            route.pre = middlewares.pre;
            route.post = middlewares.post;

            // Save route to controller
            Logger.root.fine(" Adding vane handler \"${realname(mirror)}.${realname(method)}\" with path ${route.metaRoute.path}");
            routes.add(route);
          }
        }
      }
    }
  }

  // Setup podo controllers
  for(var mirror in controllers.podoControllers) {
    String controller;
    Route baseMetaRoute;

    Logger.root.fine("Adding routes for podo controller: ${realname(mirror)}");

    // Add name and mirror to route
    controller = realname(mirror);

    // Setup base route if declared
    for(var meta in mirror.metadata) {
      if(meta.reflectee is Route) {
        baseMetaRoute = parseRoute(meta);
      }
    }

    // Create a new route object for each handler method (better for runtime
    // performance to give each handler their own route object since it makes
    // matching easier)
    for(MethodMirror method in mirror.declarations.values.where((method)
        => method is MethodMirror && method.isRegularMethod)) {
      // Check if the method have a @Route annotation
      if(method.metadata.any((meta) => meta.reflectee is Route) == true) {
        for(var meta in method.metadata) {
          if(meta.reflectee is Route) {
            _VaneRoute route = new _VaneRoute();
            route.controller = controller;
            route.type = _podo;
            route.classMirror = mirror;

            route.method = realname(method);
            route.metaRoute = parseRoute(meta, baseMetaRoute);
            route.parser = new UriParser(new UriTemplate(route.metaRoute.path));
            for(VariableMirror parameter in method.parameters) {
              Logger.root.fine("  Parameter = ${realname(parameter)}");
              route.parameters.add(realname(parameter));
            }

            // Save route to controller
            Logger.root.fine(" Adding podo handler \"${realname(mirror)}.${realname(method)}\" with path ${route.metaRoute.path}");
            routes.add(route);
          }
        }
      }
    }
  }

  // Setup func controllers
  for(var mirror in controllers.funcControllers) {
    for(var meta in mirror.metadata) {
      if(meta.reflectee is Route) {
        _VaneRoute route = new _VaneRoute();

        // Add name and mirror to route
        route.method = realname(mirror);
        route.type = _func;
        route.funcMirror = mirror;

        route.metaRoute = parseRoute(meta);
        route.parser = new UriParser(new UriTemplate(route.metaRoute.path));

        for(VariableMirror parameter in mirror.parameters) {
          Logger.root.fine("  Parameter = ${realname(parameter)}");
          route.parameters.add(realname(parameter));
        }

        // Save route
        Logger.root.fine("Adding routes for func controller: ${realname(mirror)} with path ${route.metaRoute.path}");
        routes.add(route);
      }
    }
  }

  return routes;
}

