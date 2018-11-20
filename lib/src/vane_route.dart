// Copyright (c) 2014, Robert Åkerblom-Andersson <Robert.nr1@gmail.com>

part of vane;

const String _vane = "vane";
const String _podo = "podo";
const String _func = "func";

class _VaneRoute extends Comparable {
  String controller;
  String method;
  String type;
  Route metaRoute;
  UriParser parser;
  List<String> parameters = [];
  List<ClassMirror> pre;
  List<ClassMirror> post;
  ClassMirror classMirror;
  MethodMirror funcMirror;

  int compareTo(other) {
    // Here we use String.compareTo() as a base for our compareTo(). We extend
    // it by replacing "{" with "!" ("!" in particular because of it's low ascii
    // representation, it is below a-z and 0-9 while "{" is above and hence
    // changing the result of the string sort making it so that paths with
    // variables in them gets sorted before those that don't have variables
    // but are similar otherwise. Consider "/users/points" and "/users/{user}",
    // normaly after sort and a reverse on the sorted list (we want longer paths first)
    // "/users/{user}" comes first. With this temp replacment during sort
    // "/users/points" comes before "/users/{user}".
    // Note: It is assumed that a list of routes should first be sorted with
    // the sort function provided here and then after that be reversed to get
    // the right list for url matching.
    return parser.template.template.replaceAll(r'{', "!")
        .compareTo(other.parser.template.template.replaceAll(r'{', "!"));
  }
}

String realname(DeclarationMirror mirror) {
  return mirror.simpleName.toString().split('"')[1];
}

