# serral

只需要提供一个 router 映射表, 即可启动一个 web 服务

## API

[API Documentation](https://pub.dev/documentation/serral/latest/serral/serral-library.html)

## Getting Started

### Create dart project

Create dir and create pubspec.yaml

```sh
$ mkdir your_project && cd your_project
$ touch pubspec.yaml
```

pubspec.yaml

```
name: your_project
version: 0.0.1
environment:
  sdk: '>=2.3.0 <3.0.0'

dependencies:
  serral: ^0.0.1

dev_dependencies:
  # build_runner: ^1.3
  # build_test: ^0.10.2

```

Install dependencies:

```
$ pub get
```

## Coding

```sh
$ mkdir lib
$ touch lib/main.dart
```

Edit lib/main.dart:

```dart
import 'dart:io';
import 'package:serral/main.dart';

void main() async {
  serral(routers: routers, port: 5100);
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

### Start server

```sh
$ dart lib/main.dart
```

Ok, server is running:

```
serral runing: http://127.0.0.1:5100
```
