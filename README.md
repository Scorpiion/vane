Vane is a framework to make it easy and fun to write Dart serverside 
applications. With Vane you can write both simple and advanced applications, 
with the powerful middleware system you can write reusable classes that you can 
build a chain out of that processes your requests. 

There are only one type of handler class, the Vane class. Any class extending 
Vane can either act as a handler or be registed to run as a middleware class. 
Vane classes registered to act as middleware can do so either before or after 
the main class. Middleware classes can run synchronously or asynchronously and 
you are guaranteed that they execute in the order you define. From any Vane 
class you can choose to execute the next class by running `next()` or to 
return to the client by running `close()`.

### Hello World
```dart
import 'dart:async';
import 'package:vane/vane.dart';

class HelloWorld extends Vane {
  @Route("/{user}")
  Future User(String user) => close("Hello ${user}");

  @Route("/")
  Future World() => close("Hello world");
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

