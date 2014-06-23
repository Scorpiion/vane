// Copyright (c) 2014, Robert Åkerblom-Andersson <Robert@dartvoid.com>

part of vane;

class Controllers {
  List<ClassMirror> vaneControllers = new List<ClassMirror>();
  List<ClassMirror> podoControllers = new List<ClassMirror>();
  List<MethodMirror> funcControllers = new List<MethodMirror>();
}

Controllers scanControllers() {
  MirrorSystem mirrorSystem = currentMirrorSystem();
  Map<Symbol, DeclarationMirror> declarations =
      mirrorSystem.isolate.rootLibrary.declarations;
  Controllers controllers = new Controllers();
  ClassMirror VaneMirror = reflectClass(Vane);
  InstanceMirror RouteMirror = reflect(Route);

  for(var mirror in declarations.values) {
    if(mirror is ClassMirror) {
      // Check if the class have a @Route annotation
      if(mirror.metadata.any((meta) => meta.reflectee is Route) == true) {
        if(mirror.isSubclassOf(VaneMirror)) {
//          print("Adding vane controller ${realname(mirror)}");
          controllers.vaneControllers.add(mirror);
        } else {
//          print("Adding podo controller ${realname(mirror)}");
          controllers.podoControllers.add(mirror);
        }
      } else {
        // If the class did not have a @Route annotation, check if any member
        // methods do. First sort out valid methods for @Route then check if
        // @Route is present.
        for(var method in mirror.declarations.values.where((method)
            => method is MethodMirror && method.isRegularMethod)) {
          // Check if the method have a @Route annotation
          if(method.metadata.any((meta) => meta.reflectee is Route) == true) {
            if(mirror.isSubclassOf(VaneMirror)) {
//              print("Adding vane controller ${realname(mirror)}");
              controllers.vaneControllers.add(mirror);
            } else {
//              print("Adding podo controller ${realname(mirror)}");
              controllers.podoControllers.add(mirror);
            }
            break;
          }
        }
      }
    } else if(mirror is MethodMirror) {
      // Check if the class have a @Route annotation
      if(mirror.metadata.any((meta) => meta.reflectee is Route) == true) {
//        print("Adding func controller ${realname(mirror)}");
        controllers.funcControllers.add(mirror);
      }
    }
  }

  return controllers;
}

