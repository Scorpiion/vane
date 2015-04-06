// Copyright (c) 2014, Robert Åkerblom-Andersson <Robert.nr1@gmail.com>

part of vane;

/// Http methods constants, declared for easy use with code completion and to
/// avoid typos.
const String GET      = "GET";
const String HEAD     = "HEAD";
const String POST     = "POST";
const String PUT      = "PUT";
const String DELETE   = "DELETE";
const String TRACE    = "TRACE";
const String OPTIONS  = "OPTIONS";
const String CONNECT  = "CONNECT";
const String PATCH    = "PATCH";

/// [Route] annotation used to declared the request handler for a specific path
class Route {
  final String path;
  final String method;
  final List<String> methods;

  const Route(this.path, {this.method: "", this.methods: const []});
}

// A class is used for this constant since the other entries in the pipeline
// list are also classes.
class _This {
  const _This();
}

/// [This] is a constant used to indentify the main handler in middleware
/// pipeline. With [This] it's possible to define where in the pipeline the
/// main handler should go, per default that is last in the the pipeline.
const This = const _This();

