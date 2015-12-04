part of vane;

/// Simple Cors middleware that enabled cors request to a handler
class Cors extends Vane {
  Future main() {
    // Allow cross origin requests
    res.headers.add("Access-Control-Allow-Origin", "*");
    // TODO: Remove DartVoid specific headers from here...
    res.headers.add("Access-Control-Allow-Headers", "content-type, dv-api-client, dv-session-token, dv-user-agent");
    res.headers.add("Access-Control-Allow-Methods", "OPTIONS, HEAD, GET, POST, PUT, DELETE");

    if(req.method == "OPTIONS") {
      close();
    } else {
      next();
    }

    return end;
  }
}

