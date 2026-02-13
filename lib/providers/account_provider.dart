import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../database/hive_database.dart';
import 'package:uuid/uuid.dart';

class AccountProvider with ChangeNotifier {
  List<Account> _accounts = [];
  String _searchQuery = '';

  List<Account> get accounts {
    if (_searchQuery.isEmpty) {
      return _accounts;
    }
    return _accounts
        .where((account) =>
            account.serviceName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            account.username.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Future<void> loadAccounts() async {
    final box = HiveDatabase.getAccountBox();
    _accounts = box.values.toList();
    _accounts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  Future<void> addAccount({
    required String serviceName,
    required String username,
    required String password,
    String? notes,
  }) async {
    final newAccount = Account(
      id: const Uuid().v4(),
      serviceName: serviceName,
      username: username,
      password: password,
      notes: notes,
      createdAt: DateTime.now(),
    );

    final box = HiveDatabase.getAccountBox();
    await box.add(newAccount);
    _accounts.insert(0, newAccount);
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> deleteAccount(Account account) async {
    await account.delete();
    _accounts.removeWhere((a) => a.id == account.id);
    notifyListeners();
  }
}
