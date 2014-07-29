// Copyright (c) 2014, Robert Åkerblom-Andersson <Robert@dartvoid.com>

part of vane;

class _Middlewares {
  List<ClassMirror> pre = new List<ClassMirror>();
  List<ClassMirror> post = new List<ClassMirror>();
}

_Middlewares parsePipeline(ClassMirror controllerMirror) {
  ClassMirror VaneMirror = reflectClass(Vane);
  var middlewares = new _Middlewares();

  bool pipelineDeclared = false;
  bool foundThis = false;

  for(var vMirror in controllerMirror.declarations.values.where((mirror)
          => mirror is VariableMirror)) {
    if(vMirror.simpleName == new Symbol("pipeline")) {
      pipelineDeclared = true;

      // Create instance
      var controller = controllerMirror.newInstance(new Symbol(""), []);

      // Check that pipeline is valid
      if(controller.reflectee.pipeline != null &&
         controller.reflectee.pipeline is List) {
        for(var pipelineEntry in controller.reflectee.pipeline) {
          if(pipelineEntry is Type) {
            ClassMirror middleware = reflectClass(pipelineEntry);

            if(middleware.isSubtypeOf(VaneMirror)) {
              if(foundThis == false) {
                Logger.root.fine("Adding to pre list: ${pipelineEntry}");
                middlewares.pre.add(middleware);
              } else {
                Logger.root.fine("Adding to post list: ${pipelineEntry}");
                middlewares.post.add(middleware);
              }
            } else {
              Logger.root.info("Error only classes that extend Vane can be added to the pipeline");
              return null;
            }
          } else {
            if(pipelineEntry == This) {
              foundThis = true;
            } else {
              Logger.root.info("Error only classes that extend Vane can be added to the pipeline");
              return null;
            }
          }
        }
      }
    }
  }

  return middlewares;
}

