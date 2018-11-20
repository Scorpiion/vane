// Copyright (c) 2014, Robert Åkerblom-Andersson <Robert.nr1@gmail.com>

part of vane;

const String _DEFAULT_ADDRESS = "0.0.0.0";
const int _DEFAULT_PORT       = 9090;

void serve({String address: _DEFAULT_ADDRESS,
            int port: _DEFAULT_PORT,
            Level logLevel: Level.CONFIG,
            String mongoUri: ""}) {
  // Setup logger
  Logger.root.level = logLevel;
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

  // Override MongoDB uri if provided
  if(mongoUri != "") {
    MONGODB_URI = mongoUri;
  }

  // Parse scan code for handlers and create a router
  Router router = new Router();

  // Serve incomming requests
  runZoned(() {
    // Server port assignment
    var addressEnv = Platform.environment['ADDRESS'];
    var portEnv = Platform.environment['PORT'];
    var finalAddress = addressEnv != null ? addressEnv : address;
    var finalPort = portEnv != null ? int.parse(portEnv) : port;

    Logger.root.info("Starting vane server: ${finalAddress}:${finalPort}");

    HttpServer.bind(finalAddress, finalPort).then((server) {
      RouteMatch match;

      server.listen((HttpRequest request) {
        // See if we have a match for the request
        match = router.matchRequest(request);
        if(match.match != null) {
          // Serve server request
          router.serve(request, match);
        } else {
          Logger.root.warning("Could not find any handler matching path: ${request.uri.path}");
          request.response.statusCode = HttpStatus.notFound;
          request.response.close();
        }
      });
    });
  },
  onError: (e, stackTrace) {
    Logger.root.warning(e.toString());
    Logger.root.warning("\n");
    Logger.root.warning(stackTrace.toString());
  });
}

