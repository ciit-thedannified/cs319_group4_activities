library utils;

import 'dart:io';

import 'package:cs319_group4_activities/utils/transactions_ui.dart';

import '../exceptions/transaction_exceptions.dart';
import '../classes/user.dart';

export '../utils/transactions_utils.dart';

const String exitCodeCommand = "X";

enum TransactionTypes {
  balanceInquiry(
    name: "Balance Inquiry",
    debit: false,
    code: "1",
  ), // Koji
  withdrawCash(
    name: "Withdraw Cash",
    debit: true,
    code: "2",
  ), // Cedric
  transferMoney(
    name: "Transfer Money",
    debit: true,
    code: "3",
  ),
  changePinCode(
    name: "Change PIN Code",
    debit: false,
    code: "4",
  ),  // Cedric
  payBills(
    name: "Pay Bills",
    debit: true,
    code: "5",
  ),
  depositMoney(
    name: "Deposit Money",
    debit: false,
    code: "6",
  ); // Koji

  const TransactionTypes({
    required this.name,
    required this.debit,
    required this.code,
  });

  final String name;
  final bool debit;
  final String code;
}

void depositCash({required User user, required double amount}) {
  var txTime = DateTime.now().toLocal();
  var message = "You deposited $amount to your account.";
  double oldBalance, newBalance;

  [oldBalance, newBalance] = user.addBalance(amount);

  printSuccessMessage(
    transactionType: TransactionTypes.depositMoney,
    datetime: txTime.toString(),
    success: message,
    oldBalance: oldBalance,
    newBalance: newBalance
  );

  user.addTransaction(
    transactionType: TransactionTypes.depositMoney,
    timestamp: txTime.toString(),
    message: message,
    oldBalance: oldBalance,
    newBalance: newBalance
  );
}

bool transferMoney({required List<User> users, required User sender, required String? recipientId, required double amount}) {
  var txTime = DateTime.now().toLocal();
  double senderOldBalance, senderNewBalance;
  double recipientOldBalance, recipientNewBalance;
  User? targetUser;

  bool commit = true;

  try {
    targetUser = users.firstWhere((user) => user.getId == recipientId);

    [senderOldBalance, senderNewBalance] = sender.deductBalance(amount);
    [recipientOldBalance, recipientNewBalance] = targetUser.addBalance(amount);

    sender.addTransaction(
      transactionType: TransactionTypes.transferMoney,
      timestamp: txTime.toString(),
      message: "Transferred $amount to {User ID: ${targetUser.getId}}",
      oldBalance: senderOldBalance,
      newBalance: senderNewBalance,
    );

    targetUser.addTransaction(
        transactionType: TransactionTypes.transferMoney,
        timestamp: txTime.toString(),
        message: "Received $amount from {User ID: ${sender.getId}}",
        oldBalance: recipientOldBalance,
        newBalance: recipientNewBalance
    );

    printSuccessMessage(
      transactionType: TransactionTypes.transferMoney,
      datetime: txTime.toString(),
      success: "Transferred $amount to {User ID: ${targetUser.getId}}.",
      oldBalance: senderOldBalance,
      newBalance: senderNewBalance
    );

    return commit;
  }
  on OutOfBalanceException catch (e) {
    print("********** OUT OF BALANCE **********");
    stderr.writeln(">> STATUS: FAILED");
    stderr.writeln("-- MESSAGE: $e");
    stderr.writeln("-- CURRENT BALANCE: ${sender.getBalance}");
    stderr.writeln("-- AMOUNT TO WITHDRAW: $amount");

    return !commit;
  }
  on NoSuchUserException catch (e) {
    print("********** RECIPIENT DOES NOT EXIST **********");
    stderr.writeln(">> STATUS: FAILED");
    stderr.writeln("-- MESSAGE $e\n");

    return !commit;
  }
}

bool debitCash({required TransactionTypes transactionType, required User user, required double amount, required String success, String? error}) {
  var txTime = DateTime.now().toLocal();
  double oldBalance, newBalance;
  bool commit = true;

  try {
    // Throw an exception if the transaction type is not a debit transaction.
    if (!transactionType.debit) throw IncorrectTransactionException(transactionType);

    [oldBalance, newBalance] = user.deductBalance(amount);

    // On successful transaction
    printSuccessMessage(
        transactionType: transactionType,
        datetime: txTime.toString(),
        success: success,
    );

    user.addTransaction(
      transactionType: transactionType,
      timestamp: txTime.toString(),
      message: success,
      amount: amount,
      oldBalance: oldBalance,
      newBalance: newBalance
    );

    return commit;
  }
  on IncorrectTransactionException catch (e) {
    print("********** INCORRECT TRANSACTION TYPE **********");
    stderr.writeln(">> STATUS: TYPE ERROR");
    stderr.writeln("-- MESSAGE: ${error ?? e}\n");

    return !commit;
  }
  on OutOfBalanceException catch (e) {
    print("********** OUT OF BALANCE **********");
    stderr.writeln(">> STATUS: FAILED");
    stderr.writeln("-- MESSAGE: ${error ?? e}\n");
    stderr.writeln("-- CURRENT BALANCE: ${user.getBalance}");
    stderr.writeln("-- AMOUNT TO WITHDRAW: $amount");

    return !commit;
  }
}

void changePin({required User user, required String newCode}) {
  var txTime = DateTime.now().toLocal();
  user.setPin = newCode;

  printSuccessMessage(
      transactionType: TransactionTypes.changePinCode,
      datetime: txTime.toString(),
      success: "Changed ATM PIN code."
  );

  user.addTransaction(
      transactionType: TransactionTypes.changePinCode,
      timestamp: txTime.toString(),
      message: "Changed ATM PIN code."
  );
}

User? findUser({required List<User> users, required String id}) {
  try {
    return users.firstWhere((user) => user.getId == id);
  }
  catch (e) {
    return throw NoSuchUserException("User id '$id' does not exist.");
  }
}