library classes;

import 'dart:convert';

import 'package:cs319_assignment_activity1/exceptions/transaction_exceptions.dart';
import 'package:cs319_assignment_activity1/utils/transactions_utils.dart';

export 'package:cs319_assignment_activity1/classes/user.dart';

class User {
  late String? _id;
  late String _pin;
  late double _balance;
  late bool _locked;
  late List<dynamic> _transactions;

  User(String? id, String pin, double? balance, bool? locked, List<dynamic>? transactions) {
    if (id == null) {
      throw Exception("User cannot have a null id value.");
    }

    if (pin.length < 4) {
      throw Exception("A user's pin code must have 4 digits.");
    }
    else if (pin.length > 4) {
      throw Exception("A user's pin code cannot have more than 4 digits.");
    }

    _id = id;
    _pin = pin;
    _balance = balance ?? 0.0;
    _locked = locked ?? false;
    _transactions = transactions ?? [];
  }

  String? get getId => _id;

  String get getPin => _pin;

  set setPin(String pin) {
    _pin = pin;
  }

  double get getBalance => _balance;

  bool get isLocked => _locked;

  set setLocked(bool locked) {
    _locked = locked;
  }

  List<dynamic> get getTransactions => _transactions;

  void addTransaction({required TransactionTypes transactionType, required String timestamp, required String message, double? amount, double? oldBalance, double? newBalance}) {
    _transactions.add("[$timestamp] [${transactionType.name.toUpperCase()}] $message [BALANCE: [${oldBalance ?? getBalance}${newBalance != null ? " -> $newBalance" : ''}]]");
  }

  List<double> deductBalance(double amount) {
    if (_balance < amount) {
      throw OutOfBalanceException("Your balance is less than the amount to be deducted on your account.");
    }

    return [_balance, _balance -= amount];
  }

  List<double> addBalance(double amount) {
    return [_balance, _balance += amount];
  }

  Map<String, dynamic> toJson() {
    return {
      "id": _id,
      "pin": _pin,
      "balance": _balance,
      "locked": _locked,
      "transactions": _transactions
    };
  }
}