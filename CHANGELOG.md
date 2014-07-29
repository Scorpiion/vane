
### 0.5.2

* Typo fixes by Victor Berchet
* Fixed github issue #6
* Added better logging, now possible to see when how Vane parses handlers and 
  how it matches the correct handler. 
  
See parsing of handlers (only on startup)
```dart
void main() {
  serve(logLevel: Level.FINE);
}

```

See parsing of handlers (only on startup) and matching of requests (on each request) 
```dart
void main() {
  serve(logLevel: Level.FINER);
}
```

### 0.5.1

* Added statusCode setter

### 0.5.0+2

* Updated text and fixed errors in README
* Added usage examples for Tube
* Updated examples

### 0.5.0

* New Vane server implementation that can serve three types of handlers based on the @Route annotation.
  The Vane server automatically scan your dart controller/handlers and serves them based on the @Route
  annotation.
* New @Route annotation that can be used for Vane, Podo and Func handlers. The @Route annotation uses 
  Url template syntax and Vane now supports mapping paramters from the Url as input paramters to handlers.
* New middleware declaration syntax:

Example of before to add one middleware that runs before the main controller and one that runs after it:
```dart
class TestClass extends Vane {
  void init() {
    pre.add(new SyncExample());
    post.add(new SyncExample());
  }
}
```

Example of new syntax:
```dart
class TestClass extends Vane {
  var pipeline = [SyncExample, This, SyncExample];
}
```
* Middleware system can now sense when a middleware runs next() and if it is last in the pipeline, 
  it will convert the next() call to a close() call so that the request can't hang itself. A controller
  can also get runtime information on where in the pipeline it is and how many controllers have/will run 
  before and after with the new paramters pFirst, pLast and pIndex.

### 0.3.0+2

* Updated Hello World example in README.

### 0.3.0

* Added support so that the user can choose a different handler function than main, main is still default but a different handler can be choosed, hence the same object can be registred on multiple different paths, now it's for example possible to map all GET request to one method and all POST request to a different one. Before you had to have two seperate classes.
* Added new shorthand for pathSegments called path. Similar to query, json, params and etc. Using pathSegments seems common enough and the default way to get it is complex enough compared to other parts of vane to be worth a shorthand.

### 0.2.1+1

* Moved Vane's code to a [public Github repo](https://github.com/DartVoid/Vane) 
  and updated README with link to Github repo.

### 0.2.1

* Added some simple middleware classes. One that logs all request to the 
  console (press "console" in dashboard of DartVoid to see it) and one that 
  enables cross origin requests to your handler. If you enable the Cross 
  middleware during development you can for example run the client code locally 
  and have the server code run on DartVoid (we did this during the development
  of DartVoid's dashboard, it is written with Vane and has been developed on 
  the platform it self...). 

### 0.2.0

* Added "the tube", a new way to communicate between middleware handlers. See 
  docs for examples.

### 0.1.0+1

* Syntax fix in docs.

### 0.1.0

* Initial release.

