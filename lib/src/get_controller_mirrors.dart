// Copyright (c) 2014, Robert Åkerblom-Andersson <Robert@dartvoid.com>

part of vane;

List<ClassMirror> getControllerMirrors() {
  MirrorSystem mirrorSystem = currentMirrorSystem();
  Map<Symbol, DeclarationMirror> declarations =
      mirrorSystem.isolate.rootLibrary.declarations;
  List<ClassMirror> controllers = new List();
  ClassMirror VaneMirror = reflectClass(Vane);
  InstanceMirror RouteMirror = reflect(Route);

  for(var mirror in declarations.values) {
    if(mirror is ClassMirror && mirror.isSubclassOf(VaneMirror)) {
      // Check if the class have a @Route annotation
      if(mirror.metadata.any((meta) => meta.reflectee is Route) == true) {
//        print("Adding controller ${realname(controller)}");
        controllers.add(mirror);
      } else {
        // If the class did not have a @Route annotation, check if any member
        // methods do. First sort out valid methods for @Route then check if
        // @Route is present.
        for(var method in mirror.declarations.values.where((method)
            => method is MethodMirror && method.isRegularMethod)) {

          // Check if the method have a @Route annotation
          if(method.metadata.any((meta) => meta.reflectee is Route) == true) {
//            print("Adding controller ${realname(controller)}");
            controllers.add(mirror);
          }
        }
      }

    } else if(mirror is ClassMirror) {
      // PODO controllers
//      print("Podo controller: ${controller.simpleName}");

    } else if(mirror is MethodMirror) {
      // Func controllers
//      print("Func controller: ${controller.simpleName}");

    } else {

//      print("Other controller ???: ${controller.simpleName}");
    }
  }

  return controllers;
}

