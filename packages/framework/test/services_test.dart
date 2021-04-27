import 'package:galileo_container/mirrors.dart';
import 'package:galileo_framework/galileo_framework.dart';
import 'package:galileo_framework/http.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stack_trace/stack_trace.dart';
import 'package:test/test.dart';

class Todo extends Model {
  String text;
  String over;
}

main() {
  Map headers = <String, String>{'Accept': 'application/json', 'Content-Type': 'application/json'};
  Galileo app;
  MapService service;
  String url;
  http.Client client;

  setUp(() async {
    app = Galileo(reflector: MirrorsReflector())
      ..use('/todos', service = MapService())
      ..errorHandler = (e, req, res) {
        if (e.error != null) print('Whoops: ${e.error}');
        if (e.stackTrace != null) print(Chain.forTrace(e.stackTrace).terse);
      };

    var server = await GalileoHttp(app).startServer();
    client = http.Client();
    url = "http://${server.address.host}:${server.port}";
  });

  tearDown(() async {
    await app.close();
    app = null;
    url = null;
    client.close();
    client = null;
  });

  group('memory', () {
    test('can index an empty service', () async {
      var response = await client.get(Uri.parse("$url/todos/"));
      print(response.body);
      expect(response.body, equals('[]'));
      print(response.body);
      expect(json.decode(response.body).length, 0);
    });

    test('can create data', () async {
      String postData = json.encode({'text': 'Hello, world!'});
      var response =
          await client.post(Uri.parse("$url/todos"), headers: headers as Map<String, String>, body: postData);
      expect(response.statusCode, 201);
      var jsons = json.decode(response.body);
      print(jsons);
      expect(jsons['text'], equals('Hello, world!'));
    });

    test('can fetch data', () async {
      String postData = json.encode({'text': 'Hello, world!'});
      await client.post(Uri.parse("$url/todos"), headers: headers as Map<String, String>, body: postData);
      var response = await client.get(Uri.parse("$url/todos/0"));
      expect(response.statusCode, 200);
      var jsons = json.decode(response.body);
      print(jsons);
      expect(jsons['text'], equals('Hello, world!'));
    });

    test('can modify data', () async {
      String postData = json.encode({'text': 'Hello, world!'});
      await client.post(Uri.parse("$url/todos"), headers: headers as Map<String, String>, body: postData);
      postData = json.encode({'text': 'modified'});

      var response =
          await client.patch(Uri.parse("$url/todos/0"), headers: headers as Map<String, String>, body: postData);
      expect(response.statusCode, 200);
      var jsons = json.decode(response.body);
      print(jsons);
      expect(jsons['text'], equals('modified'));
    });

    test('can overwrite data', () async {
      String postData = json.encode({'text': 'Hello, world!'});
      await client.post(Uri.parse("$url/todos"), headers: headers as Map<String, String>, body: postData);
      postData = json.encode({'over': 'write'});

      var response =
          await client.post(Uri.parse("$url/todos/0"), headers: headers as Map<String, String>, body: postData);
      expect(response.statusCode, 200);
      var jsons = json.decode(response.body);
      print(jsons);
      expect(jsons['text'], equals(null));
      expect(jsons['over'], equals('write'));
    });

    test('readMany', () async {
      var items = <Map>[
        await service.create({'foo': 'bar'}),
        await service.create({'bar': 'baz'}),
        await service.create({'baz': 'quux'})
      ];

      var ids = items.map((m) => m['id'] as String).toList();
      expect(await service.readMany(ids), items);
    });

    test('can delete data', () async {
      String postData = json.encode({'text': 'Hello, world!'});
      var created = await client
          .post(Uri.parse("$url/todos"), headers: headers as Map<String, String>, body: postData)
          .then((r) => json.decode(r.body));
      var response = await client.delete(Uri.parse("$url/todos/${created['id']}"));
      expect(response.statusCode, 200);
      var json_ = json.decode(response.body);
      print(json_);
      expect(json_['text'], equals('Hello, world!'));
    });

    test('cannot remove all unless explicitly set', () async {
      var response = await client.delete(Uri.parse('$url/todos/null'));
      expect(response.statusCode, 403);
    });
  });
}
