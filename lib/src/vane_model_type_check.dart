// Copyright (c) 2014, Robert Åkerblom-Andersson <Robert@dartvoid.com>

part of vane_model;

/// Adds type checking behaviour
class VaneModelTypeCheck {
  ClassMirror cm;

  /// Is the mirror on a basic builtin type
  bool get isBasic {
    return (cm.hasReflectedType == true &&
           ((VMMS.isBasicType(cm.reflectedType) == true) ||
           VMMS.isAssignableToBasic(cm)));
  }

  /// Is the mirror on a List
  bool get isList => cm.isSubtypeOf(VMMS.typeMirrorList);

  /// Is the mirror on a typed List (eg. List<int> or List<Podo>)
  bool get isListTyped => (isList == true &&
                           (cm.typeArguments.isNotEmpty == true ||
                           cm.typeArguments[0] != VMMS.typeMirrorDynamic));

  ClassMirror listType() {
    if(isList == true && cm.typeArguments.isNotEmpty == true) {
      if(cm.typeArguments.isNotEmpty) {
        if(cm.typeArguments[0] == VMMS.typeMirrorDynamic) {
          return VMMS.classMirrorDynamic;
        } else {
          return cm.typeArguments[0];
        }
      } else {
        throw new Exception("Can't find a type for this list......?!?");
      }
    } else {
      throw new Exception("Can't get list type on mirror that is not a list");
    }
  }

  /// Is the mirror on a Map
  bool get isMap => cm.isSubtypeOf(VMMS.typeMirrorMap);

  /// Is the mirror on a typed Map (eg. Map<String, String> or Map<String, Podo>)
  bool get isMapTyped => (isMap == true &&
                         (cm.typeArguments.isNotEmpty == true ||
                         cm.typeArguments[0] != VMMS.typeMirrorDynamic));

  ClassMirror mapValueType() {
    if(isMap == true && cm.typeArguments.isNotEmpty == true) {
      if(cm.typeArguments.isNotEmpty) {
        if(cm.typeArguments[0] == VMMS.typeMirrorDynamic) {
          return VMMS.classMirrorDynamic;
        } else {
          return cm.typeArguments[1];
        }
      } else {
        throw new Exception("Can't find a type for this map......?!?");
      }
    } else {
      throw new Exception("Can't get map type on mirror that is not a map");
    }
  }

  /// Is the mirror on a model
  bool get isModel => cm.isSubtypeOf(VMMS.typeMirrorVaneModel);

  /// Is the mirror on an object
  bool get isObject => cm.isSubtypeOf(VMMS.typeMirrorObject);
}

