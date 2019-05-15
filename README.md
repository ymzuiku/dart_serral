# serral

只需要提供一个 router 映射表, 即可启动一个 web 服务

## API

[API Documentation](https://pub.dev/documentation/serral/latest/serral/serral-library.html)

## Getting Started

Example:

```dart
import 'dart:io';
import 'package:serral/main.dart';

void main() async {
  serral(routers: routers);
}

// 一个 routers 映射表
var routers = {
  '/hello': {
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
```
