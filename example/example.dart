import 'dart:io';
import 'package:serral/main.dart';

void main() {
  serral(routers: routers);
}

var routers = {
  '/': {
    'GET': getHello,
  },
  '/404': {
    'GET': getApi404,
  },
};

void getApi404(HttpRequest req) {
  req.response.write('404');
  req.response.close();
}

void getHello(HttpRequest req) {
  req.response.write('hello-world');
  req.response.close();
}
