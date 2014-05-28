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

