import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:galileo_container/galileo_container.dart';
import 'package:galileo_framework/http.dart';
import 'package:galileo_container/mirrors.dart';
import 'package:galileo_framework/galileo_framework.dart';
import 'package:http/http.dart' as http;
import 'package:galileo_mock_request/galileo_mock_request.dart';
import 'package:test/test.dart';

import 'common.dart';

final String TEXT = "make your bed";
final String OVER = "never";

main() {
  Galileo app;
  http.Client client;
  HttpServer server;
  String url;

  setUp(() async {
    app = Galileo(reflector: MirrorsReflector());
    client = http.Client();

    // Inject some todos
    app.container.registerSingleton(Todo(text: TEXT, over: OVER));
    app.container.registerFactory<Future<Foo>>((container) async {
      var req = container.make<RequestContext>();
      var text = await utf8.decoder.bind(req.body).join();
      return Foo(text);
    });

    app.get("/errands", ioc((Todo singleton) => singleton));
    app.get("/errands3", ioc(({Errand singleton, Todo foo, RequestContext req}) => singleton.text));
    app.post('/async', ioc((Foo foo) => {'baz': foo.bar}));
    await app.configure(SingletonController().configureServer);
    await app.configure(ErrandController().configureServer);

    server = await GalileoHttp(app).startServer();
    url = "http://${server.address.host}:${server.port}";
  });

  tearDown(() async {
    app = null;
    url = null;
    client.close();
    client = null;
    await server.close(force: true);
  });

  test('runContained with custom container', () async {
    var app = Galileo();
    var c = Container(const MirrorsReflector());
    c.registerSingleton(Todo(text: 'Hey!'));

    app.get('/', (req, res) async {
      return app.runContained((Todo t) => t.text, req, res, c);
    });

    var rq = MockHttpRequest('GET', Uri(path: '/'));
    await rq.close();
    var rs = rq.response;
    await GalileoHttp(app).handleRequest(rq);
    var text = await rs.transform(utf8.decoder).join();
    expect(text, json.encode('Hey!'));
  });

  test("singleton in route", () async {
    validateTodoSingleton(await client.get(Uri.parse("$url/errands")));
  });

  test("singleton in controller", () async {
    validateTodoSingleton(await client.get(Uri.parse("$url/errands2")));
  });

  test("make in route", () async {
    var response = await client.get(Uri.parse("$url/errands3"));
    var text = await json.decode(response.body) as String;
    expect(text, equals(TEXT));
  });

  test("make in controller", () async {
    var response = await client.get(Uri.parse("$url/errands4"));
    var text = await json.decode(response.body) as String;
    expect(text, equals(TEXT));
  });

  test('resolve from future in controller', () async {
    var response = await client.post(Uri.parse('$url/errands4/async'), body: 'hey');
    expect(response.body, json.encode({'bar': 'hey'}));
  });

  test('resolve from future in route', () async {
    var response = await client.post(Uri.parse('$url/async'), body: 'yes');
    expect(response.body, json.encode({'baz': 'yes'}));
  });
}

void validateTodoSingleton(response) {
  var todo = json.decode(response.body.toString()) as Map;
  expect(todo["id"], equals(null));
  expect(todo["text"], equals(TEXT));
  expect(todo["over"], equals(OVER));
}

@Expose("/errands2")
class SingletonController extends Controller {
  @Expose("/")
  todo(Todo singleton) => singleton;
}

@Expose("/errands4")
class ErrandController extends Controller {
  @Expose("/")
  errand(Errand errand) {
    return errand.text;
  }

  @Expose('/async', method: 'POST')
  asyncResolve(Foo foo) {
    return {'bar': foo.bar};
  }
}

class Foo {
  final String bar;

  Foo(this.bar);
}

class Errand {
  Todo todo;

  String get text => todo.text;

  Errand(this.todo);
}
