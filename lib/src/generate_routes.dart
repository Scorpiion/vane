// Copyright (c) 2014, Robert Åkerblom-Andersson <Robert@dartvoid.com>

part of vane;

const String _vane = "vane";
const String _podo = "podo";
const String _func = "func";

class _VaneRoute {
  String name;
  String type;
  Route baseRoute;
  List<_Handler> handlers = [];
  List<ClassMirror> pre;
  List<ClassMirror> post;
  ClassMirror classMirror;
  MethodMirror funcMirror;
}

class _Handler {
  String name;
  Route route;
  UriParser parser;
  List<String> parameters = [];
}

List<_VaneRoute> generateRoutes(Controllers controllers) {
  List<_VaneRoute> routes = new List<_VaneRoute>();

  // Setup vane controllers
  for(var mirror in controllers.vaneControllers) {
    _VaneRoute route = new _VaneRoute();
//    print("Adding routes for controller: ${realname(mirror)}");

    // Add name and mirror to route
    route.name = realname(mirror);
    route.type = _vane;
    route.classMirror = mirror;

    // Setup base route if declared
    for(var meta in mirror.metadata) {
      if(meta.reflectee is Route) {
        route.baseRoute = parseRoute(meta);
      }
    }

    // Add handler routes
    for(var method in mirror.declarations.values.where((method)
        => method is MethodMirror && method.isRegularMethod)) {
      // Check if the method have a @Route annotation
      if(method.metadata.any((meta) => meta.reflectee is Route) == true) {
        _Handler handler = new _Handler();

        // Save handler route
        for(var meta in method.metadata) {
          if(meta.reflectee is Route) {
//            print(" Adding vane handler: ${realname(method)}");
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
    var middlewares = parsePipeline(mirror);
    if(middlewares == null) {
      exit(-1);
    }

    route.pre = middlewares.pre;
    route.post = middlewares.post;

    // Save route to controller
    routes.add(route);
  }

  // Setup podo controllers
  for(var mirror in controllers.podoControllers) {
    _VaneRoute route = new _VaneRoute();
//    print("Adding routes for podo controller: ${realname(mirror)}");

    // Add name and mirror to route
    route.name = realname(mirror);
    route.type = _podo;
    route.classMirror = mirror;

    // Setup base route if declared
    for(var meta in mirror.metadata) {
      if(meta.reflectee is Route) {
        route.baseRoute = parseRoute(meta);
      }
    }

    // Add handler routes
    for(var method in mirror.declarations.values.where((method)
        => method is MethodMirror && method.isRegularMethod)) {
      // Check if the method have a @Route annotation
      if(method.metadata.any((meta) => meta.reflectee is Route) == true) {
        _Handler handler = new _Handler();

        // Save handler route
        for(var meta in method.metadata) {
          if(meta.reflectee is Route) {
//            print(" Adding podo handler: ${realname(method)}");
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

    // Save route to controller
    routes.add(route);
  }

  // Setup func controllers
  for(var mirror in controllers.funcControllers) {
    _VaneRoute route = new _VaneRoute();
//    print("Adding routes for func controller: ${realname(mirror)}");

    // Add name and mirror to route
    route.name = realname(mirror);
    route.type = _func;
    route.funcMirror = mirror;

    // Add handler route
    _Handler handler = new _Handler();

    // Save handler route
    for(var meta in mirror.metadata) {
      if(meta.reflectee is Route) {
//        print(" Adding func handler: ${realname(mirror)}");
        handler.name = realname(mirror);
        handler.route = parseRoute(meta, route.baseRoute);
        handler.parser = new UriParser(new UriTemplate(handler.route.path));
        for(VariableMirror parameter in mirror.parameters) {
//          print("  Parameter = ${realname(parameter)}");
          handler.parameters.add(realname(parameter));
        }
      }
    }

    // Save handler to route
    route.handlers.add(handler);

    // Save route to controller
    routes.add(route);
  }

  return routes;
}

String realname(DeclarationMirror mirror) {
  return mirror.simpleName.toString().split('"')[1];
}

