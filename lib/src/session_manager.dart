// Copyright (c) 2014, Robert Åkerblom-Andersson <Robert.nr1@gmail.com>

part of vane;

// MongoDB URI, provided by enviroment, standard localhost or overridden in code
String _MONGODB_URI = Platform.environment['MONGODB_URI'];
String MONGODB_URI = _MONGODB_URI != null ? _MONGODB_URI : "mongodb://localhost:27017";

/// Mongodb session manager
///
/// Key tasks:
///  * Make it possible to reuse database connections
///   * Good for performance
///   * Good for some application where you want to know that you use the same connection.
///  * Cleanup database connections so we never forget to close any connections
///
/// A session consists of 1 connection to the database. The default session is
/// called "default" and is returned if no other value is sent to the
/// [session()] function.
///
/// Currently there is no limit on the number of sessions that can be created
/// but they all have to have unique names some their name are used as a key in
/// a map.
///
/// If a session has not been used within [_SESSION_TIMEOUT] minutes then it's
/// database connection will be closed and it will be removed from the session
/// map. If the same session is requested again after it's been removed it will
/// be recreated and connected to the database and then returned. If the session
/// exists and requeted then it's [update()] function is called so that it
/// [lastUsed] value get's updated.
///
/// TODO: Lookup if it would be relevant to contribute SessionManager or a
/// variation of it into mongo_dart.
///
class _SessionManager {
  Map<String, _Session> pool = new Map<String, _Session>();
//  var _coreMongodbPoolMax = 4;
//  var _connCount = 0;
  String _uri;
  int _session_update;

  /// Setup default uri and session update if needed
  _SessionManager([this._session_update = _SESSION_UPDATE]) {
    // Setup MongoDB connection uri
    _uri = MONGODB_URI;

    // Timer run run a session check regularly
    new Timer.periodic(new Duration(minutes: _session_update), checkSession);
  }

  /// Get session with name [name]
  Future<Db> session([String name = "default"]) {
    var c = new Completer();

    // Setup new session object if needed
    if(pool[name] == null) {
      pool[name] = new _Session();

      // Setup new db object
      pool[name].mongodb = new Db(_uri);

      // Open database connection
      pool[name].mongodb.open().then((_) {
        // Return database connection
        c.complete(pool[name].mongodb);

        // Complete internal connected completer so that a concurrent request
        // that might be waiting know then the session is connected as well.
        pool[name].connected.complete();
      }).catchError((error) {
        // Remove session from pool
        pool.remove(name);

        // Log error (maybe handle this better?)
        Logger.root.warning(error);
      });
    } else {
      // Wait to make sure sessions has been connected
      pool[name].connected.future.then((_) {
        // Update timestamp for session
        pool[name].update();

        // Return database connection
        c.complete(pool[name].mongodb);
      });
    }

    return c.future;
  }

  /// Function that runs periodicly and checks if any sessions are not being
  /// used anymore so that it can close the connections.
  void checkSession(Timer timer) {
    var now = new DateTime.now();
    var oldSessions = new List<String>();

    // Check if any sessions have timed out
    pool.forEach((session, data) {
      Duration diff = now.difference(data.lastUsed);
//      Duration diff2 = data.lastUsed.difference(now);

      // If session has not been used within [SESSION_TIMEOUT] minutes, remove it
      if(diff.inMinutes >= data.timeout) {
        data.mongodb.close();
        oldSessions.add(session);
      }
    });

    // Remove old sessions
    oldSessions.forEach((session) => pool.remove(session));
  }
}

/// Default value of how often to check sessions (in minutes)
const int _SESSION_UPDATE = 1;

/// Default value of session timeout (in minutes)
const int _SESSION_TIMEOUT = 2;

/// Session object
class _Session {
  Db mongodb;
  Completer connected = new Completer();
  DateTime lastUsed;
  int timeout;

  _Session([this.timeout = _SESSION_TIMEOUT]) {
    update();
  }

  // Update timeout so we know when to remove session
  void update() {
    lastUsed = new DateTime.now();
  }
}

