// Copyright (c) 2014, Robert Åkerblom-Andersson <Robert@dartvoid.com>

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:mirrors';

import 'package:unittest/unittest.dart';
import 'package:vane/vane_model.dart';

class Foo extends VaneModel {
  SimpleModel data = new SimpleModel("Dart1", 11);

  Foo();

  Foo.model();
}


class NoExtends extends VaneModel {
  String a = "aaaaaaaaaaa";
  String b = "bbbbbbbbbbb";
}

void main() {

//  List<NoExtends> myList = new List<NoExtends>()
//      ..add(new NoExtends())
//      ..add(new NoExtends());
//
//  String json = VaneModel.encode(myList);
//  print(json);
//
//  List<NoExtends> myList2 = VaneModel.decode(json, new List<NoExtends>());
//
//  print(myList2);




/*

  var t2 = new StringListTest()
    ..data.add("Vane as a server side framework")
    ..data.add("Pure for CSS");

  print(VaneModel.encode(t2));
  String json = VaneModel.encode(t2);

  print("");
  print("json: $json");
  print("");

//  JSON.decode("Vane as a server side framework");

  print(VaneModel.decode(json, new StringListTest()));

*/







  /*
  List<SimpleModel> l1 = [new SimpleModel("Robert", 1), new SimpleModel("Roberrrrrt", 2), new SimpleModel("Roberttttttttt", 3)];
  Map<String, SimpleModel> m1 = {
                                  "1": new SimpleModel("Robert", 1),
                                  "2": new SimpleModel("Roberrrrrt", 2),
                                  "3": new SimpleModel("Roberttttttttt", 3)
                                };

  List<NoExtends> l2 = [new NoExtends(), new NoExtends(), new NoExtends()];
  Map<String, NoExtends> m2 = {
                                "1": new NoExtends(),
                                "2": new NoExtends(),
                                "3": new NoExtends(),
                              };
  */

//  print(VaneModel.encode(new SimpleModel("Robert", 99999)));

//  print(JSON.encode(m1));
//  print(JSON.decode('[ {"name":"Robert","age":1}, {"name":"Roberrrrrt","age":2}, {"name":"Roberttttttttt","age":3} ]'));
//  print(JSON.decode('''
//'''));




  // *********************************************
  // Continue here.........
  // *********************************************

/*
  var pc = new List<PodoChild>()
      ..add(new PodoChild("aaaaaaaa"))
      ..add(new PodoChild("cccccccc3252"));



//  var aa = VaneModel.encode(new Podo()..l1 = [1, 2, 3]);
//  var aa = VaneModel.encode(new Podo()..l1 = [1, 2, 3]..l2 = [4, 5, 6]);

//  var pc = [new PodoChild("aaaaaaaa"), new PodoChild("cccccccc3252")];


  var aa = VaneModel.encode(new Podo()..l1 = [1, 2, 3]..l2 = [4, 5, 6]..l3 = pc);
//  var aa = VaneModel.encode(new Podo()..ll = [[11, 22], [33, 44]]);
//  var aa = VaneModel.encode(new Podo()..l1 = [1, 2, 3]..ll = [[11, 22], [33, 44]]);
  print("1. JSON = $aa");



  var b = VaneModel.decode(aa, new Podo());
  print("");
  print(b);
  print(b.l1);
  print(b.l2);
  print(b.l3);

  var bb = VaneModel.encode(b);
  print("2. JSON = $bb");
*/







  // Test with 'List', is not supported
//  String json = VaneModel.encode([1, 2, 3]);
//  var l = VaneModel.decode(json, List);
//  print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
//  print(l.runtimeType);
//  print(l);

  // Test with 'new List()'
//  String json1 = VaneModel.encode([1, 2, 3]);
//  var l1 = VaneModel.decode(json1, new List());
//  print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
//  print(l1.runtimeType);
//  print(l1);

  // Test with 'new List<int>()'
//  String json2 = VaneModel.encode([1, 2, 3]);
//  var l2 = VaneModel.decode(json2, new List<int>());
//  print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
//  print(l2.runtimeType);
//  print(l2);











//  String json = VaneModel.encode([new PodoChild("aaaaaaaa"), new PodoChild("cccccccc3252")]);

//  String json = VaneModel.encode(pc);

//  var l = VaneModel.decode(json, new List<PodoChild>());
//  print("99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999!");
//  print(l.runtimeType);
//  print(l);


//  String jso2 = VaneModel.encode(new PodoContainer()..pc = pc);
//  var p = VaneModel.decode(jso2, new PodoContainer());
//  print("99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999!");
//  print(p.runtimeType);
//  print(p);
//  print(p.pc.runtimeType);
//  print(p.pc);



//  var p = VaneModel.decode(jso2, PodoContainer);






//  var list1 = VaneModel.decode(VaneModel.encode([1, 2, 3]), List);
//  var list2 = VaneModel.decode(VaneModel.encode([4, 5, 6]), new List());
//  var list3 = VaneModel.decode(VaneModel.encode([7, 8, 9]), new List<int>());
//
//  print(list1.runtimeType);
//  print(list1);
//  print(list2.runtimeType);
//  print(list2);
//  print(list3.runtimeType);
//  print(list3);




//  List l = VaneModel.decode(VaneModel.encode([new AAA(), new AAA()]), new List<AAA>());
//  print(l.runtimeType);
//  print(l);
//  print("");







  /*
  // Works
//  ClassMirror m1 = reflectClass(List);
//  print(m1.newInstance(new Symbol(''), []));

  // Does not work, is not allowed
//  ClassMirror m2 = reflectClass(List<int>);

  // Does not work, No constructor '_GrowableList.' declared in class 'List'.
//  InstanceMirror m3 = reflect(new List());
//  print(m3.type.newInstance(new Symbol(''), []));

  // Does not work, No constructor '_GrowableList.' declared in class 'List'.
//  InstanceMirror m4 = reflect(new List<int>());
//  print(m4.type.newInstance(new Symbol(''), []));


//  InstanceMirror m4 = reflect(new List<int>());
//  ClassMirror listOfInt = m4.type.superinterfaces[0];
//  var l4 = listOfInt.newInstance(new Symbol(''), []).reflectee;
//  print(l4.runtimeType);

  InstanceMirror m4 = reflect(new List<int>());
  ClassMirror listOfInt = m4.type.superinterfaces[0];
  var l4 = listOfInt.newInstance(new Symbol(''), []).reflectee;
  print(l4.runtimeType);

  InstanceMirror m5 = reflect(new List<TestClass>());
  ClassMirror listOfTestClass = m5.type.superinterfaces[0];
  var l5 = listOfTestClass.newInstance(new Symbol(''), []).reflectee;
  print(l5.runtimeType);
 */








//  InstanceMirror im = reflect(new ListContainer());
//  ClassMirror mirror = im.type;
//
//  for(Symbol key in mirror.declarations.keys) {
//    print("key: $key");
//    print("key: ${key}");
//  }
//  print('');
//  for(DeclarationMirror val in mirror.declarations.values) {
//    print("val: $val");
//  }
//  print('');
//  for(Symbol key in mirror.instanceMembers.keys) {
//    print("key: $key");
//    print("key: ${key}");
//  }
//  print('');
//  for(MethodMirror val in mirror.instanceMembers.values) {
//    print("val: $val");
//  }
//  print('');
//
//  MethodMirror mm = mirror.instanceMembers[#myList];
//
//  print(mm);
//  print(mm.constructorName);
//  print(mm.returnType.reflectedType);
//  print(mm.returnType.typeArguments);







  /*
  InstanceMirror im = reflect(new ListContainer());
  ClassMirror mirror = im.type;
  TypeMirror tm = mirror.instanceMembers[#myList].returnType;

  print(tm.reflectedType);
  print(tm.typeArguments);

  // How can I create an instance of type [tm.reflectedType] here?
  //.....
  print("");
  */


  // Current suggestion workaround, not optimal, ask users to instantiate typed
  // lists inside their own model objects like [ListContainerWorkaround]
//  InstanceMirror im2 = reflect(new ListContainerWorkaround());
//  ClassMirror cm2 = im2.type;
//  var lcw = cm2.newInstance(new Symbol(''), []).reflectee;
//  InstanceMirror im8 = cm2.newInstance(new Symbol(''), []);
//
//  print('');
//
//  List l = im8.getField(new Symbol('myList')).reflectee;
//  if(l == null) {
//    l = VMMS.listMirrorC.newInstance(new Symbol(''), []).reflectee;
//  }
//
//  print(l.runtimeType);
//  print(l);




/*
  // From the object we create a new mirror on the List<int> that is on the
  // object (instantiate in the class definition). Then use that mirror to
  // create a new List<int> object.
  InstanceMirror im22 = reflect(lcw.myList);
  ClassMirror cm22 = im22.type.superinterfaces[0];
  List<int> myList = cm22.newInstance(new Symbol(''), []).reflectee;

  print(myList.runtimeType);
  print(myList);
*/

//  var lcw1 = new ListContainerWorkaround()..myList.add(1)..myList.add(2);
//  var lcw2 = VaneModel.decode(VaneModel.encode(lcw1), new ListContainerWorkaround());
//
//  print("");
//  print(lcw1.runtimeType);
//  print(lcw1);
//  print(lcw1.myList.runtimeType);
//  print(lcw1.myList);
//  print("");
//  print(lcw2.runtimeType);
//  print(lcw2);
//  print(lcw2.myList.runtimeType);
//  print(lcw2.myList);








/*
  print("Testing of new VaneMode.decode()");
  print('');

  Podo2 p1 = new Podo2()
    ..a = 42
    ..b = 3
    ..c = new List<int>();

  p1.c.add(1);
  p1.c.add(2);

  p1.cc = new Podo3(234)
    ..c = 11111;

  p1.cc.ee.add(new Podo4());
  p1.cc.ee.add(new Podo4());

  print(p1.runtimeType);
  print(p1);
  print(p1.a.runtimeType);
  print(p1.a);
  print('');

  String json = VaneModel.encode(p1);

  print("Json: $json");
  print('');

  Podo2 p2 = VaneModel.decode(json, new Podo2());

  print("");

  print(p2.runtimeType);
  print(p2);
  print(p2.a.runtimeType);
  print(p2.a);
  print(p2.b);

  print(p2.c.runtimeType);
  print(p2.c);

  print(p2.cc.ee.runtimeType);
  print(p2.cc.ee);
  print(p2.cc.ee[0]);
  print(p2.cc.ee[1]);
  */









/*
  List<int> l1 = new List<int>()
      ..add(1)
      ..add(2)
      ..add(3);

  String json = VaneModel.encode(l1);

  print("");
  print("json: $json");
  print("");

//  JSON.decode("Vane as a server side framework");

  List<int> l2 = VaneModel.decode(json, new List<int>());

  print(l2.runtimeType);
  print(l2);
  */


  /*
  QQQQQQ q1 = new QQQQQQ();

//  Map<String, ABC> m1 = new Map<String, ABC>();
//  m1["1"] = 111;
//  m1["2"] = 222;
//  m1["3"] = 333;
  q1.m1["1"] = new ABC()..data = "1111111";
  q1.m1["2"] = new ABC()..data = "22222";
  q1.m1["3"] = new ABC()..data = "333333333";
  q1.m2["aaa"] = "AAAAA";
  q1.m2["bb"] = "BBBB";

  print("");
  print(q1.m1.runtimeType);
  print(q1.m1);
  print(q1.m1["1"]);
  print(q1.m1["2"]);
  print(q1.m1["3"]);
  print("");

//  for(var item in m1.keys) {
//    print(item);
//  }

  String json = VaneModel.encode(q1);
//  String json = JSON.encode(m1);

  print("");
  print("json: $json");
  print("");

  QQQQQQ q2 = VaneModel.decode(json, new QQQQQQ());
//  Map<String, String> m2 = JSON.decode(json);

  print("");
  print(q2.m1.runtimeType);
  print(q2.m1);
  print(q2.m1["1"]);
  print(q2.m1["2"]);
  print(q2.m1["3"]);
  print(q2.m2["aaa"]);
  print(q2.m2["bb"]);
  print("");
*/



  Podo2 p = new Podo2()
    ..a = 42
//    ..myMap = new Map<String, String>()
    ..m1["111"] = "aaaaaa"
    ..m1["222"] = "bbbbbb"
    ..m1["333"] = "cccccc"
    ..m2["AAAAAAAA"] = new Item()
    ..m2["BBBBBBBB"] = new Item()
    ..m2["CCCCCCCC"] = new Item()
    ..b.add(1)
    ..b.add(2)
    ..b.add(3)
//    ..c = new List<Item>()
    ..c.add(new Item())
    ..c.add(new Item())
    ..c.add(new Item());

  print("------------------------------------------------------------");
  print(p);
//  print(p.a);
//  print(p.m1.runtimeType);
//  print(p.m1);
//  print(p.m2.runtimeType);
//  print(p.m2);
//  print(p.b.runtimeType);
//  print(p.b);
//  print(p.c.runtimeType);
//  print(p.c);
  print("------------------------------------------------------------");




  print(VaneModel.transform(new Podo2()));
  print(VaneModel.transform(new Item()));


  print("\n");

  print(VaneModel.encode(p));

  Podo2 p3 = VaneModel.decode(VaneModel.encode(p), new Podo2());
  print("------------------------------------------------------------");
  print(p3);
//  print(p3.a);
//  print(p3.m1.runtimeType);
//  print(p3.m1);
//  print(p3.m2.runtimeType);
//  print(p3.m2);
//  print(p3.b.runtimeType);
//  print(p3.b);
//  print(p3.c.runtimeType);
//  print(p3.c);
  print("------------------------------------------------------------");




//  List model;
//  String json;
//  model.addAll(VaneModel.decode(json, new List<Item>()));
}

class ListItem {
  int row;

  ListItem(this.row);
}

class Podo2 extends VaneModel {
  int a;
  List<int> b = new List<int>();
  List<Item> c = new List<Item>();

  Item myItem = new Item();

  List ddd = [];

  Map<String, String> m1 = new Map<String, String>();
  Map<String, Item> m2 = new Map<String, Item>();
}

class Item extends VaneModel {
  String data = "aaaaa";

  Item();
}



































// TODO: Add better error output for this:
//class BadListModel extends VaneModel {
//  List badList;
//}






class QQQQQQ extends VaneModel {
  Map<String, ABC> m1 = new Map<String, ABC>();
  Map<String, String> m2 = new Map<String, String>();
}

class ABC extends VaneModel {
  String data = "11111111111";
  int int2 = 2;
}

class MapTest extends VaneModel {
  Map<String, String> myMap = new Map<String, String>();
}



class Podo3 extends VaneModel {
  int c;
  Podo4 dd = new Podo4();

//  List<Podo4> ee;
//  List ee = new List();

//  List<Podo4> ee = new List();        // Bad, will generate list of Map
//  List<Podo4> ee = new List<Podo4>(); // Good, will generate list of Podo
//  List ee = new List<Podo4>();        // Okay, will generate list of Podo
//  var ee = new List<Podo4>();         // Works but not recommended

  List<Podo4> ee = new List<Podo4>();

  Podo3(this.c);

  Podo3.model();
}

class Podo4 extends VaneModel {
  int d = 666666666;
}

class ListContainerWorkaround extends VaneModel {
  List<int> myList = new List<int>();
//  List<int> myList;
}





class ListContainer {
  List<int> myList = new List<int>();
}









class PodoContainer extends VaneModel {
  List<PodoChild> pc;
//  List<PodoChild> pc = new List<PodoChild>();
}



class TestClass extends B {
  int value = 42;
}


class AAA extends VaneModel {
  String a = "aaaaaaaaaa";
}




class Podo extends VaneModel {
  String aaa = "111111111";
  String bbb = "222222222";

//  List l0 = new List();
  List l1;

//  List<List> ll;


  List<int> l2 = new List<int>();
  List<PodoChild> l3 = new List<PodoChild>();


//  List<String> l3 = new List<String>();



//  Map m0 = new Map();
//  Map m1 = {"aaa": "111"};
//  Map<String, int> m2 = new Map<String, int>();
//  Map<String, String> m3 = new Map<String, String>();

//  PodoChild c = new PodoChild.model();
}

class PodoChild extends VaneModel {
  String ccccccccccc = "3333333333333";
  String ddddddddddd = "4444444444444";

  PodoChild(this.ccccccccccc);

  PodoChild.model();

//  MiniPodoWithoutDefault a = new MiniPodoWithoutDefault();
}





class MiniPodoWithDefault extends VaneModel {
  String data = "whooooooooot";

  MiniPodoWithDefault(this.data);
//  MiniPodoWithDefault();

  MiniPodoWithDefault.model();
}

class MiniPodoWithoutDefault extends VaneModel {
  String data = "whooooooooot22222";
}






class A {
  String aa = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
  Podo podo235 = new Podo();
}

class Engine {
  bool isRunning = true;
}

class B extends A {
  String bb = "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB";

  Engine engine;

  bool get isEngineRunning => engine.isRunning;

  void set isEngineRunning(bool isRunning) {
    engine.isRunning = isRunning;
  }
}

class C {
  String cc = "CCCCCCCCCCCCCCCCCCCC";
}

//class TestModel extends B with C {
class TestModel extends VaneModel {
  String name;
  int age;
  Podo podo = new Podo();
  MiniPodoWithDefault miniPodoWithDefault = new MiniPodoWithDefault("whoot");
  MiniPodoWithoutDefault miniPodoWithoutDefault = new MiniPodoWithoutDefault();

  List<int> myList = [1,3,4];

  TestModel(this.name, this.age);
//  TestModel();

  TestModel.model();

//  bool useMirrors() => false;
//
//  TestModel fromDocument(Map document) {
//    TestModel This = new TestModel();
//    This.name = document["name"];
//    This.age = document["age"];
//    if(This.myList == null) {
//      This.myList = new List();
//    }
//    This.myList.addAll(document["myList"]);
//    return This;
//  }
//
//  Map toJson() {
//    Map map = new Map();
//    map["name"] = this.name;
//    map["age"] = this.age;
//    map["podo"] = this.podo;
//    map["miniPodoWithDefault"] = this.miniPodoWithDefault;
//    map["miniPodoWithoutDefault"] = this.miniPodoWithoutDefault;
//    map["myList"] = this.myList;
//    return map;
//  }

}



String symbolString(Symbol symbol) {
  return symbol.toString().split('"')[1];
}


// TODO: Does inherience work?? For both encode and decode??? Only decode??




