# serral

[English Documentation](./README.md)

- 完全基于 Dart 的, 快速的后端 Server 框架, 使用方式接近 Koa.
- 轻松设置请求前和请求后的 middleware.
- 轻松扩展 Context 的类型或者值, 已满足绝大部分 Web 服务器的需求

## API

[API 文档](https://pub.dev/documentation/serral/latest/serral/serral-library.html)

## 开始

### 创建一个 Dart 项目

创建一个文件夹, 并且创建一个 pubspec.yaml 文件

```sh
$ mkdir your_project && cd your_project
$ touch pubspec.yaml
```

pubspec.yaml 文件内容:

```yaml
name: your_project
version: 0.0.1
environment:
  sdk: '>=2.3.0 <3.0.0'

dependencies:
  serral: any
```

安装依赖:

```
$ pub get
```

## 编写你的第一个 Serral 服务

```sh
$ mkdir lib
$ touch lib/main.dart
```

编辑 lib/main.dart:

```dart
import 'package:serral/main.dart';

void main() {
  final app = Serral();

  // 默许跨域
  app.before(app.addCorsHeaders);

  // 添加前置中间键
  app.before((SerralCtx ctx) {
    print(ctx.request.uri.toString());
    ctx.context['dog'] = 100;
  });

  // 添加后置中间键
  app.after((SerralCtx ctx) {
    print('end');
  });

  // 捕获某个路径的请求
  app.GET('/', getHome);
  app.POST('/dog', postDog);

  app.serve(port: 5100);
}

// 实现该 GET 路由
void getHome(SerralCtx ctx) async {
  // 读取 ctx.context, 检查前置中间键是否生效
  print(ctx.context['dog']);
  // 查看请求路径参数
  print(ctx.params);
  ctx.send(200, 'hello: ${ctx.context['dog']}');
}

// 实现该 POST 路由
void postDog(SerralCtx ctx) async {
  // 查看 post 请求的 body
  print(ctx.body);
  // 模拟异步, 检查后置中间键是否生效
  await Future.delayed(Duration(milliseconds: 300));
  ctx.send(200, 'order');
}
```

### 启动服务

```sh
$ dart lib/main.dart
```

好了, 服务已经启动:

```
serral runing: http://127.0.0.1:5100
```

## 如何使用 Mongodb 或其他数据驱动

安装 mongo_dart:

```yaml
dev_dependencies:
  mongo_dart: any
```

### 方案 1, 利用 context 存储驱动:

编写代码

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
  // 在请求响应中使用 db 对象
  Db db = ctx.context['db'];
  print(db);
  ctx.send(200, 'hello: ${ctx.context['dog']}');
}
```

### 方案 2, 使用 mixin 扩展 SerralCtx:

```dart
import 'package:mongo_dart/mongo_dart.dart';

import 'package:serral/main.dart';

// mixin 扩展 SerralCtx 来添加各种所需的对象
class MongoCtx with SerralCtx {
  Db db;
}

void main() async {
  Db db = new Db("mongodb://127.0.0.1:27017/test");
  await db.open();

  // 使用 MongoCtx 替换 SerralCtx 作为上下文
  final app = Serral(()=> MongoCtx());

  app.before((MongoCtx ctx) {
    // 在请求前置的中间键存储 db 对象的引用
    ctx.db = db;
  });

  app.GET('/', getHome);

  app.serve(port: 5100);
}

void getHome(MongoCtx ctx) async {
  // 在请求响应中使用 db 对象
  print(ctx.db);
  ctx.send(200, 'hello: ${ctx.context['dog']}');
}
```

### AOT 编译及部署

接下来我们要 DartVM 的性能, 我们将 source-code 进行 AOT 编译, AOT 编译后相对于 source-code 可以提升一个数量级或以上的性能:

AOT 编译:

```sh
dart2aot lib/main.dart lib/main.aot
```

使用 dartaotruntime 启动生产版本:

```sh
dartaotruntime lib/main.aot
```
