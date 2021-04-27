import 'dart:async';

import 'package:galileo_framework/galileo_framework.dart';
import 'package:galileo_configuration/galileo_configuration.dart';
import 'package:file/local.dart';
import 'package:io/ansi.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

Future<void> main() async {
  //Logger.root.onRecord.listen(prettyLog);

  // Note: Set GALILEO_ENV to 'development'
  var app = Galileo(logger: Logger('galileo_configuration'));
  var fileSystem = const LocalFileSystem();

  await app.configure(configuration(
    fileSystem,
    directoryPath: './test/config',
  ));

  test('standalone', () async {
    var config = await loadStandaloneConfiguration(
      fileSystem,
      directoryPath: './test/config',
      onWarning: (msg) {
        print(yellow.wrap('STANDALONE WARNING: $msg'));
      },
    );
    print('Standalone: $config');
    expect(config, {
      'galileo': {'framework': 'cool'},
      'must_be_null': null,
      'artist': 'Timberlake',
      'included': true,
      'merge': {'map': true, 'hello': 'world'},
      'set_via': 'default',
      'hello': 'world',
      'foo': {'version': 'bar'}
    });
  });

  test('obeys included paths', () async {
    expect(app.configuration['included'], true);
  });

  test('can load based on GALILEO_ENV', () async {
    expect(app.configuration['hello'], equals('world'));
    expect(app.configuration['foo']['version'], equals('bar'));
  });

  test('will load default.yaml if exists', () {
    expect(app.configuration['set_via'], equals('default'));
  });

  test('will load .env if exists', () {
    expect(app.configuration['artist'], 'Timberlake');
    expect(app.configuration['galileo'], {'framework': 'cool'});
  });

  test('non-existent environment defaults to null', () {
    expect(app.configuration.keys, contains('must_be_null'));
    expect(app.configuration['must_be_null'], null);
  });

  test('can override GALILEO_ENV', () async {
    await app.configure(configuration(fileSystem, directoryPath: './test/config', overrideEnvironmentName: 'override'));
    expect(app.configuration['hello'], equals('goodbye'));
    expect(app.configuration['foo']['version'], equals('baz'));
  });

  test('merges configuration', () async {
    await app.configure(configuration(fileSystem, directoryPath: './test/config', overrideEnvironmentName: 'override'));
    expect(app.configuration['merge'], {'map': true, 'hello': 'goodbye'});
  });
}
