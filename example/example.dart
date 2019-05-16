import 'package:serral/main.dart';

void main() {
  final app = Serral();
  app.serve(port: 5100);

  app.before((SerralCtx req) {
    app.middlewareOfOrigin(req, '*');
  });

  app.before((SerralCtx sr) {
    print(sr.request.uri.toString());
    sr.context['dog'] = 100;
  });

  app.after((SerralCtx sr) {
    print('end');
  });

  app.GET('/', getHome);
  app.POST('/dog', postDog);
}

void getHome(SerralCtx ctx) async {
  ctx.send(200, 'hello: ${ctx.context['dog']}');
}

void postDog(SerralCtx ctx) async {
  print(ctx.body);
  // 模拟异步, 等待 300 ms, 测试 before middleware 是否执行
  await Future.delayed(Duration(milliseconds: 300));
  ctx.send(200, 'order');
}
