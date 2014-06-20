part of vane;

void serve() {
  Router router = new Router();

  var appRoot = path.current;
  appRoot = "/home/robert/dv-workplace/Vane-Hello-World";

  runZoned(() {
    // Server port assignment
    var portEnv = Platform.environment['PORT'];
    var port = portEnv != null ? int.parse(portEnv) : 8081;
    VirtualDirectory serveClient;

    // Start client handler
    if(portEnv == null) {
      serveClient = new VirtualDirectory(appRoot)
      ..allowDirectoryListing = false;
    }

    print("Starting vane server: 127.0.0.1:${port}");

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

