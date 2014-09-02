// Copyright (c) 2014, Robert Åkerblom-Andersson <Robert@dartvoid.com>

part of vane_http;

abstract class VaneHttp {
  String root = "/rest";
  String resource = "/";
  Map<String, String> _header = new Map<String, String>();

  static Future<Response> get(String resource,
                    {list, map, model,
                    bool validate: true,
                    bool observe: false}) {
    Completer c = new Completer();
    Map<String, String> header = new Map<String, String>();
    BrowserClient http = new BrowserClient();
    String jsonStart;
    String jsonEnd;

    if(list != null) {
      jsonStart = '{"list":';
      jsonEnd = ',"map":{}}';
    } else if(map != null) {
      jsonStart = '{"list":[],"map":';
      jsonEnd = '}';
    } else if(model != null) {
      // OK, at least one paramter was provided
    } else {
      throw("Either a ViewModel has to be provided via one of the named paramters list, map or ob (depending on the type used in the view)");
    }

    http.get('${resource}', headers: header).then((res) {
      if(res.statusCode == 200) {
        // Setup correct model container type
        if(list != null) {
          VaneModel.decode('${jsonStart}${res.body}${jsonEnd}', list, observe: observe);
        } else if(map != null) {
          VaneModel.decode('${jsonStart}${res.body}${jsonEnd}', map, observe: observe);
        } else {
          VaneModel.decode(res.body, model, observe: observe);
        }
      } else {
        print("VaneHttp: HTTP ${res.statusCode}: ${res.reasonPhrase}");
      }

      // Return res
      c.complete(res);
    });

    return c.future;
  }
}

