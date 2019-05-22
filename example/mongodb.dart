import 'package:mongo_dart/mongo_dart.dart';

import 'package:serral/serral.dart';

class MongoCtx with SerralCtx {
  Db db;
}

void main() async {
  Db db = new Db("mongodb://127.0.0.1:27017/test");
  await db.open();

  // Use MongoCtx repeat SerralCtx
  final app = Serral(() => MongoCtx());

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
