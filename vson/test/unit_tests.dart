// Copyright (c) 2014, Robert Åkerblom-Andersson <Robert@dartvoid.com>

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:mirrors';

import 'package:unittest/unittest.dart';
import 'package:vson/vson.dart';

void main() {
  test('1. VaneModel.encode(new SimpleModel("Dart", 100))', () {
    SimpleModel a = new SimpleModel("Dart", 100);
    SimpleModel b = VaneModel.decode('{"name":"Dart","age":100}', new SimpleModel.model());

    expect(VaneModel.encode(a), equals('{"name":"Dart","age":100}'));
    expect(a.name, equals(b.name));
    expect(a.age, equals(b.age));
  });

  test('2. VaneModel.decode(VaneModel.encode())', () {
    SimpleModel a = new SimpleModel("Dart", 100);
    SimpleModel b = VaneModel.decode(VaneModel.encode(new SimpleModel("Dart", 100)), new SimpleModel.model());

    expect(a.name, equals(b.name));
    expect(a.age, equals(b.age));
  });

  test('3. VaneModel.encode([new SimpleModel("Dart", 100), new SimpleModel("Dart", 100)])', () {
    expect(VaneModel.encode([new SimpleModel("Dart", 100), new SimpleModel("Dart", 100)]),
        equals('[{"name":"Dart","age":100},{"name":"Dart","age":100}]'));
  });

  test('4. Compare list [..] with decode(encode([..]))', () {
    List<SimpleModel> l1 = new List<SimpleModel>()
      ..add(new SimpleModel("Dart", 100))
      ..add(new SimpleModel("Dart", 100));

    List<SimpleModel> l2 = VaneModel.decode(VaneModel.encode(l1), new List<SimpleModel>());

    for(var i = 0; i < l1.length; i++) {
      expect(l1[i].name, equals(l2[i].name));
      expect(l1[i].age, equals(l2[i].age));
    }
  });

  test('5. VaneModel.decode(VaneModel.encode())', () {
    var t1 = new MyTagClass()
      ..name = "Aaaaaaaaaaaaaaa"
      ..tags.add(new Tag("111111111"))
      ..tags.add(new Tag("222222222"));
    var t2 = VaneModel.decode(VaneModel.encode(t1), new MyTagClass());

    expect(t1.name, equals(t2.name));

    for(var i = 0; i < t1.tags.length; i++) {
      expect(t1.tags[i].tag, equals(t2.tags[i].tag));
      expect(t1.tags[i].selected, equals(t2.tags[i].selected));
    }
  });

  test('6. VaneModel.decode(VaneModel.encode())', () {
    var t1 = new MyTagClass()
      ..name = "Aaaaaaaaaaaaaaa"
      ..tags.add(new Tag("111111111"))
      ..tags.add(new Tag("222222222"));
    var t2 = VaneModel.decode(VaneModel.encode(t1), new MyTagClass());

    expect(t1.name, equals(t2.name));
    for(var i = 0; i < t1.tags.length; i++) {
      expect(t1.tags[i].tag, equals(t2.tags[i].tag));
      expect(t1.tags[i].selected, equals(t2.tags[i].selected));
    }
  });

  test('7. VaneModel.decode(VaneModel.encode())', () {
    var t1 = new MyTagClass()
      ..name = "Aaaaaaaaaaaaaaa"
      ..tags.add(new Tag("111111111"))
      ..tags.add(new Tag("222222222"));

    List<MyTagClass> l0 = new List<MyTagClass>()
        ..add(t1)
        ..add(t1)
        ..add(t1);
    List<MyTagClass> l1 = new List.from(l0);
    List<MyTagClass> l2 = VaneModel.decode(VaneModel.encode(l0), new List<MyTagClass>());

    for(var i = 0; i < l1.length; i++) {
      for(var k = 0; k < l1[i].tags.length; k++) {
        expect(l1[i].tags[k].tag,       equals(l2[i].tags[k].tag));
        expect(l1[i].tags[k].selected,  equals(l2[i].tags[k].selected));
      }
    }
  });

  test('Top level list of String (List<String> data = new List<String>();) ', () {
    var t2 = new StringListTest()
      ..data.add("Vane as a server side framework")
      ..data.add("Pure for CSS");

    expect(VaneModel.encode(t2), equals(VaneModel.encode(VaneModel.decode(VaneModel.encode(t2), new StringListTest.model()))));
  });

  // Tests on basic lists maps of built in Dart types
  group("Testing encode(x), decode(x), encode(decode(encode(x))) on top level", () {
    group("String", () {
      test("List", () {
        List l = new List<String>()
            ..add("Robert")
            ..add("is")
            ..add("testing")
            ..add("list");

        expect(VaneModel.encode(l), equals('["Robert","is","testing","list"]'));
        expect(VaneModel.decode(VaneModel.encode(l), new List<String>()), equals(l));
        expect(VaneModel.encode(VaneModel.decode(VaneModel.encode(l), new List<String>())), equals('["Robert","is","testing","list"]'));
      });

      test("Map", () {
        Map m = new Map<String, String>()
          ..["user"] = "Robert"
          ..["does"] = "testing"
          ..["what"] = "maps";

        expect(VaneModel.encode(m), equals('{"user":"Robert","does":"testing","what":"maps"}'));
        expect(VaneModel.decode(VaneModel.encode(m), new Map<String, String>()), equals(m));
        expect(VaneModel.encode(VaneModel.decode(VaneModel.encode(m), new Map<String, String>())), equals('{"user":"Robert","does":"testing","what":"maps"}'));
      });
    });

    group("Int", () {
      test("List", () {
        List l = new List<int>()
            ..add(1)
            ..add(2)
            ..add(3);

        expect(VaneModel.encode(l), equals('[1,2,3]'));
        expect(VaneModel.decode(VaneModel.encode(l), new List<int>()), equals(l));
        expect(VaneModel.encode(VaneModel.decode(VaneModel.encode(l), new List<int>())), equals('[1,2,3]'));
      });

      test("Map", () {
        Map m = {"1": 1, "2": 2, "3": 3};

        expect(VaneModel.encode(m), equals('{"1":1,"2":2,"3":3}'));
        expect(VaneModel.decode(VaneModel.encode(m), new Map()), equals(m));
        expect(VaneModel.encode(VaneModel.decode(VaneModel.encode(m), new Map())), equals('{"1":1,"2":2,"3":3}'));
      });
    });

    group("Double", () {
      test("List", () {
        List l = new List<double>()
            ..add(1.33)
            ..add(2.66)
            ..add(3.99);

        expect(VaneModel.encode(l), equals('[1.33,2.66,3.99]'));
        expect(VaneModel.decode(VaneModel.encode(l), new List<double>()), equals(l));
        expect(VaneModel.encode(VaneModel.decode(VaneModel.encode(l), new List<double>())), equals('[1.33,2.66,3.99]'));
      });

      test("Map", () {
        Map m = {"1.33": 1.33, "2.66": 2.66, "3.99": 3.99};

        expect(VaneModel.encode(m), equals('{"1.33":1.33,"2.66":2.66,"3.99":3.99}'));
        expect(VaneModel.decode(VaneModel.encode(m), new Map()), equals(m));
        expect(VaneModel.encode(VaneModel.decode(VaneModel.encode(m), new Map())), equals('{"1.33":1.33,"2.66":2.66,"3.99":3.99}'));
      });
    });

    group("Bool", () {
      test("List", () {
        List l = new List<bool>()
            ..add(true)
            ..add(false)
            ..add(true);

        expect(VaneModel.encode(l), equals('[true,false,true]'));
        expect(VaneModel.decode(VaneModel.encode(l), new List<bool>()), equals(l));
        expect(VaneModel.encode(VaneModel.decode(VaneModel.encode(l), new List<bool>())), equals('[true,false,true]'));
      });

      test("Map", () {
        Map m = {"true": true, "false": false, "true2": true};

        expect(VaneModel.encode(m), equals('{"true":true,"false":false,"true2":true}'));
        expect(VaneModel.decode(VaneModel.encode(m), new Map()), equals(m));
        expect(VaneModel.encode(VaneModel.decode(VaneModel.encode(m), new Map())), equals('{"true":true,"false":false,"true2":true}'));
      });
    });
  });

  // TODO: For this to work [MyPrivate] needs to be declared in a different
  // lib, now when it's in the same lib private members are include and the
  // should be. To public/private members different lib are needed.
//  test('Public/private members', () {
//    MyPrivate mp = new MyPrivate()
//      ..pubName = "Robert"
//      .._priName = "The One";
//
//    expect(VaneModel.encode(mp), equals('{"pubName":"Robert"}'));
//  });
}





class MyPrivate extends VaneModel {
  String pubName;
  String _priName;

  MyPrivate();

  MyPrivate.model();

  MyPrivate.fromJson(Map json) {
    pubName = json["pubName"];
  }

  Map toJson() {
    return {
      "pubName": pubName
    };
  }
}

class SimpleModel extends VaneModel {
  String name;
  int age;

  SimpleModel(this.name, this.age);

  SimpleModel.model();
}

class SimpleModel3 extends VaneModel {
  String name;
  int age;

//  List myList = [1,2,3,4,5];
//  List<int> myIntList = [1,2,3,4,5];
//  List<String> myStringList = ["aaa", "bbb", "ccc"];
//  List<Podo> podoList = [new Podo(), new Podo(), new Podo()];

  Map myMap = {"key": "value"};
  Map<String, int> myIntMap = {"key": 1};

//  Podo podo = new Podo();

  SimpleModel3(this.name, this.age);

  SimpleModel3.model();
}



class MyTagClass extends VaneModel {
  String name;
  Tag superTag = new Tag("9999999999");
  List<Tag> tags = new List<Tag>();

  MyTagClass();

  MyTagClass.model();
}

class Tag extends VaneModel {
  String tag;
  bool selected;

  Tag(this.tag, [this.selected = false]);

  Tag.model();
}

class StringListTest extends VaneModel {
  List<String> data = new List<String>();

  StringListTest();

  StringListTest.model();
}




// TODO: Add values of type "double" to tests.....


