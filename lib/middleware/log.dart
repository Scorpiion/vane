part of vane;

/// Simple logger class that can be used for debugging, output goes to console. 
class Log extends Vane {
  Future main() {
    log.info("${req.method} ${req.uri.path}");
    return next();
  }
}

