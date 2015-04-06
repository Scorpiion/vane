// Copyright (c) 2014, Robert Åkerblom-Andersson <Robert.nr1@gmail.com>

part of vane;

class VaneClientProxy {
  String proxyName = "vane_client_proxy";

  static List<String> spaPaths = new List<String>();

  /// Pub proxy, always return "/${path}" from pub with for paths
  void pubProxy(HttpRequest request) => _proxyRequest(request);

  /// Spa proxy, always return "/" from pub with for paths
  void spaProxy(HttpRequest request) {
    String path = "";

    // Search for a match among SPA paths
    for(var spaPath in spaPaths) {
      if(request.uri.path.startsWith(spaPath) == true) {
        print("Found match! $spaPath");
        path = spaPath;
        break;
      }
    }

    // Make proxy request
    if(request.uri.pathSegments.last.contains(".") == true) {
      return _proxyRequest(request, spa: true, path: "${request.uri.path.replaceFirst(path, "")}");
    } else {
      return _proxyRequest(request, spa: true);
    }
  }

  /// Proxy request to pub
  void _proxyRequest(HttpRequest request, {bool spa: false, String path: "/"}) {
    Client client = new Client();
    // TODO: Maybe make this url configurable
    Uri url = Uri.parse("http://127.0.0.1:8080");

    // Setup request url path
    if(spa == true) {
      url = url.resolve(path);
    } else {
      url = url.resolve(request.uri.path);
    }

    // Create a stream request
    StreamedRequest req = new StreamedRequest(request.method, url);

    // Add headers to new request
    request.headers.forEach((key, val) => req.headers[key] = val.toString());

    // Set "Host" and "Via" header
    req.headers["Host"] = url.authority;
    req.headers["Via"] = '${request.protocolVersion} $proxyName';

    // Proxy all incomming http data to the new request, when all data has
    // been proxied, close the sink so the proxied request can be sent.
    request.listen((data) => req.sink.add(data), onDone: () => req.sink.close());

    client.send(req).then((res) {
      // Set status code
      request.response.statusCode = res.statusCode;

      // Add headers from proxied response
      request.response.headers.clear();
      res.headers.forEach((key, val) => request.response.headers.add(key, val));

      // Set proxy "Via" header
      request.response.headers.add("Via", '${request.protocolVersion} $proxyName');

      // Write output from proxy backend back to the client
      request.response.addStream(res.stream).whenComplete(() {
        request.response.close();
        client.close();
      });
    }).catchError((error) {
      request.response.statusCode = 502;
      request.response.write("Error: Could not proxy request to pub serve ${url} (pub serve instance, is it running?)\n");
      request.response.close();
    });
  }
}

