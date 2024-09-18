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

void uiTransferMoney(User user, List<User> users) async {
  String? recipient;
  String? iamount;

  User? targetUser;
  double amount = 0;

  bool session = true;

  while (session) {
    while (targetUser == null) {
      print("**** TRANSFER MONEY ****");
      print("- Type '-1' to terminate transaction.\n");

      stdout.write("ENTER USER ID: ");
      recipient = stdin.readLineSync();

      if (recipient == "-1") {
        print(">> TRANSFER MONEY TERMINATED.\n");
        session = false;
      }
      else if (recipient == user.getId) {
        stderr.writeln("!! You cannot transfer money to yourself.\n");
      }
      else {
        try {
          targetUser = findUser(users: users, id: recipient!);
        } catch (e) {
          stderr.writeln(">> Please enter a user id to send money to.\n");
          targetUser = null;
        }
      }
    }

    stdout.write("ENTER AMOUNT TO TRANSFER: ");
    iamount = stdin.readLineSync();

    amount = double.tryParse(iamount!) ?? 0.0;

    if (amount == -1) {
      print(">> TRANSFER MONEY TERMINATED.\n");
      session = false;
    }
    else if (amount <= 0) {
      stderr.writeln(">> Transferred amount cannot be less than or equal to 0.\n");
    }
    else {
      try {
        session = !transferMoney(
            users: users,
            sender: user,
            recipientId: targetUser.getId,
            amount: amount
        );
      }
      catch (e) {
        amount = 0.0;
      }
    }
  }
}

/// User Interface for Withdraw Cash
void uiWithdrawCash(User user) {
  String? iamount;
  double amount = 0;
  bool session = true;

  /* Prompt the user to enter a valid withdrawal amount
   * to proceed with cashing out money from their balance.
   */
  do {
    print("**** WITHDRAW CASH ****");
    print("- Type '-1' to terminate withdrawal.\n");

    stdout.write("ENTER AMOUNT TO WITHDRAW: ");
    iamount = stdin.readLineSync();


    amount = double.tryParse(iamount!) ?? 0.0;

    if (iamount == "-1") {
      print(">> WITHDRAWAL TERMINATED.\n");
      session = false;
    }
    else if (amount <= 0) {
      stderr.writeln(">> Withdrawal amount cannot be less than or equal to 0.\n");
    }
    else {
      session = !debitCash(
          transactionType: TransactionTypes.withdrawCash,
          user: user,
          amount: amount,
          success: "You withdrew $amount from your account."
      );
    }
  } while (session);
}

void uiChangePinCode(User user) {
  String? oldCode;
  String? newCode;
  String? confirmPrompt;
  bool confirm = false;
  RegExp validPinPattern = RegExp(r'^[0-9]{4}$');
  bool session = true;

  while (session) {
    // PROMPT CURRENT USER PIN CODE
    do {
      print("**** CHANGE PIN CODE ****");
      print("- Type '-1' to terminate transaction.\n");

      stdout.write("ENTER CURRENT PIN: ");
      oldCode = stdin.readLineSync();

      if (oldCode == '-1') {
        print(">> CHANGE PIN TERMINATED.\n");
        session = false;
      }
      else if (oldCode == null || !validPinPattern.hasMatch(oldCode)) {
        stderr.write(">> Please enter your current 4-digit PIN code.");
      }
    } while (session && !validPinPattern.hasMatch(oldCode!));

    // PROMPT NEW USER PIN CODE
    while (session && !validPinPattern.hasMatch(newCode ?? "")) {
      stdout.write("ENTER NEW PIN: ");
      newCode = stdin.readLineSync();

      if (newCode == '-1') {
        print(">> CHANGE PIN TERMINATED.\n");
        session = false;
      }
      else if (newCode == null || !validPinPattern.hasMatch(newCode)) {
        stderr.write(">> Please enter a valid 4-digit PIN code.");
      }
    }

    while (session) {
      print("!!!! PIN CHANGE CONFIRMATION !!!!");
      print(">> You are about to change your current ATM PIN code with a new PIN code.");
      print(">> Are you sure of this change? Enter 'y' to confirm. Otherwise, type any character.");
      stdout.write("ENTER CONFIRMATION: ");

      confirmPrompt = stdin.readLineSync() ?? "";
      confirm = confirmPrompt.toLowerCase() == 'y';
      session = false;
    }
  }

  try {
    if (!confirm) return;

    if (user.getPin == oldCode && newCode != null) {
      changePin(
        user: user,
        newCode: newCode,
      );
    }
    else {
      throw IncorrectPinCodeException();
    }
  }
  on IncorrectPinCodeException catch (e) {
    print("********** INCORRECT PIN CODE **********");
    stderr.writeln(">> STATUS: FAILED");
    stderr.writeln("-- MESSAGE: $e\n");
  }
}

/// User Interface for Balance Inquiry
void uiBalanceInquiry(User user) {
  var txTime = DateTime.now().toLocal();

  print("**** BALANCE INQUIRY ****");
  print("Balance: ${user.getBalance}");
  print("*************************\n");

  user.addTransaction(
    transactionType: TransactionTypes.balanceInquiry,
    timestamp: txTime.toString(),
    message: "Checked Balance Inquiry",
  );
}

/// User Interface for Deposit Money
void uiDepositMoney(User user) {
  String? iamount;
  double amount = 0;
  bool session = true;

  do {
    print("**** DEPOSIT MONEY ****");
    print("- Type '-1' to terminate deposit transaction.\n");

    stdout.write("ENTER AMOUNT TO DEPOSIT: ");
    iamount = stdin.readLineSync();

    amount = double.tryParse(iamount!) ?? 0;

    if (amount <= 0) {
      stderr.writeln(">> Deposit amount cannot be less than or equal to 0.\n");
    }
    else if (amount == -1) {
      print(">> DEPOSIT TERMINATED.\n");
      session = false;
    }
    else {
      depositCash(user: user, amount: amount);
      session = false;
    }
  } while (session);
}