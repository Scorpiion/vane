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

  // Parse dv.yaml
  String content;
  try {
    var file = new File("${appRoot}/dv.yaml");
    content = file.readAsStringSync();
  } catch (error) {
    Logger.root.warning("Could not find an dv.yaml file in the application root, no client requests will be proxied");
    return routes;
  }

  // Parse dv.yaml content
  var appConf = loadYaml(content);

  // For each client handler, add a new vane function handler route
  // TODO: Consider the value of "match" as well to reduce risk of differences
  //       between nginx and pub serve serving files. Now we are forcing
  //       the match to be "regex" for all dir handlers.
  if(appConf["client"] != null) {
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

        // Create a new route object
        MethodMirror method = mirror.declarations[#pubProxy];
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

  // For each spa handler, add a new vane function handler route
  if(appConf["spa"] != null) {
    for(var handler in appConf["spa"]) {
      var url = handler["url"];
      var httpMethod = handler["method"];
      if(httpMethod == null) {
        httpMethod = "";
      }

      // Add path to spa paths
      VaneClientProxy.spaPaths.add(url);

      if(url != null) {
        // Setup podo controllers
        var mirror = VaneClientProxyMirror.type;
        String controller;
        Route baseMetaRoute;

        Logger.root.fine("Adding routes for podo controller: ${realname(mirror)}");

        // Add name and mirror to route
        controller = realname(mirror);

        // Create a new route object
        MethodMirror method = mirror.declarations[#spaProxy];
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

      // Sort SPA paths
      VaneClientProxy.spaPaths.sort((x, y) => x.length.compareTo(y.length));

      // Reverse list so that the longest paths comes first
      VaneClientProxy.spaPaths = new List.from(VaneClientProxy.spaPaths.reversed);
    }
  }

  return routes;
}

