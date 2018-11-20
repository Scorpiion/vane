// Copyright (c) 2014, Robert Åkerblom-Andersson <Robert.nr1@gmail.com>

part of vane;

class _VaneCore {
  dynamic j;
  Map params;
  Map<String, dynamic> files;
  WebSocket ws;
  BytesBuilder output = new BytesBuilder();

  /// Internal variables used for redirect
  String redirect_url;
  int redirect_status;

  /// VaneRequest
  VaneRequest req;

  /// VaneResponse
  VaneResponse res;

  /// Parsed request body
  HttpRequestBody body;

  /// Tube
  Tube tube = new _TubeImpl();

  /// Logger
  final Logger log = Logger.root;

  /// Session
  static Map<String, Object> session = new Map<String, Object>();

  /// Mongodb session manager
  static final _SessionManager sessionManager = new _SessionManager();
}

