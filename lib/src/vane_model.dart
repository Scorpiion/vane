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

    // Run jsonToModel, will run recursively on object if needed
    return jsonToModel(json, model);


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

  static String encode(Object object, {bool validate: true}) {
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
    return JSON.encode(object);
  }

  static Map document(VaneModel object) {
    // Validate models data
    object.validate();

    return object.toJson();
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


  static String transform(Object ob) {
//    return '''  Map toJson() {
//    Map map = new Map();
//    map["aaa"] = this.aaa;
//    map["bbb"] = this.bbb;
//    return map;
//  }''';


    // Function to convert objects to a map representation
    String convertObject(Object ob) {
      InstanceMirror This = reflect(ob);
      Map map = new Map();
      StringBuffer code = new StringBuffer();

      code.writeln('  Map toJson() {');
      code.writeln('    Map map = new Map();');

      This.type.declarations.forEach((Symbol key, DeclarationMirror val) {
        if(val is VariableMirror) {
          TypeMirror listMirror = reflectType(List);

          if(VMMS.isBasicType(val.type.reflectedType)) {
//          if(val.type.reflectedType == String ||
//             val.type.reflectedType == int ||
//             val.type.reflectedType == bool ||
//             val.type.reflectedType == num) {
            // For transformer
            code.writeln('    map["${symbolString(key)}"] = this.${symbolString(key)};');
          } else if(val.type.isAssignableTo(listMirror)) {
            // Note: We use 'isAssignableTo()' here instead of just '==' because
            // while 'val.type.reflectedType == List' does work on a list like
            // 'List a = [1,2]' it does not work on 'List<int> a = [1,2]',
            // 'isAssignableTo()' works in both cases.
            code.writeln('    map["${symbolString(key)}"] = this.${symbolString(key)};');
          }
        }
      });
      code.writeln('    return map;');
      code.writeln('  }');

      return code.toString();
    }

    return convertObject(ob);
  }



















  Map toJson() {
    // Function to convert objects to a map representation
    Map modelToJson(Object model) {
      InstanceMirror mirror = reflect(model);
      Map map = new Map();

      mirror.type.declarations.forEach((Symbol key, DeclarationMirror val) {
        if(val is VariableMirror) {
          TypeMirror listMirror = reflectType(List);
          TypeMirror mapMirror = reflectType(Map);

          // TODO: Use same type check here as we do in decode?
          //
          //       if(mirror.isSubtypeOf(VaneModelMember.listMirrorT) == true ||
          //          mirror.isSubtypeOf(VaneModelMember.mapMirrorT) == true) {
          //

          if(VMMS.isBasicType(val.type.reflectedType) ||
//          if(val.type.reflectedType == String ||
//             val.type.reflectedType == int ||
//             val.type.reflectedType == bool ||
//             val.type.reflectedType == num ||
             val.type.isAssignableTo(listMirror) ||
             val.type.isAssignableTo(mapMirror)) {
            String mapKey = symbolString(key);

            // Add value to map, remove Polymer Observable prefix if present
            if(mapKey.startsWith("__\$")) {
              map[mapKey.substring(3)] = mirror.getField(key).reflectee;
            } else {
              // Add value to map
              map[mapKey] = mirror.getField(key).reflectee;
            }

            // TODO: Add special case for DateTime ?!?!

          } else {
            String mapKey = symbolString(key);

            // Recursively add new map based on the member object, remove
            // Polymer Observable prefix if present
            if(mapKey.startsWith("__\$")) {
              map[mapKey.substring(3)] = modelToJson(mirror.getField(key).reflectee);
            } else {
              // Add value to map
              map[mapKey] = modelToJson(mirror.getField(key).reflectee);
            }
          }
        }
      });

      return map;
    }

    // Run objectToJson, will run recursively on object if needed
    return modelToJson(this);
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

void transformP(String s) {
  bool doPrint;

  doPrint = false;
//  doPrint = true;

  if(doPrint) {
    print(s);
  }
}


