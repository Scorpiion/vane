// Copyright (c) 2014, Robert Åkerblom-Andersson <Robert.nr1@gmail.com>

part of vson;

const int NO_CONSTRUCTOR = 0;
const int BUILTIN_CONSTRUCTOR = 1;
const int EMPTY_CONSTRUCTOR = 2;
const int MODEL_CONSTRUCTOR = 3;

class VaneModelMirror extends Object with VaneModelTypeCheck {
  InstanceMirror im;
  ClassMirror get cm => im.type;
  Map<String, VaneModelMirrorMember> members = new Map<String, VaneModelMirrorMember>();

  VaneModelMirror(Object model) {
    im = reflect(model);
  }

  /// Scans all members on the mirror and populates the [members] map with all
  /// members of the model and their type information.
  void scanMembers() {
//    print(" --> Scanning members...");

    for(var item in cm.instanceMembers.values) {
      if(item.isGetter &&
         cm.instanceMembers.keys.contains(new Symbol('${symbolString(item.simpleName)}='))) {
        // If return is an object, we save that type mirror since we can create
        // a new instance based on it. If the return object is a list, then
        // we can create a new instance based on it, therefor we create a new
        // object that we can use.
        if(item.returnType.isSubtypeOf(VMMS.typeMirrorList) == true) {
          // Check if list was instantiated (if not we only support dynamic lists)
          List list = im.getField(item.simpleName).reflectee;
          if(list == null) {
            list = VMMS.classMirrorList.newInstance(new Symbol(''), []).reflectee;
//            print("Huston, we got null...");
          } else {
//            print("Huston, no null in sight!");
          }

          // Create new mirror for list
          ClassMirror listMirror = reflect(list).type;

          members[symbolString(item.simpleName)]
              = new VaneModelMirrorMember(item.simpleName, cm: listMirror);

        } else if(item.returnType.isSubtypeOf(VMMS.typeMirrorMap) == true) {
          // Check if map was instantiated (if not we only support dynamic maps)
          Map map = im.getField(item.simpleName).reflectee;
          if(map == null) {
            map = VMMS.classMirrorMap.newInstance(new Symbol(''), []).reflectee;
//            print("Huston, we got null...");
          } else {
//            print("Huston, no null in sight!");
          }

          // Create new mirror for map
          ClassMirror mapMirror = reflect(map).type;

          members[symbolString(item.simpleName)]
              = new VaneModelMirrorMember(item.simpleName, cm: mapMirror);
        } else {
          members[symbolString(item.simpleName)]
              = new VaneModelMirrorMember(item.simpleName, tm: item.returnType);
        }
      }
    }
  }

  /// Creates a new instance of member [name]
  Object newInstance(String name) {
    VaneModelMirrorMember vmmm = members[name];
    return _newInstance(vmmm.cm);
  }

  /// Create a new value of list element
  Object newListElement() {
    if(isList == true && isListTyped == true) {
      ClassMirror elementCm = listType();
      return _newInstance(elementCm);
    } else if(isList == true) {
      return new Object();
    } else {
      throw("Error vmm is not a list");
    }
  }

  /// Create a new instance of map value
  Object newMapValue() {
    if(isMap == true && isMapTyped == true) {
      ClassMirror valueCm = mapValueType();
      return _newInstance(valueCm);
    } else if(isMap == true) {
      return new Object();
    } else {
      throw("Error vmm is not a map");
    }
  }

  /// Creates a new instance of member [name]
  static Object _newInstance(ClassMirror cm) {
    var instance;

    // Check what constructor this mirror should use
    int constructor = constructorTypeOnClassMirror(cm);

    // Create a new instance using the correct constructor
    if(constructor == BUILTIN_CONSTRUCTOR) {
      if(cm.hasReflectedType == true) {
        if(cm.reflectedType == String) {
          instance = "";
        } else if(cm.reflectedType == int) {
          instance = 0;
        } else if(cm.reflectedType == bool) {
          instance = false;
        } else if(cm.reflectedType == double) {
          instance = 0.0;
        } else if(cm.reflectedType == num) {
          instance = 0;
        } else if(cm.isSubtypeOf(VMMS.typeMirrorList) == true) {
          // Create new list instance using the empty constructor of the
          // lists super interface. For reference on this usage please see
          // here on why we use superinterface[0]:
          // https://groups.google.com/a/dartlang.org/d/topic/misc/9ze4Cqn5iAc/discussion

//          print("");
//          print(cm.runtimeType);
//          print(cm.superinterfaces);
//          print(cm.superclass);
//          print(cm.superclass.superinterfaces);
//          print(cm.instanceMembers);
//          print(cm.hasReflectedType);
//          print(cm.typeArguments);
//
//          print("");
//          print(cm.typeVariables[0].originalDeclaration);
//          print(cm.typeVariables[0].owner);
//          print(cm.typeVariables[0].qualifiedName);
//          print(cm.typeVariables[0].upperBound);
//          print(cm.typeVariables[0].typeArguments);
//          print(cm.typeVariables[0].typeVariables);

          instance = new List<Tag>();

//          instance = cm.newInstance(new Symbol(''), []).reflectee;

          // Old usage that no longer works
//          instance = cm.superinterfaces[0].newInstance(new Symbol(''), []).reflectee;
        } else if(cm.isSubtypeOf(VMMS.typeMirrorMap) == true) {
          // Note: This "super climbing" is adapted for instansiation of a Map
          // of type "LinkedHashMap". Not sure what happends for the
          // implementations of "HashMap" and "SplayTreeMap".
          //
          // TODO: Add support for "HashMap" and "SplayTreeMap" implementations
          //       do some check to see what type and use same "super climbing"
          //       method to find constructors for them.

          // Note: Use this to get a HashMap insntace (not LinkedHashMap)
//          var hashMapInstance = cm.superclass.superclass.superinterfaces[0].newInstance(new Symbol(''), []).reflectee;

          // Create new map instance (LinkedHashMap implementation) using the
          // default map empty constructor
          instance = cm.superclass.superinterfaces[0].superinterfaces[0].newInstance(new Symbol(''), []).reflectee;
        } else {
          throw new Exception("Lost in if else jungle...");
        }
      } else {
        // We come here for lists without a generic type, eg "List" but not
        // List<int> or List<dynamic> (note: new List() gives List<dynamic>)
        if(cm.isSubtypeOf(VMMS.typeMirrorList) == true) {
          // Create new list instance using the default list empty constructor
          instance = cm.superinterfaces[0].newInstance(new Symbol(''), []).reflectee;
       } else if(cm.isSubtypeOf(VMMS.typeMirrorMap) == true) {
          // Create new map instance (LinkedHashMap implementation) using the
          // default map empty constructor
          instance = cm.superclass.superinterfaces[0].superinterfaces[0].newInstance(new Symbol(''), []).reflectee;
       } else {
         throw new Exception("Lost in if else jungle...");
       }
      }
    } else if(constructor == EMPTY_CONSTRUCTOR) {
      // Create new instance using empty constructor
      instance = cm.newInstance(new Symbol(''), []).reflectee;
    } else if(constructor == MODEL_CONSTRUCTOR) {
      // Create new instance using model constructor
      instance = cm.newInstance(new Symbol('model'), []).reflectee;
    } else {
      throw new Exception("All VaneModels must have either an empty default constructor or empty \".model\" constructor, please add \"${symbolString(cm.simpleName)}.model();\" to your model");
    }

    return instance;
  }

  static int constructorTypeOnClassMirror(ClassMirror cm) {
    bool foundBasic = false;
    bool foundEmpty = false;
    bool foundModel = false;

    // Check if mirror is a builtin type that does not need a constructor
    if(cm.hasReflectedType == true &&
       (VMMS.isBasicType(cm.reflectedType) == true ||
       cm.isSubtypeOf(VMMS.typeMirrorList) == true ||
       cm.isSubtypeOf(VMMS.typeMirrorMap) == true)) {
      foundBasic = true;
    } else if(cm.isSubtypeOf(VMMS.typeMirrorList) == true ||
              cm.isSubtypeOf(VMMS.typeMirrorMap) == true) {
      foundBasic = true;
    }

    // If mirror is not a built in type, look for an empty default
    // constructor or an empty .model constructor
    if(foundBasic == false) {
      for(var method in cm.declarations.values.where((m) => m is MethodMirror)) {
        if(method.isConstructor == true) {
          if(method.constructorName == const Symbol('')) {
            if(method.parameters.isEmpty == true) {
              foundEmpty = true;
              break;
            }
          } else if(method.constructorName == new Symbol('model')) {
            if(method.parameters.isEmpty == true) {
              foundModel = true;
              break;
            }
          }
        }
      }
    }

    // Return the type of constructor that is needed
    if(foundBasic == true) {
      return BUILTIN_CONSTRUCTOR;
    } else if(foundEmpty == true) {
      return EMPTY_CONSTRUCTOR;
    } else if(foundModel == true) {
      return MODEL_CONSTRUCTOR;
    } else {
      return NO_CONSTRUCTOR;
    }
  }
}

VaneModelMirror reflectModel(Object model) {
  VaneModelMirror vmm = new VaneModelMirror(model);

  // Scan members
  vmm.scanMembers();

  return vmm;
}

class VaneModelMirrorMember extends Object with VaneModelTypeCheck {
  // TODO: Rename to just symbol? Or just name?
  Symbol nameSymbol;
  TypeMirror tm;
  ClassMirror cm;

  VaneModelMirrorMember(this.nameSymbol, {TypeMirror this.tm, ClassMirror this.cm} ) {
    // Create and save a mirror of the type if a cm was not provided
    if(cm == null) {
      cm = reflectClass(tm.reflectedType);
    }
  }
}

class Tag extends VaneModel {
  String tag;
  bool selected;

  Tag(this.tag, [this.selected = false]);

  Tag.model();
}

