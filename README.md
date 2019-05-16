# serral

Dart tiny web framework, like KoaFast and productive web server framework provided by Dart, like Koa. Easy add middleware at before request and after request. Easy extend context Type and values.

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
  serral: any

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
import 'package:serral/main.dart';

void main() {
  final app = Serral();

  // open cros
  app.before(app.addCorsHeaders);

  app.before((SerralCtx ctx) {
    print(ctx.request.uri.toString());
    ctx.context['dog'] = 100;
  });

  app.after((SerralCtx ctx) {
    print('end');
  });

  app.GET('/', getHome);
  app.POST('/dog', postDog);

  app.serve(port: 5100);
}

void getHome(SerralCtx ctx) async {
  // read ctx.context, check app.before;
  print(ctx.context['dog']);
  ctx.send(200, 'hello: ${ctx.context['dog']}');
}

void postDog(SerralCtx ctx) async {
  print(ctx.body);
  // use Futrue, check app.after;
  await Future.delayed(Duration(milliseconds: 300));
  ctx.send(200, 'order');
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

## Use mongodb or other driver

### Case 1: save in context:

After install mongo_dart:

```dart
import 'package:mongo_dart/mongo_dart.dart';

import 'package:serral/main.dart';

void main() async {
  Db db = new Db("mongodb://127.0.0.1:27017/test");
  await db.open();

  final app = Serral();

  app.before((SerralCtx ctx) {
    // add mongodb in context
    ctx.context['db'] = db;
  });

  app.GET('/', getHome);

  app.serve(port: 5100);
}

void getHome(SerralCtx ctx) async {
  Db db = ctx.context['db'];
  // use mongodb in some router:
  print(db);
  ctx.send(200, 'hello: ${ctx.context['dog']}');
}
```

### Case 2: mixin SerralCtx

```dart
import 'package:mongo_dart/mongo_dart.dart';

import 'package:serral/main.dart';

class MongoCtx with SerralCtx {
  Db db;
}

void main() async {
  Db db = new Db("mongodb://127.0.0.1:27017/test");
  await db.open();

  // Use MongoCtx repeat SerralCtx
  final app = Serral(()=> MongoCtx());

  app.before((MongoCtx ctx) {
    // save db at MongodbCtx.db
    ctx.db = db;
  });

  app.GET('/', getHome);

  app.serve(port: 5100);
}

void getHome(MongoCtx ctx) async {
  // use mongodb in some router:
  print(ctx.db);
  ctx.send(200, 'hello: ${ctx.context['dog']}');
}
```
