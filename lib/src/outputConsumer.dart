// Copyright (c) 2014, Robert Åkerblom-Andersson <Robert@dartvoid.com>

part of vane;

class _OutputConsumer<S> implements StreamConsumer<S> {
  Completer _c = new Completer();
  List<S> _data;
  int _length;
  StreamSubscription _sub;
  
  Future<S> addStream(Stream<S> stream) {
    _sub = stream.listen(null);
    _data = <S>[];
    _length = 0;
    
    _sub.onData((data) {
      _data.add(data);
      _length += data.length; 
    });
    
    _sub.onError((err) {
      // Do something here?
      print("Error in streamConsumer");
    });
    
    _sub.onDone(() {
      // Do something here?
    });
    
    return _c.future;
  }
  
  Future<S> close() {
    // If nothing has been written _sub is null
    if(_sub != null) {
      _sub.cancel().then((_) => _c.complete());
    } else {
      _c.complete();
    }
    
    return _c.future;      
  }
}

