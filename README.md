# serral

[中文文档](./README-CN.md)

Fast backEnd server framework provided by Dart, like Koa. Easy add middleware at before request and after request. Easy extend context Type and values.

## API

[API Documentation](https://pub.dev/documentation/serral/latest/serral/serral-library.html)

## Getting Started

### Create dart project

Create dir and create pubspec.yaml

```sh
$ mkdir your_project && cd your_project
$ touch pubspec.yaml
```

pubspec.yaml:

```
name: your_project
version: 0.0.1
environment:
  sdk: '>=2.3.0 <3.0.0'

dependencies:
  serral: any

```

Install dependencies:

```
$ pub get
```

## Coding your first Serral server

```sh
$ mkdir lib
$ touch lib/main.dart
```

Edit lib/main.dart:

```dart
import 'package:serral/serral.dart';

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

Ok, server is running:s

```
serral runing: http://127.0.0.1:5100
```

## Use mongodb or other driver

Install mongo_dart:

```yaml
dev_dependencies:
  mongo_dart: any
```

### Case 1, save in context:

```dart
import 'package:mongo_dart/mongo_dart.dart';

import 'package:serral/serral.dart';

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
  // use mongodb in some router:
  Db db = ctx.context['db'];
  print(db);
  ctx.send(200, 'hello: ${ctx.context['dog']}');
}
```

### Case 2, mixin SerralCtx

```dart
import 'package:mongo_dart/mongo_dart.dart';

import 'package:serral/serral.dart';

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

### AOT build and AOT runtime

AOT build:

```sh
dart2aot lib/main.dart lib/main.aot
```

use dartaotruntime run it:

```sh
dartaotruntime lib/main.aot
```
