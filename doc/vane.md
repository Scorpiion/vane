# Vane

## Introduction to Vane

Vane is a framework to make it easy and fun to write Dart server-side applications. With Vane you can write both simple and advanced applications, with the powerful middleware system you can write reusable classes that you can build a chain out of that processes your requests.

There are only one type of handler class, the Vane class. Any class extending Vane can either act as a handler or be registered to run as a middleware class. Vane classes registered to act as middleware can do so either before or after the main class.

Middleware classes can run synchronously or asynchronously and you are guaranteed that they execute in the order you define. From any Vane class you can choose to execute the next class by running next() or to return to the client by running close().

## Summary

* Easy extendable class based core
* Pre-defined top level access to commonly used data such as
  * request parameters
  * json bodies
  * file uploads
* A versatile handler system that allows you to register classes either as the main handler or as a middleware
* Middlewares can be defined to run synchronously or asynchronously
* Middleware communication layer called Tube
* Websockets out of the box
* Plug and play support for MongoDB (provided by DartVoid)

## What framework is Vane inspired by or similar to

Vane is not inspired by any single framework but has rather been inspired by several different frameworks written in Java, PHP, Ruby and NodeJS. Some concepts are new and have been adapted specifically to cater the nature of Dart. Most specifically is the use of futures that does not translate directly to many existing frameworks in other languages.

Vane’s middleware system is inspired by similar middleware systems such as Rack for Ruby, Connect for NodeJS and Play for Java.

Some features that Rack and Connect middlewares implement are either included by default in Vane or are abstracted to Nginx while running on DartVoid.

At DartVoid we believe the best tools should always be used for the job, Nginx is very good at serving static files, Dart is very good for writing application logic.

## Handlers

Vane supports three different types of handlers:

* Vane handlers
  * Classes that extend the Vane class
* Podo handlers
  * “Plain Old Dart Objects”, normal classes that have one or more functions with the @Route annotation
* Func handlers 
  *  Function handlers, normal dart function with the @Route annotation

### Vane handler

A vane handler is any class that extends the Vane class. When you extend the Vane class your handler functions get access to many helpers and features that are part of the Vane framework. In a vane handler you have access to a set of top level helpers to makes life easier, some example of these are a ready to use parsed version of incomming json data called “json”.

A Vane class can either run on it’s own or in a pipeline of a set of Vane controllers. When mulitple a Vane controller is used in a pipeline to process a request those other than the main controller are called middleware controllers, but it’s not a different type of controller and middleware controllers can themself also have their own middleware controllers. Inside a Vane controller you can either end the controller by returning next() or close(), if you return with next() the next middleware controller will run (if there is one, otherwise the call will be changed to a close() call). If you call close() that will end the request even if there are middleware controllers that have yet not run.

Vane classes registered to as middleware can run either before or after the main controller. Middleware controller can run synchronously or asynchronously and you are guaranteed that they execute in the order you define. Per default middleware controllers run synchronously any the next controller only starts when the current one have finished. You can choose to run one or more middleware controllers in async and also combine both a set of synchronous and asynchronous controller to create more complex pipelines for processing.

#### Vane class example

```dart

class HelloVane extends Vane {
  @Route("/")
  Future World() {
    return close("Hello world! (from vane handler)");
  }
}

```

#### Vane Middleware example

```dart

class HelloVane extends Vane {
  var pipeline = [MyMiddleware, This]
  @Route("/")
  Future World() {
    return close("Hello world! (from vane handler)");
  }
}

class MyMiddleware extends Vane {
  Future main() {
    write("Hello from middleware!");
    return next();
  }
}

```

### Podo handler

A podo handler is a “Plain Old Dart Object”, basically any Dart class that have 1 or more function handlers with declared with the @Route annotation.

#### Podo example

```dart

class HelloPodo {
  @Route("/")
  void World(HttpRequest request) {
    request.response.write("Hello World! (from podo handler)");
    request.response.close();
  }
}

```

### Func handler

A function handler is simple a function that takes at least 1 HttpRequest parameter and optionally 1 or more parameters that can be mapped from the url.

#### Func example

```dart

@Route("/")
void helloFuncWorld(HttpRequest request) {
  request.response.write("Hello World! (from func handler)");
  request.response.close();
}

```

## Vane server

With Vane you don’t have to worry about writing a dart/web server, you focus on writing your controllers/handlers and Vane serves them for you automatically based on your @Route annotations.
All you need to do is to make sure they are in the same library and that you start the serve function.

### Vane server example

```dart

import 'dart:async';
import 'package:vane/vane.dart';

class HelloWorld extends Vane {
  @Route("/")
  Future Hello() {
    return close("Hello world");
  }
}

void main() => serve();

```

## JSON

The modern web breaths JSON, and so does Vane. For many developers JSON is today the obvious choice as a data exchange format and Dart being a language developed for the web also comes with JSON support out of the box. Vane makes it extra easy to return JSON from handlers by setting the content type to “application/json” and to convert any object written to close that is a List or Map to JSON (this default behaviour can of course also be overridden if needed).

Here are some example of handlers that returns JSON. The first two uses Vane’s close functions “auto encode to json” feature (works only for Lists and Maps) to send a list and a map respectivly to the client in JSON format. The third example uses Dart’s built in convert package to convert a map to json format and then writing it to the response and closes the request.

### Map to json

```dart

import 'dart:async';
import 'package:vane/vane.dart';

class HelloJsonMap extends Vane {
  @Route("/")
  Future main() {
    // Define Map of Strings
    var jsonData = new Map<String, String>();

    // Add data to Map
    jsonData["Hello"] = "World";

    // Log data
    log.info("${jsonData}");

    // Send back data and let Vane convert it for you
    return close(jsonData);
  }
}

void main() => serve();

```

### List to json

```dart

import 'dart:async';
import 'package:vane/vane.dart';

class HelloJsonList extends Vane {
  @Route("/")
  Future main() {
    // Define List of Strings
    var jsonData = new List<String>();

    // Add data to the List
    jsonData.add("Hello");
    jsonData.add("World");

    // Log data
    log.info("${jsonData}");

    // Send back data and let Vane convert it for you
    return close(jsonData);
  }
}

void main() => serve();

```

## Websockets

Writing a websocket handler with Vane is easy. There is a top level websocket object ready for you if you want to respond to incoming websocket requests. Here we start listening to the ws object, the websocket object, and then register callbacks for the different types of events that can happen. If data comes on the websocket we retrieve the value and then write it back to the client, appending the message with “Echo: “ using Dart’s string interpolation feature. If an error occurs we write it to the warning log, currently available in DartVoid’s app console (on stderr). When either the server or the client closes the connection we also close the handler.

We return with end (which is a getter to one of Vane’s internal futures) instead of close() at the end of the handler. We do this since we don’t know for sure when close() will actually run, since it’s inside an async structure (read more about the relationship between close() and end in the topic “Closing a handler” below). In cases like this one where we close inside an async structure you should always return end at the end of your handler.

More information about how you can use the websocket object can be found here in the Dart API reference for the Websocket object.

### Websocket example

```dart

import 'dart:async';
import 'package:vane/vane.dart';

class WebsocketEchoClass extends Vane {
  @Route("/ws")
  Future main() {
    // Subscribe to the websocket stream
    var conn = ws.listen(null);

    // Handle incoming data
    conn.onData((data) {
      // Log request
      log.info(data);

      // Echo data back to the sender
      ws.add("Echo: $data");
    });

    // Handle and log errors
    conn.onError((e) => log.warning(e));

    // Handle and close connection
    conn.onDone(() => close());

    return end;
  }
}

void main() => serve();

```

## Closing a handler

In Dart asynchronous programming is very common and many times you will have one or more asynchronous structures in your code. Vane is implemented to work with Dart’s asynchronous programming model, not against it, therefore you should always return Vane’s internal future called end from all your handlers. It’s the same for both the main handler and for middleware handlers (remember middleware handlers also extend Vane so they are all equal in this respect). If you are new to the concept of Dart’s futures, we recommend that you read this article before you continue reading.

Vane internal future called end is completed when you run either close() or next() in your handler. When you do that Vane knows that the handler has finished and that it can start the next middleware handler if there is one waiting. If you used close() Vane ignores any waiting middleware handlers and just finishes up the request and closes it.

In some cases, like the “Hello World” example, it might feel verbose to run both close() and return end after each other. In those cases you have the option to return with either close() or next() instead of end. This works because both close() and next() themself return end. This is a nice feature, but it should be used with care because it does not always work as expected if you try to use return close() inside an asynchronous structure. If you are not sure, then return end explicitly, but in general the rule is that if you return inside an async structure you should return end and if you return from asynchronous structure you can choose.

### 4 ways/combinations to close a handler

#### close() + return end

```dart
 ...
  close();
  ...
  return end;
```

#### next() + return end

```dart

  ...
  next();
  ...
  return end;

```

#### return close()

```dart
  ...
  return close();
```

#### return next()

```dart
  ...
  return next();

```

## Good to know checklist

* 1 class must always extend Vane, we call that the main handler in our documentation
* 0 or more Vane classes can be registered as middleware classes running before the main handler, the list of middleware running before the main handler is called the pre list.
* 0 or more Vane classes can be registered as middleware classes running after the main handler, the list of middleware running after the main handler is called the post list.
* At least 1 handler class must be guaranteed to run close(), otherwise you risk that your request might hang.
* To continue running next middleware handler (or the main handler) you should run next() from your handler.
* To end a request and not run any more middleware handlers (or the main handler) you should run close() from your handler.
* You can choose if your middleware should run synchronously and asynchronously, synchronously is the standard mode.
* The end future must always be returned from main(), you can do that explicitly with return end or implicitly with return close() or return next().
* The last middleware class should try to use close() and not next(). But if next() is used in the last instance it will be converted to close() to prevent the server from hanging.

## Introduction to Middlewares

Any class that extends Vane can be used as either the main handler or as a middleware handler. You can have all your handler logic in one class or you can separate them into multiple Vane classes that you configure to run in an order of your choosing.

### Vane’s middleware implementation has four goals

* Enhance code reuse between projects and within apps
* Make it easier and less verbose to structure combinations of synchronous and asynchronous code
* Make it easier to debug big or complex handlers
* Make middleware classes lightweight

The middleware functionally in Vane can be thought of as a tool to help structure synchronous and asynchronous structures that otherwise could can be hard (or verbose) to structure in a single function in Dart (eg. when you get too many “and then, and then, and then, and then”).

The asynchronous nature of Dart is very powerful, but sometimes it’s simply better to separate parts of the code that should run synchronously after each other in different functions/classes.

Middlewares can be registered to run either before or after the main handler. To register the middlewares order of execution you need to implement a member called pipeline as a List in your main handler. To help with defining the position for the main handler, Vane exposes This which reflects the handlers own name.

Middlewares in Vane run synchronously by default, but you can choose to run some or all middleware asynchronously to create the optimal chain of classes for your handler. Asynchronous middleware classes that are registered after each other are started in async until the first synchronous class comes in the chain, then Vane will wait for all the asynchronous classes to finish before it continues with the next synchronous class. If you want your class to run asynchronously you just declare a member called async in your class and set it to true.

Any class in your handler chain can at it’s end, either run close() or next(). close() will close the request and the response will be returned to the client, if any middleware handler or the main handler calls close() the handlers registered after it will not run. If a handler calls next() instead of close(), then the next handler will continue to run. If you have a handler or middleware at the end of the pipeline that calls next() Vane converts it to a close() to prevent the server from hanging.

Vane’s middleware classes are lightweight, what that means is that you don’t have to worry that your handler gets slow because you add many middleware classes. Behind the scenes the main handler and the middleware classes share most of the “heavy parts”. Vane has a core object that hold things like the request data, the request body and the request response. When a middleware class should run, it will not get a copy of all this data, but a reference to the core Vane object. Because of this we believe that you should not have to consider running code inside middleware classes a performance hit, not big enough to care about anyways.

It should be noted that when we talk about running code synchronous and asynchronous we only refer to the order middleware and the main handler runs in respect to each other. Code inside handlers runs like any dart code, mostly asynchronously that is.

## Tube

Tube is a middleware communication layer that allows an application to communicate between the different middlewares and the main handler.

### There are two ways to communicate through Tube

* Add data events to a stream
* Send data to a message queue

## Stream data

Tubes stream combines a sink and a stream to broadcast messages. Stream data events with add and then listen for the data.

```dart

import 'dart:async';
import 'package:vane/vane.dart';

class HelloWorld extends Vane {
  var pipeline = [HelloMiddleware, This];

  @Route("/")
  Future main() {
    tube.listen((data) {
      write("Hello ${data["name"]}!");
      return close();
    });

    return end;
  }
}

class HelloMiddleware extends Vane {
  Future main() {
    tube.add({"name": "testuser"});
    return next();
  }
}

void main() => serve();

```

### Queue messages

Tubes message queue uses a FIFO (first in, first out) approach. Simply add messages to the queue with send and use recieve to read messages one at a time from the bottom.

```dart

import 'dart:async';
import 'package:vane/vane.dart';

class HelloWorld extends Vane {
  var pipeline = [HelloMiddleware, This];

  @Route("/")
  Future main() {
    var data = tube.receive();
    write("Hello ${data["name"]}!");
    return close();
  }
}

class HelloMiddleware extends Vane {
  Future main() {
    tube.send({"name": "testuser"});
    return next();
  }
}

void main() => serve();


```

## Execution order

By defining the order in the pipeline you can control the applications flow. To allow for middlewares to run after the main handler it needs to return next() instead of close(), and because Vane can convert the last next() to a close() there isn’t any risk of hanging your server if you choose to change the order of execution later on.

### Before main handler

```dart

import 'dart:async';
import 'package:vane/vane.dart';

class HelloWorld extends Vane {
  var pipeline = [HelloMiddleware, This];

  @Route("/")
  Future main() {
    writeln("Hello World!");
    return close();
  }
}

class HelloMiddleware extends Vane {
  Future main() {
    writeln("Hello middle earth!");
    return next();
  }
}

void main() => serve();

```

### After main handler

```dart

import 'dart:async';
import 'package:vane/vane.dart';

class HelloWorld extends Vane {
  var pipeline = [This, HelloMiddleware];

  @Route("/")
  Future main() {
    writeln("Hello World!");
    // Allows the middleware to run
    return next();
  }
}

class HelloMiddleware extends Vane {
  Future main() {
    writeln("Hello middle earth!");
    return next();
  }
}

void main() => serve();

```

## Switching between synchronous and asynchronous behavior

If you want to switch between running your middleware synchronously and asynchronously (when you debug for example) then you can just change the bool value of the async member that all Vane handlers inherit. If you switch very often and have many different classes then you could add a default constructor to your middleware class where you setup the async member.

In the following examples we simulate a workload with Timer and log each request with the pIndex (pipeline index).

### Synchronous

```dart

import 'dart:async';
import 'package:vane/vane.dart';

class HelloWorld extends Vane {
  var pipeline = [
    SyncMiddleware,
    SyncMiddleware,
    This
  ];

  @Route("/hello")
  Future main() {
    writeln("Hello World!");
    log.info("Main $pIndex");
    return next();
  }
}

class SyncMiddleware extends Vane {
  Future main() {
    new Timer(new Duration(seconds: 1), () {
      writeln("Hello sync earth!");
      log.info("Sync $pIndex");
      next();
    });

    return end;
  }
}

void main() => serve();

```

### Asynchronous

```dart

import 'dart:async';
import 'package:vane/vane.dart';

class HelloWorld extends Vane {
  var pipeline = [
    AsyncMiddleware,
    AsyncMiddleware,
    This
  ];

  @Route("/hello")
  Future main() {
    writeln("Hello World!");
    log.info("Main $pIndex");
    return next();
  }
}

class AsyncMiddleware extends Vane {
  var async = true;
  
  Future main() {
    new Timer(new Duration(seconds: 1), () {
      writeln("Hello async earth!");
      log.info("Async $pIndex");
      next();
    });

    return end;
  }
}

void main() => serve();

```