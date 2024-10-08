

import 'dart:async';

class BasicBloc<T> {

  StreamController<T> controller = StreamController<T>.broadcast();
  StreamSink<T> get sink=> controller.sink;
  Stream<T> get stream=> controller.stream;

}