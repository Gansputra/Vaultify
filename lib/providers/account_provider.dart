import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../database/hive_database.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

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
    required String category,
  }) async {
    final newAccount = Account(
      id: const Uuid().v4(),
      serviceName: serviceName,
      username: username,
      password: password,
      notes: notes,
      createdAt: DateTime.now(),
      category: category,
    );

    final box = HiveDatabase.getAccountBox();
    await box.add(newAccount);
    _accounts.insert(0, newAccount);
    notifyListeners();
  }

  Future<void> updateAccountCategory(Account account, String newCategory) async {
    account = _accounts.firstWhere((a) => a.id == account.id);
    // Since Account extends HiveObject, we can update and save
    final box = HiveDatabase.getAccountBox();
    final index = box.values.toList().indexWhere((a) => a.id == account.id);
    
    if (index != -1) {
      final updatedAccount = Account(
        id: account.id,
        serviceName: account.serviceName,
        username: account.username,
        password: account.password,
        notes: account.notes,
        createdAt: account.createdAt,
        category: newCategory,
      );
      await box.putAt(index, updatedAccount);
      _accounts[_accounts.indexWhere((a) => a.id == account.id)] = updatedAccount;
      notifyListeners();
    }
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

  Future<void> clearAllAccounts() async {
    final box = HiveDatabase.getAccountBox();
    await box.clear();
    _accounts.clear();
    notifyListeners();
  }

  Future<String?> exportBackup() async {
    if (_accounts.isEmpty) return 'empty';

    try {
      final List<Map<String, dynamic>> jsonData = 
          _accounts.map((a) => a.toJson()).toList();
      
      final String jsonString = jsonEncode(jsonData);
      
      final directory = await getTemporaryDirectory();
      final String filePath = '${directory.path}/vaultify_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final File file = File(filePath);
      
      await file.writeAsString(jsonString);
      
      await Share.shareXFiles([XFile(filePath)], text: 'Vaultify Backup Data');
      return 'success';
    } catch (e) {
      return 'error: $e';
    }
  }

  Future<String> importBackup() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null) return 'cancelled';

      final File file = File(result.files.single.path!);
      final String content = await file.readAsString();
      final List<dynamic> jsonData = jsonDecode(content);

      final box = HiveDatabase.getAccountBox();
      int importedCount = 0;

      for (var item in jsonData) {
        final account = Account.fromJson(item as Map<String, dynamic>);
        
        // Check if ID already exists to avoid duplicates
        bool exists = _accounts.any((a) => a.id == account.id);
        if (!exists) {
          await box.add(account);
          _accounts.add(account);
          importedCount++;
        }
      }

      if (importedCount > 0) {
        _accounts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        notifyListeners();
        return 'Imported $importedCount accounts successfully';
      } else {
        return 'No new accounts found in backup';
      }
    } catch (e) {
      return 'Error importing: $e';
    }
  }
}
