// Copyright (c) 2014, Robert Åkerblom-Andersson <Robert@dartvoid.com>

part of vane;

/**
 * Start serving requests.
 *
 * Regarding SSL support, consult the documentation of [SecureSocket.initialize]
 * for information on the parameters.
 */
void serve({String host: "127.0.0.1",
            int port: 9090,
            String sslCertificateName,
            String sslCertificateDatabase,
            String sslCertificateDatabasePassword,
            int sslPort: 9091,
            bool sslOnly: false,
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

  // Server port assignment
  var portEnv = Platform.environment['PORT'];
  port = portEnv != null ? int.parse(portEnv) : port;
  var httpsPortEnv = Platform.environment['PORT_SSL'];
  sslPort = httpsPortEnv != null ? int.parse(httpsPortEnv) : sslPort;

  // Serve incoming requests
  runZoned(() {
    // Function that sets up the server binding
    Function serverBinding = (HttpServer server) {
      RouteMatch match;
      server.listen((HttpRequest request) {
        // See if we have a match for the request
        match = router.matchRequest(request);
        if(match.match != null) {
          // Serve server request
          router.serve(request, match);
        } else {
          Logger.root.warning("Could not find any handler matching path: ${request.uri.path}");
          request.response.statusCode = HttpStatus.NOT_FOUND;
          request.response.close();
        }
      });
    };

    // Check if SSL is configured correctly and start HTTPS binding if so
    if(sslCertificateName != null && sslCertificateDatabase != null && sslCertificateDatabasePassword != null) {
      Logger.root.info("Starting Vane server on HTTPS: ${host}:${port}");
      SecureSocket.initialize(database: sslCertificateDatabase, password: sslCertificateDatabasePassword);
      HttpServer.bindSecure(host, sslPort, certificateName: sslCertificateName).then(serverBinding);
    }

    // Start regular HTTP binding
    if(!sslOnly) {
      Logger.root.info("Starting Vane server on HTTP: ${host}:${port}");
      HttpServer.bind(host, port).then(serverBinding);
    }
  },
  onError: (e, stackTrace) {
    Logger.root.warning(e.toString());
    Logger.root.warning("\n");
    Logger.root.warning(stackTrace.toString());
  });
}

