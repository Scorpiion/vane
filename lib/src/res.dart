// Copyright (c) 2014, Robert Åkerblom-Andersson <Robert.nr1@gmail.com>
//
// Note: Parts of the comments are derived from the original dartlang code
// in cases were already documented members or functions are exposed.

part of vane;

class VaneResponse {
  /// Underlying http response object
  HttpResponse zResponse;

  VaneResponse(this.zResponse);

  /**
   * Returns the response headers.
   */
  HttpHeaders get headers => zResponse.headers;

  /**
   * Cookies to set in the client (in the 'set-cookie' header).
   */
  List<Cookie> get cookies => zResponse.cookies;

  /**
   * Gets and sets the content length of the response. If the size of
   * the response is not known in advance set the content length to
   * -1 - which is also the default if not set.
   */
  int get contentLength => zResponse.contentLength;
  void set contentLength(int _contentLength) {
    zResponse.contentLength = _contentLength;
  }

  /**
   * Gets and sets the persistent connection state. The initial value
   * of this property is the persistent connection state from the
   * request.
   */
  bool get persistentConnection => zResponse.persistentConnection;
  void set persistentConnection(bool _persistentConnection) {
    zResponse.persistentConnection = _persistentConnection;
  }

  /**
   * Gets and sets the reason phrase. If no reason phrase is explicitly
   * set a default reason phrase is provided.
   */
  String get reasonPhrase => zResponse.reasonPhrase;
  void set reasonPhrase(String _reasonPhrase) {
    zResponse.reasonPhrase = _reasonPhrase;
  }

  /**
   * Gets and sets the status code. Any integer value is accepted. For
   * the official HTTP status codes use the fields from
   * [HttpStatus]. If no status code is explicitly set the default
   * value [HttpStatus.ok] is used.
   */
  int get statusCode => zResponse.statusCode;
  void set statusCode(int _statusCode) {
    zResponse.statusCode = _statusCode;
  }

  /**
   * The [Encoding] used when writing strings. Depending on the
   * underlying consumer this property might be mutable.
   */
  Encoding get encoding => zResponse.encoding;

  /**
   * Set and get the [deadline] for the response. The deadline is timed from the
   * time it's set. Setting a new deadline will override any previous deadline.
   * When a deadline is exceeded, the response will be closed and any further
   * data ignored.
   *
   * To disable a deadline, set the [deadline] to `null`.
   *
   * The [deadline] is `null` by default.
   */
  Duration get deadline => zResponse.deadline;
  void set deadline(Duration _deadline) {
    zResponse.deadline = _deadline;
  }

  /**
   * Gets information about the client connection. Returns [:null:] if the
   * socket is not available.
   */
  HttpConnectionInfo get connectionInfo => zResponse.connectionInfo;
}

