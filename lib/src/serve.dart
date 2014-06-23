// Copyright (c) 2014, Robert Åkerblom-Andersson <Robert@dartvoid.com>

part of vane;

void serve() {
  Router router = new Router();

  var appRoot = path.current;
  appRoot = "/home/robert/dv-workplace/Vane-Hello-World";

  // Setup logger
  Logger.root.level = Level.CONFIG;
  Logger.root.onRecord.listen((LogRecord rec) {
    if(rec.level == Level.SEVERE ||
       rec.level == Level.SHOUT ||
       rec.level == Level.WARNING) {
      var name = (rec.loggerName.length == 0) ? "" : " ${rec.loggerName}";
      stderr.write('${rec.time} ${rec.level.name}${name}: ${rec.message}\n');
    } else {
      var name = (rec.loggerName.length == 0) ? "" : " ${rec.loggerName}";
      stdout.write('${rec.time} ${rec.level.name}${name}: ${rec.message}\n');
    }
  });

  runZoned(() {
    // Server port assignment
    var portEnv = Platform.environment['PORT'];
    var port = portEnv != null ? int.parse(portEnv) : 8080;
    VirtualDirectory serveClient;

    // Start client handler
    if(portEnv == null) {
      serveClient = new VirtualDirectory(appRoot)
      ..allowDirectoryListing = false;
    }

    Logger.root.info("Starting vane server: 127.0.0.1:${port}");

    HttpServer.bind("127.0.0.1", port).then((server) {
      RouteMatch match;

      server.listen((HttpRequest request) {
        // Check if path matches any static code first...
        // Then proxy request to subprocess running pub serve
//        serveClient.serveRequest(request);

        // See if we have a match for the request
        match = router.matchRequest(request);
        if(match.match != null) {
          // Serve server request
          router.serve(request, match);
        } else {
          stderr.writeln("Error 404: Could not find any handler matching path: ${request.uri.path}");
          request.response.close();
        }
      });
    });
  },
  onError: (e, stackTrace) {
    stderr.writeln(e);
    stderr.writeln("\n");
    stderr.writeln(stackTrace);
  });
}

