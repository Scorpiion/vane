library vane_elements.vane_view;

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:uri/uri.dart';

import 'package:vane/elements/vane_router/vane_router.dart';

/**
 * A Polymer vane-view element.
 */
@CustomTag('vane-view')
class VaneView extends PolymerElement {
  @published String view = "";
  @published String views = "";
  @published String path = "/";

  // Check documentation to see if "hidden" is a published attribute on PolymerElement?

  /// Constructor used to create instance of VaneView.
  VaneView.created() : super.created() {
    this.hidden = true;
  }

  load(Event event, DetailsElement detail, HtmlElement target) {
    // Do element native click on element
//    target.click();

    String path = target.dataset["path"];

    if(path != null) {
      print("Routing client to new path: ${path}");

      if(History.supportsState == true) {
        // Client support pushState
        window.history.pushState("", "", "${path}");

        // Trigger routing
        VaneRouter.load(path: path);
      } else {
        // Client does not supprt pushState, do a redirect and let vane server
        // help us out (assumed SPA urls are setup in app.yaml)
        window.location.assign("${path}");
      }
    }
  }

  /*
   * Optional lifecycle methods - uncomment if needed.
   */

  /// Called when an instance of vane-view is inserted into the DOM.
  attached() {
    super.attached();
  }

  /// Called when an instance of vane-view is removed from the DOM.
  detached() {
    super.detached();
  }

  /// Called when an attribute (such as  a class) of an instance of
  /// vane-view is added, changed, or removed.
  attributeChanged(String name, String oldValue, String newValue) {
  }

  /// Called when vane-view has been fully prepared (Shadow DOM created,
  /// property observers set up, event listeners attached).
  ready() {
    // Setup route object
    ViewRoute route = new ViewRoute();
    route.name = this.element.name;
    route.hash = this.hashCode;
    route.path = this.path;
    route.views = "${this.views},${this.view}".split(",");
    for(var i = 0; i < route.views.length; i++) {
      route.views[i] = route.views[i].trim();
    }

    // Register route with VaneServe
    if(this.element.name != "vane-view") {
      VaneRouter.viewRegistration.sink.add(route);
    }

    // Listen to routeStream and show/hide when told to by VaneServe
    VaneRouter.routeStream.stream.listen((ViewState state) {
      if(this.element.name == state.name && this.hashCode == state.hash) {
        this.hidden = state.hidden;
      }
    });
  }
}

class ViewRoute extends Comparable {
  String name;
  int hash;
  String path;
  List<String> views;
  bool app;
  UriParser parser;

  int compareTo(ViewRoute other) {
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

