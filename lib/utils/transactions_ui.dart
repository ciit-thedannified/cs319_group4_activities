library utils;

import 'dart:io';
import 'dart:collection';
import '../exceptions/transaction_exceptions.dart';

import '../utils/transactions_utils.dart';
import '../classes/user.dart';

export 'package:cs319_assignment_activity1/utils/transactions_ui.dart';

void uiPayBills(User user) {
  String? biller;
  String? iamount;
  RegExp validBillerNamePattern = RegExp(r'^[a-zA-Z0-9\W]{3,}$');

  double amount = 0;

  bool session = true;

  while (session) {
    do {
      print("**** PAY BILLS ****");
      print("- Type '-1' to terminate transaction.\n");

      stdout.write("ENTER BILLER NAME: ");
      biller = stdin.readLineSync();

      if (biller == null || !validBillerNamePattern.hasMatch(biller)) {
        stderr.writeln("!! Please provide a valid biller name.\n");
      }
      else if (biller == '-1') {
        print(">> PAY BILLS TERMINATED.\n");
        session = false;
      }
    } while (session && !validBillerNamePattern.hasMatch(biller ?? ''));

    stdout.write("ENTER AMOUNT TO PAY BILLER: ");
    iamount = stdin.readLineSync();

    amount = double.tryParse(iamount!) ?? 0.0;

    if (amount == -1) {
      print(">> PAY BILLS TERMINATED.\n");
      session = false;
    }
    else if (amount <= 0) {
      stderr.writeln(">> Transferred amount cannot be less than or equal to 0.\n");
    }
    else {
      try {
        session = !debitCash(
          transactionType: TransactionTypes.payBills,
          user: user,
          amount: amount,
          success: "Paid $amount to BILLER '$biller'",
        );
      }
      finally {}
    }
  }
}

void uiDashboard() {
  print("*********************");
  print("   iOS ATM GROUP 4   ");
  print("*********************\n");

  print("Select a transaction: ");
  for (TransactionTypes txTypes in TransactionTypes.values) {
    print("[${txTypes.code}] ${txTypes.name} ");
  }
  print("[$exitCodeCommand] Log out\n");
}

void printSuccessMessage({required TransactionTypes transactionType, required String datetime, required String success, double? oldBalance, double? newBalance}) {
  print("********** ACKNOWLEDGEMENT RECEIPT **********");
  print(">> STATUS: SUCCESS");
  print("++ TRANSACTION TYPE: ${transactionType.name}");
  print("++ TRANSACTION DATE: $datetime");
  print("-- MESSAGE: $success");
  if (oldBalance != null) print("-- OLD BALANCE: $oldBalance");
  if (newBalance != null) print("-- NEW BALANCE: $newBalance");
  stdout.write("\n");
}