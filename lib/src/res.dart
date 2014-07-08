// Copyright (c) 2014, Robert Åkerblom-Andersson <Robert@dartvoid.com>
//
// Note: Parts of the comments are derived from the original dartlang code
// in cases were already documented members or functions are exposed.

part of vane;

class VaneResponse {
  // Internal http response object
  HttpResponse _res;

  VaneResponse(this._res);

  /**
   * Returns the response headers.
   */
  HttpHeaders get headers => _res.headers;

  /**
   * Cookies to set in the client (in the 'set-cookie' header).
   */
  List<Cookie> get cookies => _res.cookies;

  /**
   * Gets and sets the content length of the response. If the size of
   * the response is not known in advance set the content length to
   * -1 - which is also the default if not set.
   */
  int get contentLength => _res.contentLength;

  /**
   * Gets and sets the persistent connection state. The initial value
   * of this property is the persistent connection state from the
   * request.
   */
  bool get persistentConnection => _res.persistentConnection;

  /**
   * Gets and sets the reason phrase. If no reason phrase is explicitly
   * set a default reason phrase is provided.
   */
  String get reasonPhrase => _res.reasonPhrase;

  /**
   * Gets and sets the status code. Any integer value is accepted. For
   * the official HTTP status codes use the fields from
   * [HttpStatus]. If no status code is explicitly set the default
   * value [HttpStatus.OK] is used.
   */
  int get statusCode => _res.statusCode;

  void set statusCode(int code) {
    _res.statusCode = code;
  }

  /**
   * The [Encoding] used when writing strings. Depending on the
   * underlying consumer this property might be mutable.
   */
  Encoding get encoding => _res.encoding;

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
  Duration get deadline => _res.deadline;

  /**
   * Gets information about the client connection. Returns [:null:] if the
   * socket is not available.
   */
  HttpConnectionInfo get connectionInfo => _res.connectionInfo;
}

