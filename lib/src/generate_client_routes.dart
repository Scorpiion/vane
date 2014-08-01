// Copyright (c) 2014, Robert Åkerblom-Andersson <Robert@dartvoid.com>

part of vane;

List<_VaneRoute> generateClientRoutes() {
  List<_VaneRoute> routes = new List<_VaneRoute>();
  InstanceMirror VaneClientProxyMirror = reflect(new VaneClientProxy());

  // Check if we should serve client files or not (dev vs production)
  if(Platform.environment['DART_PRODUCTION'] != null) {
    return routes;
  }

  // Get application root
  var appRoot = Platform.script.toFilePath();
  var pathList = appRoot.split("/");
  pathList.removeLast();        // Removes "server.dart" of /server/server.dart
  pathList.removeLast();        // Removes "server"  of /server/server.dart
  appRoot = pathList.join("/"); // Join list again to get app root

  // Parse app.yaml
  String content;
  try {
    var file = new File("${appRoot}/app.yaml");
    content = file.readAsStringSync();
  } catch (error) {
    Logger.root.warning("Could not find an app.yaml file in the application root, no client requests will be proxied");
    return routes;
  }

  // Parse app.yaml content
  var appConf = loadYaml(content);

  // For each client handler, add a new vane function handler route
  // TODO: Consider the value of "match" as well to reduce risk of differences
  //       between nginx and pub serve serving files. Now we are forcing
  //       the match to be "regex" for all dir handlers.
  for(var handler in appConf["client"]) {
    var url = handler["url"];
    var httpMethod = handler["method"];
    if(httpMethod == null) {
      httpMethod = "";
    }

    if(url != null) {
      // Setup podo controllers
      var mirror = VaneClientProxyMirror.type;
      String controller;
      Route baseMetaRoute;

      Logger.root.fine("Adding routes for podo controller: ${realname(mirror)}");

      // Add name and mirror to route
      controller = realname(mirror);

      // Create a new route object for each handler method (better for runtime
      // performance to give each handler their own route object since it makes
      // matching easier)
      for(var method in mirror.declarations.values.where((method)
          => method is MethodMirror && method.isRegularMethod)) {

        _VaneRoute route = new _VaneRoute();
        route.controller = controller;
        route.type = _podo;
        route.classMirror = mirror;

        route.method = realname(method);
        route.metaRoute = new Route(url, method: httpMethod, methods: []);
        route.parser = new UriParser(new UriTemplate(url));
        for(VariableMirror parameter in method.parameters) {
          Logger.root.fine("  Parameter = ${realname(parameter)}");
          route.parameters.add(realname(parameter));
        }

        // Save route to controller
        Logger.root.fine(" Adding podo handler \"${realname(mirror)}.${realname(method)}\" with path ${url}");
        routes.add(route);
      }
    }
  }

  return routes;
}

