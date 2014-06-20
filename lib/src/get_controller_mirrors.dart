part of vane;

List<ClassMirror> getControllerMirrors() {
  MirrorSystem mirrorSystem = currentMirrorSystem();
  Map<Symbol, DeclarationMirror> declarations =
      mirrorSystem.isolate.rootLibrary.declarations;
  List<ClassMirror> controllers = new List();
  ClassMirror VaneMirror = reflectClass(Vane);
  InstanceMirror RouteMirror = reflect(Route);

  for(var controller in declarations.values.where((controller) =>
      controller is ClassMirror && controller.isSubclassOf(VaneMirror))) {

    bool added = false;
    Map<String, String> pathParams;
    UriParser uriParser;

    if(controller is ClassMirror && controller.isSubclassOf(VaneMirror)) {
      // Check if the class have a @Route annotation
      if(controller.metadata.any((meta) => meta.reflectee is Route) == true) {
//        print("Adding controller ${realname(controller)}");
        controllers.add(controller);
        added = true;
      } else {
        // If the class did not have a @Route annotation, check if any member
        // methods do. First sort out valid methods for @Route then check if
        // @Route is present.
        for(var method in controller.declarations.values.where((mirror)
            => mirror is MethodMirror && mirror.isRegularMethod)) {

          // Check if the method have a @Route annotation
          if(method.metadata.any((meta) => meta.reflectee is Route) == true) {
//            print("Adding controller ${realname(controller)}");
            controllers.add(controller);
            added = true;
          }
        }
      }

    } else if(controller is ClassMirror) {
      // PODO controllers
//      print("Podo controller: ${controller.simpleName}");

    } else if(controller is MethodMirror) {
      // Func controllers
//      print("Func controller: ${controller.simpleName}");

    } else {

//      print("Other controller ???: ${controller.simpleName}");
    }
  }

  return controllers;
}

