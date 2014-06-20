part of vane;

const String GET    = "GET";
const String POST   = "POST";
const String PUT    = "PUT";
const String DELETE = "DELETE";

class Route {
  final String path;
  final String method;
  final List<String> methods;

  const Route(this.path, {this.method: "", this.methods: const []});
}

class _This {
  const _This();
}

const This = const _This();

String realname(DeclarationMirror mirror) {
  return mirror.simpleName.toString().split('"')[1];
}

class _VaneRoute {
  String name;
  Route baseRoute;
  List<_Handler> handlers = [];
  List<ClassMirror> pre;
  List<ClassMirror> post;
  ClassMirror mirror;
}

class _Handler {
  String name;
  Route route;
  UriParser parser;
  List<String> parameters = [];
}

Route parseRoute(InstanceMirror routeMirror, [Route baseRoute]) {
  Route route;

  if(routeMirror.reflectee is Route) {
    InstanceMirror pathMirror = routeMirror.getField(const Symbol("path"));
    InstanceMirror methodMirror = routeMirror.getField(const Symbol("method"));
    InstanceMirror methodMirrors = routeMirror.getField(const Symbol("methods"));
//    print(" path     = ${path.reflectee}");
//    print(" method   = ${method.reflectee}");
//    print(" methods  = ${methods.reflectee}");

    // Build
    if(baseRoute == null) {
      route = new Route(pathMirror.reflectee,
                        method: methodMirror.reflectee,
                        methods: methodMirrors.reflectee);
    } else {
      List<String> allMethods = new List();
      List<String> methods;
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
    print("${routeMirror.reflectee} is not Route");
  }

  return route;
}

