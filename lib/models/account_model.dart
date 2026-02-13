import 'package:hive/hive.dart';

part 'account_model.g.dart';

@HiveType(typeId: 0)
class Account extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String serviceName;

  @HiveField(2)
  final String username;

  @HiveField(3)
  final String password;

  @HiveField(4)
  final String? notes;

  @HiveField(5)
  final DateTime createdAt;

  Account({
    required this.id,
    required this.serviceName,
    required this.username,
    required this.password,
    this.notes,
    required this.createdAt,
  });
}
