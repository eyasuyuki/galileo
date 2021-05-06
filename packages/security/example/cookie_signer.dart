import 'dart:io';
import 'dart:math';
import 'package:galileo_framework/galileo_framework.dart';
import 'package:galileo_framework/http.dart';
import 'package:galileo_security/galileo_security.dart';
import 'package:logging/logging.dart';
import 'package:galileo_pretty_logging/galileo_pretty_logging.dart';

void main() async {
  // Logging boilerplate.
  Logger.root.onRecord.listen(prettyLog);

  // Create an app, and HTTP driver.
  var app = Galileo(logger: Logger('cookie_signer')), http = GalileoHttp(app);

  // Create a cookie signer. Uses an SHA256 Hmac by default.
  var signer = CookieSigner.fromStringKey('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789ab');

  // When a user visits /getid, give them a (signed) uniqid cookie.
  // When they visit /cookies, print their verified cookies.
  var rnd = Random.secure();

  // Endpoint to give a signed cookie.
  app.get('/getid', (req, res) {
    // Write the uniqid cookie.
    var uniqid = rnd.nextInt(65536);
    signer.writeCookie(res, Cookie('uniqid', uniqid.toString()));

    // Send a response.
    res.write('uniqid=$uniqid');
  });

  // Endpoint to dump all verified cookies.
  //
  // The [onInvalidCookie] callback is optional, but
  // here we will use it to log invalid cookies.
  app.get('/cookies', (req, res) {
    var verifiedCookies = signer.readCookies(req, onInvalidCookie: (cookie) {
      app.logger.warning('Invalid cookie: $cookie');
    });
    res.writeln('${verifiedCookies.length} verified cookie(s)');
    res.writeln('${req.cookies.length} total unverified cookie(s)');
    for (var cookie in verifiedCookies) {
      res.writeln('${cookie.name}=${cookie.value}');
    }
  });

  // 404 otherwise.
  app.fallback(
      (req, res) => throw GalileoHttpException.notFound(message: 'The only valid endpoints are /getid and /cookies.'));

  // Start the server.
  await http.startServer('127.0.0.1', 3000);
  print('Cookie signer example listening at ${http.uri}');
}
