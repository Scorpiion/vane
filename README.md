Vane
=========

Vane is server side framework written and optimized for the Dart programming 
langauge. Vane comes bundled with a lightweight and performant middleware 
system and strives to provide commonly used parameters and objects in an easy
to use manner such as query paramters or json body data. 

Vane supports three different types of handlers:

1. Func handlers - Function handlers, normal dart function with the @Route annotation 
2. Podo handlers - "Plain Old Dart Objects", normal classes that have one or more 
functions with the @Route annotation
3. Vane handlers - Classes that extend the Vane class

### Func handler 
A function handler is simple a function that takes at least 1 HttpRequest paramter and 
optionally 1 or more paramters that can be mapped from the url.

Hello World Example:
```dart
@Route("/")
void helloFuncWorld(HttpRequest request) {
  request.response.write("Hello World! (from func handler)");
  request.response.close();
}
```

### Podo handler 
A podo handler is a "Plain Old Dart Object", basically any Dart class that have 1 or more
function handlers with declared with the @Route annotation.

Hello World Example:
```dart
class HelloPodo {
  @Route("/")
  void World(HttpRequest request) {
    request.response.write("Hello World! (from podo handler)");
    request.response.close();
  }
}
```

### Vane handler 
A vane handler is any class that extends the Vane class. When you extend the Vane class your 
handler functions get access to many helpers and features that are part of the Vane framework.
In a vane handler you have access to a set of top level helpers to makes life easier, some 
example of these are a ready to use parsed version of incomming json data called "json". 

A Vane class can either run on it's own or in a pipeline of a set of Vane controllers. When 
mulitple a Vane controller is used in a pipeline to process a request those other than the 
main controller are called middleware controllers, but it's not a different type of controller
and middleware controllers can themself also have their own middleware controllers. Inside a 
Vane controller you can either end the controller by returning `next()` or `close()`, if you 
return with `next()` the next middleware controller will run (if there is one, otherwise the 
call will be changed to a `close()` call). If you call `close()` that will end the request 
even if there are middleware controllers that have yet not run.  

Vane classes registered to as middleware can run either before or after 
the main controller. Middleware controller can run synchronously or asynchronously and 
you are guaranteed that they execute in the order you define. Per default middleware controllers
run synchronously any the next controller only starts when the current one have finished. You
can choose to run one or more middleware controllers in async and also combine both a set of 
synchronous and asynchronous controller to create more complex pipelines for processing.

Hello World Example:
```dart
class HelloVane extends Vane {
  @Route("/")
  Future World() { 
    return close("Hello world! (from vane handler)");
  }
}
```

Middleware Example:
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

### Vane's server.dart file
With Vane you don't have to worry about writing a dart/web server, you focus on writing your 
controllers/handlers and Vane serves them for you automatically based on your @Route annotations.  
All you need to do is to make sure they are in the same library and that you start the serve function. 

### Hello World with a Vane handler  
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

### Example with all three types of handlers 
```dart
import 'dart:io';
import 'dart:async';
import 'package:vane/vane.dart';

class HelloVane extends Vane {
  @Route("/")
  @Route("/vane")
  Future World() {
    return close("Hello world! (from vane handler)");
  }

  @Route("/{user}")
  @Route("/vane/{user}")
  Future User(String user) {
    return close("Hello ${user}! (from vane handler)");
  }
}

class HelloPodo {
  @Route("/podo")
  void World(HttpRequest request) {
    request.response.write("Hello World! (from podo handler)");
    request.response.close();
  }

  @Route("/podo/{user}")
  void User(HttpRequest request, String user) {
    request.response.write("Hello World $user! (from podo handler)");
    request.response.close();
  }
}

@Route("/func")
void helloFuncWorld(HttpRequest request) {
  request.response.write("Hello World! (from func handler)");
  request.response.close();
}

@Route("/func/{user}")
void helloFuncUser(HttpRequest request, String user) {
  request.response.write("Hello World $user! (from func handler)");
  request.response.close();
}

void main() => serve();
```

### Summary
* Support three handler types; Func, Podo and Vane
* Class based, easy to make your own standard classes by extending any Podo or Vane class and addingyour handlers
* Simple top level access to commonly used data such as paramters, json body or uploaded files
* Out of the box websocket support
* Any Vane  class can either run as the main controller or as a middleware
* Middleware classes can be defined to run synchronously or asynchronously, before or after the main controller
* Built in "plug and play" support for Mongodb 

### Documentation, examples and roadmap
* [Vane project homepage and documentation](http://www.dartvoid.com/vane/)
* [Vane API documentation](http://www.dartvoid.com/docs/vaneapi/)
* [Vane@Github](https://github.com/DartVoid/Vane)

