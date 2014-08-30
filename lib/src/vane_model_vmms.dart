// Copyright (c) 2014, Robert Åkerblom-Andersson <Robert@dartvoid.com>

part of vane_model;

/// VMMS, Vane Model Mirrors
///
/// Static mirrors, create only once and used for comparisions and instance
/// instantiations.
class VMMS {
  /// Class mirrors, note that because dynamic is not a class, we simulate a
  /// dynamic ClassMirror with a ClassMirror from the String type
  static final ClassMirror classMirrorDynamic   = reflectClass(String);
  static final ClassMirror classMirrorInt       = reflectClass(int);
  static final ClassMirror classMirrorDouble    = reflectClass(double);
  static final ClassMirror classMirrorNum       = reflectClass(num);
  static final ClassMirror classMirrorBool      = reflectClass(bool);
  static final ClassMirror classMirrorString    = reflectClass(String);
  static final ClassMirror classMirrorList      = reflectClass(List);
  static final ClassMirror classMirrorMap       = reflectClass(Map);
  static final ClassMirror classMirrorObject    = reflectClass(Object);
  static final ClassMirror classMirrorVaneModel = reflectClass(VaneModel);

  /// Type mirrors
  static final TypeMirror typeMirrorDynamic     = reflectType(dynamic);
  static final TypeMirror typeMirrorInt         = reflectType(int);
  static final TypeMirror typeMirrorDouble      = reflectType(double);
  static final TypeMirror typeMirrorNum         = reflectType(num);
  static final TypeMirror typeMirrorBool        = reflectType(bool);
  static final TypeMirror typeMirrorString      = reflectType(String);
  static final TypeMirror typeMirrorList        = reflectType(List);
  static final TypeMirror typeMirrorMap         = reflectType(Map);
  static final TypeMirror typeMirrorObject      = reflectType(Object);
  static final TypeMirror typeMirrorVaneModel   = reflectType(VaneModel);

  /// Check if type is a builtin basic type
  static bool isBasicType(Type type) {
    return (type == String || type == int || type == bool ||
            type == double || type == num);
  }

  static bool isAssignableToBasic(ClassMirror cm) {
    return (cm.isAssignableTo(VMMS.typeMirrorInt) ||
            cm.isAssignableTo(VMMS.typeMirrorDouble) ||
            cm.isAssignableTo(VMMS.typeMirrorNum) ||
            cm.isAssignableTo(VMMS.typeMirrorBool) ||
            cm.isAssignableTo(VMMS.typeMirrorString));
  }
}

