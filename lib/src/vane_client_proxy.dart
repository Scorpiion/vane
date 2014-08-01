// Copyright (c) 2014, Robert Åkerblom-Andersson <Robert@dartvoid.com>

part of vane;

class VaneClientProxy {
  void proxy(HttpRequest request) {
    shelf_io.handleRequest(request, proxyHandler("http://127.0.0.1:8080",
                                                 proxyName: "vane_client_proxy"));
  }
}

