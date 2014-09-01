// Copyright (c) 2014, Robert Åkerblom-Andersson <Robert@dartvoid.com>

part of vane_model;

/// [VaneModel] can automatically convert a Dart data model class to and
/// from json with its [VaneModel.encode] and [VaneModel.decode] functions.
/// Classes extending [VaneModel] don't need and should not implement the
/// [toJson] function nor the [fromJson] constructor.
///
/// [VaneModel] is used to [encode] Dart objects (that extend [VaneModel]) to
/// json [String], and to [decode] json [String] into Dart objects. It can also
/// convert a Dart object to a [Map] format well suited for MongoDB with it's
/// helper function [VaneModel.document]. During conversions to and from json
/// the models constrains are also checked and if a validation is found a
/// [ValidationException] is thrown.
///
/// All [VaneModel]s must have either an empty default constructor or empty
/// named model constructor. See these examples of how to implement the
/// model constructor:
///
///     class MyModel1 extends VaneModel {
///       String myData;
///     }
///
///     class MyModel2 extends VaneModel {
///       String myData;
///
///       MyModel2(this.myData);
///
///       MyModel2.model();
///     }
///
abstract class VaneModel {
  static Validator _v = new Validator();

  static dynamic decode(json, model, {bool validate: true}) {
    // Return correct type if we got empty json data (responses from APIs or
    // databases can be empty if no data was found for example)
    if(json is String) {
      switch(json) {
        case "":   return "";
        case "[]": return [];
        case "{}": return {};
        default:   break;
      }
    } else if(json is List) {
      if(json.isEmpty) {
        return [];
      }
    } else if(json is Map) {
      if(json.isEmpty) {
        return {};
      }
    } else {
      // TODO: Throw error, json can only be String, List or Map
    }

    /// Function used to convert json into a model object
    Object jsonToModel(json, Object model) {
      var document;

      // Create a new mirror on the model
      VaneModelMirror vmm = reflectModel(model);

      // We support both json strings and already parsed by JSON.decode() and
      if(json is String) {
        // We do a check in the type of the model here so we can seperate a
        // json string from a list item that is a string
        if(model is String) {
          document = json;
        } else {
          document = JSON.decode(json);
        }
      } else {
        document = json;
      }

      // If vmm is a list
      if(vmm.isList == true) {
        if(document is List) {
//          print("--> Just found out that vmm is a list");

          // Recursively convert and add all items to the list
          for(var item in document) {
            // Create a new instance of the list item
            var newElement = vmm.newListElement();

            // Convert item
            var model = jsonToModel(item, newElement);

            // Add the new converted model object to the list
            vmm.im.reflectee.add(model);
          }

          // Return list
          return vmm.im.reflectee;
        } else {
          throw("Expected list in json document but found ${document.runtimeType}");
        }
      }

      // If vmm is a map
      if(vmm.isMap == true) {
        if(document is Map) {
//          print("--> Just found out that vmm is a map");

          // Recursively convert and add all items to the list
          for(var key in document.keys) {
            // Create a new instance of the map item
            var newElement = vmm.newMapValue();

            // Convert item
            var model = jsonToModel(document[key], newElement);

            // Add the new converted model object to the map
            vmm.im.reflectee[key] = model;
          }

          // Return map
          return vmm.im.reflectee;
        } else {
          throw("Expected map in json document but found ${document.runtimeType}");
        }
      }

      // If the vmm is a basic builtin type, just return it since it does not
      // need any conversion
      if(vmm.isBasic == true) {
//        print("--> Just found out that vmm is a basic object, returning it");

        // Return all basic types without any conversion
        return document;
      }

      // If vmm is an VaneModel or Podo object
      if(vmm.isModel == true && document is Map) {
//        print("--> Just found out that vmm is a model");

        // Check all members of the model to see if there is a match in the
        // json document/map
        for(String key in vmm.members.keys) {
          // Check if key exists in the document
          if(document.keys.contains(key)) {
            var element;

            if(vmm.members[key].isBasic == true) {
              // Use value directly from document if we expect a basic type
              element = document[key];
            } else {
//              print("--> Before vmm.newInstance(key), key = ${key}");

              // Create a new instance of the member model
              var newModel = vmm.newInstance(key);

//              print("--> Output from vmm.newInstance(key): ${newModel.runtimeType}");

              // Recursively convert the json element into a model object
              element = jsonToModel(document[key], newModel);
            }

            // Update member in the model instance
            vmm.im.setField(vmm.members[key].nameSymbol, element);
          } else {
//            print("Could not find member ${key} from model in json document");
          }
        }

        return vmm.im.reflectee;
      }

      throw("Unsupported datatype......");
    }

    // Use either mirrors or predefined decode function
    bool useMirr = false;

    // TODO: Benchmark and see what is fastest, use try/catch or mirrors to see
    // if an object has a _useMirrors() function.
    try {
      useMirr = model.useMirrors();
    } catch(e) {
      // If the object don't have a _useMirror function, it's not a VaneModel
      // and we force using mirrors implementation
      useMirr = true;
    }

    if(useMirr == true) {
      // Run mirror based jsonToModel function, will run recursively on object
      // if needed
      return jsonToModel(json, model);
    } else {
      // Run code generated "factory" method (not a Dart built in factory since
      // we can't use it as flexibly as a method)
      var document;

      // We support both json strings and map documents
      if(json is String) {
        document = JSON.decode(json);
      } else {
        document = json;
      }

      return model.fromDocument(document);
    }

    /*
    // Validate data
    // TODO: Do we validate maps of models?
    if(validate == true) {
      if(objects.isNotEmpty) {
        objects.forEach((ob) => VaneModel._validateAny(ob));
      } else {
        VaneModel._validateAny(object);
      }
    }

    // Return object or list of objects
    if(objects.isNotEmpty) {
      return objects;
    } else {
      return object;
    }
    */
  }

  /// Function used by transformer in order to tell VaneModel that code has
  /// been generated
  bool useMirrors() => true;

  static void _validateAny(model) {
    if(VMMS.isBasicType(model)) {
      // Validate built type
      // TODO: Should builtin types be validated? Practical use cases?
      _v.validate(model);
    } else {
      // Validate model data
      model.validate();
    }
  }

  static String encode(Object model, {bool validate: true}) {
    // Validate data
    // TODO: Do we validate maps of models?
//    if(validate == true) {
//      if(object is List) {
//        // Validate all models in list
//        object.forEach((ob) => VaneModel._validateAny(ob));
//      } else {
//        VaneModel._validateAny(object);
//      }
//    }

    // Encode to json format
    return JSON.encode(model);
  }

  static Map document(VaneModel model) {
    // Validate models data
//    model.validate();

    return model.toJson();
  }

  Set<ConstraintViolation> validate() {
    Set<ConstraintViolation> violations = _v.validate(this);

    if(violations.isNotEmpty) {
      Logger.root.warning("The data in ${this.runtimeType} contain constrains violations");
      throw new ValidationException(violations.join("\n"));
    }

    return violations;
  }

  // TODO: Add special case for DateTime
  // https://code.google.com/p/dart/issues/detail?id=16628

  /// Function to convert objects to a document/map representation that then is
  /// converted into JSON by [JSON.encode]
  Map toJson() {
    /// Function to convert objects to a document/map representation
    Map modelToDocument(Object model) {
      InstanceMirror mirror = reflect(model);
      Map map = new Map();

      mirror.type.declarations.forEach((Symbol key, DeclarationMirror val) {
        if(val is VariableMirror) {
          TypeMirror listMirror = reflectType(List);
          TypeMirror mapMirror = reflectType(Map);

          // Remove Polymer Observable prefix if present
          String kv = symbolString(key);
          if(kv.startsWith("__\$")) {
            kv = kv.substring(3);
          }

          // Check type
          if(VMMS.isBasicType(val.type.reflectedType) ||
             val.type.isAssignableTo(listMirror) ||
             val.type.isAssignableTo(mapMirror)) {
            // Add value to map
            map[kv] = mirror.getField(key).reflectee;

            // TODO: Add special case for DateTime and Duration....

          } else {
            // Add value to map
            map[kv] = modelToDocument(mirror.getField(key).reflectee);
          }
        }
      });

      return map;
    }

    // Run modelToDocument, will run recursively on object if needed
    return modelToDocument(this);
  }

  /// Generate code for transformer
  static String transform(Object model) {
    // Function to generate code to for json generation
    StringBuffer modelToCode(Object model, StringBuffer code, bool fromDocument) {
      InstanceMirror mirror = reflect(model);
      String Model;

      if(fromDocument == true) {
        // Create an easier to use variable for the model name
        Model = symbolString(mirror.type.simpleName);

        // Check if we should use empty or model constructor
        int constructor = VaneModelMirror.constructorTypeOnClassMirror(mirror.type);

        code.writeln('  bool useMirrors() => false;\n');
        code.writeln('  ${Model} fromDocument(Map document) {');
        if(constructor == EMPTY_CONSTRUCTOR) {
          code.writeln('    ${Model} This = new ${Model}();');
        } else if(constructor == MODEL_CONSTRUCTOR) {
          code.writeln('    ${Model} This = new ${Model}.model();');
        } else {
          throw new Exception("All VaneModels must have either an empty default constructor or empty \".model\" constructor, please add \"${Model}.model();\" to your model");
        }
      } else {
        code.writeln('  Map toJson() {');
        code.writeln('    Map map = new Map();');
      }

      // For each model member
      mirror.type.declarations.forEach((Symbol key, DeclarationMirror val) {
        if(val is VariableMirror) {
          TypeMirror listMirror = reflectType(List);
          TypeMirror mapMirror = reflectType(Map);

          // Remove Polymer Observable prefix if present
          String kv = symbolString(key);
          if(kv.startsWith("__\$")) {
            kv = kv.substring(3);
          }

          // Check type
          if(VMMS.isBasicType(val.type.reflectedType)) {
            if(fromDocument == true) {
              // Write code
              code.writeln('    This.${kv} = document["${kv}"];');
            } else {
              // Add value to map
              code.writeln('    map["${kv}"] = this.${kv};');
            }
          } else if(val.type.isAssignableTo(listMirror)) {
             if(fromDocument == true) {
               // Check what type of list
               if(VMMS.isBasicType(val.type.typeArguments[0].reflectedType)) {
//                 print("Found typed basic list!");
                 code.writeln('    if(This.${kv} == null) {');
                 code.writeln('      This.${kv} = new List();');
                 code.writeln('    }');
                 code.writeln('    This.${kv}.addAll(document["${kv}"]);');
               } else if(val.type.typeArguments[0] != VMMS.typeMirrorDynamic) {
//                 print("Found typed model based list!");
                 // Check if we should use empty or model constructor
                 int constructor = VaneModelMirror.constructorTypeOnClassMirror(val.type.typeArguments[0]);

                 code.writeln('    if(This.${kv} == null) {');
                 code.writeln('      This.${kv} = new List();');
                 code.writeln('    }');
                 if(constructor == EMPTY_CONSTRUCTOR) {
                   code.writeln('    This.${kv}.addAll(document["${kv}"].map((doc) => VaneModel.decode(doc, new ${val.type.typeArguments[0].reflectedType}())));');
                 } else if(constructor == MODEL_CONSTRUCTOR) {
                   code.writeln('    This.${kv}.addAll(document["${kv}"].map((doc) => VaneModel.decode(doc, new ${val.type.typeArguments[0].reflectedType}.model())));');
                 } else {
                   throw new Exception("All VaneModels must have either an empty default constructor or empty \".model\" constructor, please add \"${kv}.model();\" to your model");
                 }
               } else {
//                 print("Found dynamic list!");
                 // Since we don't know the type we don't try to create new
                 // instances for items
                 code.writeln('    if(This.${kv} == null) {');
                 code.writeln('      This.${kv} = new List();');
                 code.writeln('    }');
                 code.writeln('    This.${kv}.addAll(document["${kv}"]);');
               }
             } else {
               // Add value to map
               code.writeln('    map["${kv}"] = this.${kv};');
             }
          } else if(val.type.isAssignableTo(mapMirror)) {
             if(fromDocument == true) {
               // Check what type of map
               if(VMMS.isBasicType(val.type.typeArguments[1].reflectedType)) {
//                 print("Found typed basic map!");
                 code.writeln('    if(This.${kv} == null) {');
                 code.writeln('      This.${kv} = new Map();');
                 code.writeln('    }');
                 code.writeln('    This.${kv}.addAll(document["${kv}"]);');
               } else if(val.type.typeArguments[0] != VMMS.typeMirrorDynamic) {
//                 print("Found typed model based map!");
                 // Check if we should use empty or model constructor
                 int constructor = VaneModelMirror.constructorTypeOnClassMirror(val.type.typeArguments[1]);

                 code.writeln('    if(This.${kv} == null) {');
                 code.writeln('      This.${kv} = new Map();');
                 code.writeln('    }');

                 if(constructor == EMPTY_CONSTRUCTOR) {
                   code.writeln('    document["${kv}"].forEach((key, doc) => This.m2[key] = VaneModel.decode(doc, new ${val.type.typeArguments[1].reflectedType}()));');
                 } else if(constructor == MODEL_CONSTRUCTOR) {
                   code.writeln('    document["${kv}"].forEach((key, doc) => This.m2[key] = VaneModel.decode(doc, new ${val.type.typeArguments[1].reflectedType}.model()));');
                 } else {
                   throw new Exception("All VaneModels must have either an empty default constructor or empty \".model\" constructor, please add \"${kv}.model();\" to your model");
                 }
               } else {
//                 print("Found dynamic map!");
                 // Since we don't know the type we don't try to create new
                 // instances for items
                 code.writeln('    if(This.${kv} == null) {');
                 code.writeln('      This.${kv} = new Map();');
                 code.writeln('    }');
                 code.writeln('    This.${kv}.addAll(document["${kv}"]);');
               }
             } else {
               // Add value to map
               code.writeln('    map["${kv}"] = this.${kv};');
             }

            // TODO: Add special case for DateTime and Duration....

          } else {
            if(fromDocument == true) {
              code.writeln('    This.${kv} = document["${kv}"];');
            } else {
              code.writeln('    map["${kv}"] = this.${kv};');
            }
          }
        }
      });

      if(fromDocument == true) {
        code.writeln('    return This;');
        code.writeln('  }\n');
      } else {
        code.writeln('    return map;');
        code.writeln('  }');
      }

      return code;
    }

    // String buffer used to store generated code
    StringBuffer code = new StringBuffer();

    // Run modelToCode, will run recursively on object if needed
    code = modelToCode(model, code, true);

    // Run modelToCode, will run recursively on object if needed
    code = modelToCode(model, code, false);

    // Return the buffer as a string
    return code.toString();
  }
}

/// [ValidationException] is thrown if a class extending the [VaneModel] class
/// contain any data that validate the models constraints.
class ValidationException implements Exception {
  final String msg;
  const ValidationException([this.msg]);
  String toString() => msg == null ? 'ValidationException' : msg;
}

String symbolString(Symbol symbol) {
  return symbol.toString().split('"')[1];
}

