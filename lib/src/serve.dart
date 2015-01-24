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
void serve({String host: "127.0.0.1",
            int port: 9090,
            bool enableSSL: false,
            int sslPort: 9091,
            String sslCertificateName,
            String sslCertificateDatabase,
            String sslCertificateDatabasePassword,
            bool sslOnly: false,
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
  if(port == null)
    port = int.parse(Platform.environment['PORT']);
  if(sslPort = null)
    sslPort = int.parse(Platform.environment['PORT_SSL']);
  // SSL config using environment
  if(sslCertificateName == null)
    sslCertificateName = Platform.environment['SSL_CERT_NAME'];
  if(sslCertificateDatabase == null)
    sslCertificateDatabase = Platform.environment['SSL_CERT_DB'];
  if(sslCertificateDatabasePassword == null)
    sslCertificateDatabasePassword = Platform.environment['SSL_CERT_DB_PASS'];

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
    if(enableSSL) {
      // Configuring SSL when all parameters are given
      if(sslCertificateName != null && sslCertificateDatabase != null && sslCertificateDatabasePassword != null) {
        SecureSocket.initialize(database: sslCertificateDatabase, password: sslCertificateDatabasePassword);
      }
      Logger.root.info("Starting Vane server on HTTPS: ${host}:${port}");
      HttpServer.bindSecure(host, sslPort, certificateName: sslCertificateName).then(serverBinding);

      // Redirect HTTP traffic to HTTPS when redirectHTTP is true
      if(redirectHTTP) {
        HttpServer.bind(host, port).then((HttpServer server) {
          server.listen((HttpRequest request) {
            Uri httpsUri = new Uri(scheme: "https",
                userInfo: request.uri.userInfo,
                host: request.uri.host,
                port: request.uri.port,
                path: request.uri.path,
                pathSegments: request.uri.pathSegments,
                query: request.uri.query,
                queryParameters: request.uri.queryParameters,
                fragment: request.uri.fragment);
            request.response.redirect(httpsUri, status: HttpStatus.MOVED_PERMANENTLY);
          });
        });
      }
    }

    // Start regular HTTP binding
    if(!sslOnly && !redirectHTTP) {
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

