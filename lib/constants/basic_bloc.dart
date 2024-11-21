

import 'dart:async';

class BasicBloc<T> {
  BasicBloc({this.defaultEvent});

  dynamic defaultEvent;

  StreamController<T> controller = StreamController<T>.broadcast();
  StreamSink<T> get sink=> controller.sink;
  Stream<T> get stream=> controller.stream;


  update() {
    sink.add(defaultEvent);
  }
}