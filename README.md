Vane is a framework to make it easy and fun to write Dart applications. 
With Vane you can write both simple and advanced applications, 
with the powerful middleware system you can write reusable classes that you can 
build a chain out of that processes your requests. 

There are only one type of handler class, the Vane class. Any class extending 
Vane can either act as a handler or be registed to run as a middleware class. 
Vane classes registered to act as middleware can do so either before or after 
the main class. Middleware classes can run synchronously or asynchronously and 
you are guaranteed that they execute in the order you define. From any Vane 
class you can choose to execute the next class by running `next()` or to 
return to the client by running `close()`.

Vane supports three different types of handlers:
1. Vane handlers - Classes that extend the Vane class, lightweight and easier to use) 
2. Podo handlers - "Plain Old Dart Objects", normal classes that have one or more 
functions with the @Route annotation
3. Func handlers - Function handlers, normal dart function with the @Route annotation 

### Simple Hello World with a Vane handler  
```dart
import 'dart:async';
import 'package:vane/vane.dart';

class HelloWorld extends Vane {
  @Route("/")
  Future Hello() => close("Hello world");
}

void main() => serve();
```

### Hello World with both two Vane handlers, two Podo handlers and two func handlers  
```dart
import 'dart:io';
import 'dart:async';
import 'package:vane/vane.dart';

class HelloVane extends Vane {
  @Route("/")
  @Route("/vane")
  Future World() => close("Hello world! (from vane handler)");

  @Route("/{user}")
  @Route("/vane/{user}")
  Future User(String user) => close("Hello ${user}! (from vane handler)");
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
* Class based, easy to make your own standard class that you extend for your handlers
* Simple top level access to commonly used data such as paramters, json body or uploaded files
* Out of the box websocket support
* Any handler class can be registed either as the main class or as middleware
* Middleware classes can be defined to run synchronously or asynchronously, before or after the main handler
* Built in "plug and play" support for Mongodb 

### Documentation, examples and roadmap
* [Vane project homepage and documentation](http://www.dartvoid.com/vane/)
* [Vane API documentation](http://www.dartvoid.com/docs/vaneapi/)
* [Vane@Github](https://github.com/DartVoid/Vane)

