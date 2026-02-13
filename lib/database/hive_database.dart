import 'package:hive_flutter/hive_flutter.dart';
import '../models/account_model.dart';

class HiveDatabase {
  static const String boxName = 'vaultify_accounts';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(AccountAdapter());
    await Hive.openBox<Account>(boxName);
  }

  static Box<Account> getAccountBox() {
    return Hive.box<Account>(boxName);
  }
}
