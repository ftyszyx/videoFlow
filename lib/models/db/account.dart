import 'package:hive/hive.dart';
part 'account.g.dart';

@HiveType(typeId: 0)
class Account {
  Account({
    this.id,
    this.name,
    this.token,
  });

  @HiveField(0)
  String? id;

  @HiveField(1)
  String? name;

  @HiveField(2)
  String? token;
}
