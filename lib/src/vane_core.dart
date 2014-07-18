// Copyright (c) 2014, Robert Åkerblom-Andersson <Robert@dartvoid.com>

part of vane;

class _VaneCore {
  Map json;
  Map params;
  Map<String, dynamic> files;
  WebSocket ws;
  _OutputConsumer output = new _OutputConsumer();
  IOSink iosink;

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
  static final _SessionManager sessionManager =
      new _SessionManager(Platform.environment['MONGODB_URI']);
}

