// Copyright (c) 2014, Robert Åkerblom-Andersson <Robert@dartvoid.com>

part of vane;

/**
 * Start serving requests.
 *
 * Regarding SSL support, consult the documentation of [SecureSocket.initialize]
 * for information on the parameters.
 *
 * If [redirectHTTP] is true, HTTP traffic will be redirected to HTTPS.
 */
void serve({String host,
            int port,
            bool enableTLS: false,
            int tlsPort,
            String tlsCertificateName,
            String tlsCertificateDb,
            String tlsCertificateDbPassword,
            bool tlsOnly: false,
            bool redirectHTTP: false,
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

  // Server port assignment (parameter overwrites environment)
  var hostEnv = Platform.environment['HOST'];
  host = host != null ? host : (hostEnv != null ? hostEnv : "127.0.0.1");
  var portEnv = Platform.environment['PORT'];
  port = port != null ? port : portEnv != null ? int.parse(portEnv) : 80; // default HTTP port
  var tlsPortEnv = Platform.environment['PORT_SSL'];
  tlsPort = tlsPort != null ? tlsPort : tlsPortEnv != null ? int.parse(tlsPortEnv) : 443; // default HTTPS port
  // SSL config using environment
  tlsCertificateName = tlsCertificateName != null ? tlsCertificateName : Platform.environment['SSL_CERT_NAME'];
  tlsCertificateDb = tlsCertificateDb != null ? tlsCertificateDb : Platform.environment['SSL_CERT_DB'];
  tlsCertificateDbPassword = tlsCertificateDbPassword != null ? tlsCertificateDbPassword : Platform.environment['SSL_CERT_DB_PASS'];

  // Serve incoming requests
  runZoned(() {
    // Function that sets up the server binding
    void serverBinding (HttpServer server) {
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
    if(enableTLS == true) {
      // Configuring SSL when all parameters are given
      if(tlsCertificateName != null && tlsCertificateDb != null && tlsCertificateDbPassword != null) {
        SecureSocket.initialize(database: tlsCertificateDb, password: tlsCertificateDbPassword);
      }
      Logger.root.info("Starting Vane server on HTTPS: ${host}:${tlsPort}");
      HttpServer.bindSecure(host, tlsPort, certificateName: tlsCertificateName).then(serverBinding);

      // Redirect HTTP traffic to HTTPS when redirectHTTP is true
      if(redirectHTTP == true) {
        Logger.root.info("Starting HTTP server to redirect to HTTPS on ${host}:${port}");
        HttpServer.bind(host, port).then((HttpServer server) {
          server.listen((HttpRequest request) {
            Uri httpsUri = request.uri.replace(scheme: "https");
            request.response.redirect(httpsUri, status: HttpStatus.MOVED_PERMANENTLY);
          });
        });
      }
    }

    // Start regular HTTP binding
    if(tlsOnly == false && redirectHTTP == false) {
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

