library serral;

import 'dart:io';

void serral({Map<String, dynamic> routers, int port = 5100}) async {
  var server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);

  print('serral runing: http://127.0.0.1:$port');

  await for (HttpRequest req in server) {
    var uri = req.uri.toString();

    // 带 . 的路径一般是文件路径, 不进行路由判断
    if (uri.indexOf('.') < 0) {
      if (routers.containsKey(uri) && routers[uri].containsKey(req.method)) {
        routers[uri][req.method](req);
      } else if (routers.containsKey('/404')) {
        if (routers['/404'].containsKey('GET')) {
          routers['/404']['GET'](req);
        }
      }
    }
  }
}
