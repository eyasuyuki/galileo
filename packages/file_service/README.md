# file_service
[![Pub](https://img.shields.io/pub/v/galileo_file_service.svg)](https://pub.dartlang.org/packages/galileo_file_service)
[![build status](https://travis-ci.org/galileo-dart/file_service.svg)](https://travis-ci.org/galileo-dart/file_service)

galileo service that persists data to a file on disk, stored as a JSON list. It uses a simple
mutex to prevent race conditions, and caches contents in memory until changes
are made.

The file will be created on read/write, if it does not already exist.

This package is useful in development, as it prevents you from having to install
an external database to run your server.

When running a multi-threaded server, there is no guarantee that file operations
will be mutually excluded. Thus, try to only use this one a single-threaded server
if possible, or one with very low load.

While not necessarily *slow*, this package makes no promises about performance.

# Usage
```dart
configureServer(galileo app) async {
  // Just like a normal service
  app.use(
    '/api/todos',
    new JsonFileService(
      const LocalFileSystem().file('todos_db.json')
    ),
  );
}
```
