import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:galileo_framework/galileo_framework.dart';
import 'package:galileo_framework/http.dart';

main() async {
  int x = 0;
  var c = Completer();
  var exit = ReceivePort();
  List<Isolate> isolates = [];

  exit.listen((_) {
    if (++x >= 50) {
      c.complete();
    }
  });

  for (int i = 1; i < Platform.numberOfProcessors; i++) {
    var isolate = await Isolate.spawn(serverMain, null);
    isolates.add(isolate);
    print('Spawned isolate #${i + 1}...');

    isolate.addOnExitListener(exit.sendPort);
  }

  serverMain(null);

  print('Galileo listening at http://localhost:3000');
  await c.future;
}

serverMain(_) async {
  var app = Galileo();
  var http = GalileoHttp.custom(app, startShared, useZone: false); // Run a cluster

  app.get('/', (req, res) {
    return res.serialize({
      "foo": "bar",
      "one": [2, "three"],
      "bar": {"baz": "quux"}
    });
  });

  app.errorHandler = (e, req, res) {
    print(e.message ?? e.error ?? e);
    print(e.stackTrace);
  };

  var server = await http.startServer('127.0.0.1', 3000);
  print('Listening at http://${server.address.address}:${server.port}');
}
