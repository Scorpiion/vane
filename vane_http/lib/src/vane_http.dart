// Copyright (c) 2014, Robert Åkerblom-Andersson <Robert.nr1@gmail.com>

part of vane_http;

abstract class VaneHttp {
  static Future get(String resource, Object model,
                   {bool validate: true, bool observe: false}) {
    Completer c = new Completer();
    Map<String, String> header = new Map<String, String>();
    BrowserClient http = new BrowserClient();

    http.get('${resource}', headers: header).then((res) {
      if(res.statusCode == 200) {
        c.complete(VaneModel.decode(res.body, model, observe: observe));
      } else {
        print("VaneHttp: HTTP ${res.statusCode}: ${res.reasonPhrase}");

        // Return object since it can be assigned to most things
        c.complete(new Object());
      }
    });

    return c.future;
  }
}

