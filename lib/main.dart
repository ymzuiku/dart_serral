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

  void sendJson(int statusCode, Map<String, dynamic> obj) {
    response.statusCode = statusCode;
    response.write(jsonEncode(obj));
  }

  Map<String, dynamic> queryPaser([String query]) {
    if (query == null) {
      query = request.uri.query;
    }
    List<String> list = query.split('&');
    Map<String, dynamic> body = {};
    for (var v in list) {
      if (v.contains('=')) {
        body[v] = '';
      } else {
        List<String> sv = v.split('=');
        String key = sv[0];
        sv.removeAt(0);
        body[key] = jsonDecode(sv.join(''));
      }
    }
    return body;
  }

  void close() {
    response.close();
  }
}

/// Serral class
class Serral {
  List<Function> _prefixMiddleware = [];
  List<Function> _suffixMiddleware = [];
  Map<String, Map<String, Function>> _routers = {};
  dynamic initCtx = () {
    return SerralCtx();
  };

  Serral([this.initCtx]);

  void _setRouter(String router, String method, Function fn) {
    if (!_routers.containsKey(router)) {
      _routers[router] = {};
    }
    _routers[router][method] = fn;
  }

  void ANY(String router, Function fn) {
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

  void addCorsHeaders(SerralCtx ctx) {
    ctx.response.headers.add('Access-Control-Allow-Origin', '*');
    ctx.response.headers
        .add('Access-Control-Allow-Methods', 'POST, PUT, DELETE, OPTIONS');
    ctx.response.headers.add('Access-Control-Allow-Headers',
        'Origin, X-Requested-With, Content-Type, Accept');
    ctx.response.headers.add('Cache-control', 'no-cache');
  }

  // start server on port
  void serve({int port}) async {
    var server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    print('serral running: http:127.0.0.1:$port');

    await for (HttpRequest req in server) {
      var ctx = initCtx();
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
