// Copyright (c) 2014, Robert Åkerblom-Andersson <Robert.nr1@gmail.com>

part of vane;

Route parseRoute(InstanceMirror routeMirror, [Route baseRoute]) {
  Route route;

  if(routeMirror.reflectee is Route) {
    InstanceMirror pathMirror = routeMirror.getField(const Symbol("path"));
    InstanceMirror methodMirror = routeMirror.getField(const Symbol("method"));
    InstanceMirror methodMirrors = routeMirror.getField(const Symbol("methods"));

    // Build
    if(baseRoute == null) {
      route = new Route(pathMirror.reflectee,
                        method: methodMirror.reflectee,
                        methods: methodMirrors.reflectee);
    } else {
      List<String> allMethods = new List();
      List<String> methods = new List();
      String method;

      // Let parameter method override baseRoutes method
      if(methodMirror.reflectee == "") {
        method = baseRoute.method;
      } else {
        method = methodMirror.reflectee;
      }

      // Avoid adding duplicate methods
      allMethods.addAll(baseRoute.methods);
      allMethods.addAll(methodMirrors.reflectee);

      for(var method in allMethods) {
        if(methods.contains(method) == false) {
          methods.add(method);
        }
      }

      route = new Route("${baseRoute.path}${pathMirror.reflectee}",
                        method: method,
                        methods: methods);
    }
  } else {
    Logger.root.info("${routeMirror.reflectee} is not Route");
  }

  return route;
}

