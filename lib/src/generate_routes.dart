// Copyright (c) 2014, Robert Åkerblom-Andersson <Robert@dartvoid.com>

part of vane;

const String _vane = "vane";
const String _podo = "podo";
const String _func = "func";

class _VaneRoute extends Comparable {
  String controller;
  String method;
  String type;
  Route metaRoute;
  UriParser parser;
  List<String> parameters = [];
  List<ClassMirror> pre;
  List<ClassMirror> post;
  ClassMirror classMirror;
  MethodMirror funcMirror;

  int compareTo(_VaneRoute other) {
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

List<_VaneRoute> generateRoutes(Controllers controllers) {
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
    for(var method in mirror.declarations.values.where((method)
        => method is MethodMirror && method.isRegularMethod)) {
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
    for(var method in mirror.declarations.values.where((method)
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

  // Sort routes
  routes.sort();

  // Reverse list so that the longest paths comes first
  routes = new List.from(routes.reversed);

  return routes;
}

String realname(DeclarationMirror mirror) {
  return mirror.simpleName.toString().split('"')[1];
}

