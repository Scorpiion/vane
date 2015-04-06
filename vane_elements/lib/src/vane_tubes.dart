// Copyright (c) 2014, Robert Åkerblom-Andersson <Robert@dartvoid.com>

library vane_elements.vane_tubes;

import 'dart:async';
import 'dart:collection';
import 'package:quiver/collection.dart';

class VaneTubes {
  static TubeSystem single = new TubeSystem(broadcast: false);
  static TubeSystem broadcast = new TubeSystem(broadcast: true);
}

class TubeSystem extends DelegatingMap<String, Tube> {
  Map<String, Tube> _tubes = new Map<String, Tube>();
  bool broadcast;

  TubeSystem({bool this.broadcast: false});

  Map<String, Tube> get delegate => _tubes;

  Tube operator [](String name) {
    if(_tubes[name] == null) {
      _tubes[name] = new Tube(broadcast: broadcast);
    }

    return _tubes[name];
  }
}

class Tube extends Stream implements Sink {
  StreamController _base;
  Queue _fifo = new Queue();

  Tube({bool broadcast}) {
    if(broadcast == true) {
      _base = new StreamController.broadcast();
    } else {
      _base = new StreamController();
    }
  }

  /// Subscribe to the tubes stream.
  ///
  /// On each data event from the stream, the subscriber's [onData] handler
  /// is called. If [onData] is null, nothing happens.
  ///
  /// On errors from the stream, the [onError] handler is given a
  /// object describing the error.
  ///
  /// The [onError] callback must be of type `void onError(error)` or
  /// `void onError(error, StackTrace stackTrace)`. If [onError] accepts
  /// two arguments it is called with the stack trace (which could be `null` if
  /// the stream itself received an error without stack trace).
  /// Otherwise it is called with just the error object.
  ///
  /// If the stream closes, the [onDone] handler is called.
  ///
  /// If [cancelOnError] is true, the subscription is ended when
  /// the first error is reported. The default is false.
  ///
  StreamSubscription listen(void onData(String line),
                            { void onError(Error error),
                              void onDone(),
                              bool cancelOnError }) {
   return _base.stream.listen(onData,
                              onError: onError,
                              onDone: onDone,
                              cancelOnError: cancelOnError);
  }

  /// A future telling if the tube's sink has been closed.
  ///
  /// The [done] Future completes with the same values as [close], except
  /// for the following case:
  ///
  /// * The synchronous methods of [EventSink] were called, resulting in an
  /// error. If there is no active future (like from an addStream call), the
  /// [done] future will complete with that error.
  Future get done => _base.sink.done;

  /// Add data to the tube's stream.
  ///
  /// When using [add] a data event will get created that a handler listening
  /// to the tube with [listen] can later access.
  void add(event) => _base.sink.add(event);

  /// Create an async error.
  void addError(errorEvent, [StackTrace stackTrace]) =>
     _base.sink.addError(errorEvent, stackTrace);

  /// Add a stream of data to the tube's stream.
  ///
  /// Consumes the elements of [stream].
  ///
  /// Listens on [stream] and does something for each event.
  ///
  /// The consumer may stop listening after an error, or it may consume
  /// all the errors and only stop at a done event.
  ///
  Future addStream(Stream stream) => _base.sink.addStream(stream);

  /// Close the tube.
  ///
  /// Close the internal [StreamSink]. It'll return the [done] Future.
  ///
  /// Note that if you close the tube you can't use it later in other handlers
  /// that is part of the same request.
  Future close() => _base.close();

  /// Send object on the tubes queue so that later can be received by a
  /// different handler calling [receive].
  void send(Object data) => _fifo.add(data);

  /// Receive object sent on the tube with [send]. Throws an StateError
  /// exception if the tubes queue is empty.
  Object receive() => _fifo.removeFirst();
}

