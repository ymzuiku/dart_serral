library serral;

import 'dart:convert';

import 'dart:io';

/// Serral context
class SerralCtx {
  HttpRequest request;
  Map<String, dynamic> context = {};
  Map<String, dynamic> params = {};
  Map<String, dynamic> body = {};
  String bodyData;
  HttpResponse response;
  void send(int statusCode, Object obj) {
    response.statusCode = statusCode;
    response.write(obj);
  }

  void close() {
    response.close();
  }
}

/// Serral class
class Serral {
  List<Function(SerralCtx)> _prefixMiddleware = [];
  List<Function(SerralCtx)> _suffixMiddleware = [];
  Map<String, Map<String, Function>> _routers = {};
  void _setRouter(String router, String method, Function(SerralCtx) fn) {
    if (!_routers.containsKey(router)) {
      _routers[router] = {};
    }
    _routers[router][method] = fn;
  }

  void use(String router, Function fn) {
    _setRouter(router, 'ANY', fn);
  }

  void GET(String router, Function fn) {
    _setRouter(router, 'GET', fn);
  }

  void POST(String router, Function fn) {
    _setRouter(router, 'POST', fn);
  }

  void PUT(String router, Function fn) {
    _setRouter(router, 'PUT', fn);
  }

  void DELETE(String router, Function fn) {
    _setRouter(router, 'DELETE', fn);
  }

  void TRACE(String router, Function fn) {
    _setRouter(router, 'TRACE', fn);
  }

  void CONNECT(String router, Function fn) {
    _setRouter(router, 'CONNECT', fn);
  }

  void HEAD(String router, Function fn) {
    _setRouter(router, 'HEAD', fn);
  }

  void OPTIONS(String router, Function fn) {
    _setRouter(router, 'OPTIONS', fn);
  }

  /// before router runing
  void before(fn) {
    _prefixMiddleware.add(fn);
  }

  /// after router runing
  void after(fn) {
    _suffixMiddleware.add(fn);
  }

  void middlewareOfOrigin(SerralCtx ctx, [String value = '*']) {
    ctx.response.headers.set('Access-Control-Allow-Origin', value);
  }

  void middlewareOfHeaderDefault(SerralCtx ctx) {
    ctx.response.headers
        .set('Access-Control-Expose-Headers', 'Authorization, Content-Type');
    ctx.response.headers.set('Access-Control-Allow-Headers',
        'Authorization, Origin, X-Requested-With, Content-Type, Accept');
    ctx.response.headers
        .set('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE');
  }

  // start server on port
  void serve({int port}) async {
    var server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    print('serral running: http:127.0.0.1:$port');

    await for (HttpRequest req in server) {
      var ctx = SerralCtx();
      ctx.request = req;
      ctx.response = req.response;
      ctx.params = req.uri.queryParameters;

      for (final fn in _prefixMiddleware) {
        fn(ctx);
      }

      if (req.method != 'GET') {
        final String content = await req.transform(utf8.decoder).join();
        ctx.bodyData = content;
        if (req.headers.contentType?.mimeType == 'application/json') {
          ctx.body = jsonDecode(content);
        } else {
          List<String> list = ctx.bodyData.split('&');
          for (var v in list) {
            List<String> sv = v.split('=');
            ctx.body[sv[0]] = jsonDecode(sv[1]);
          }
        }
      }

      if (_routers.containsKey(req.uri.path)) {
        if (_routers[req.uri.path].containsKey(req.method)) {
          await _routers[req.uri.path][req.method](ctx);
        } else if (_routers[req.uri.path].containsKey('ANY')) {
          await _routers[req.uri.path]['ANY'](ctx);
        }
      }

      for (var fn in _suffixMiddleware) {
        await fn(ctx);
      }

      req.response.close();
    }
  }
}
