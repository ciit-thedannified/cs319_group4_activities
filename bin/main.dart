import 'dart:io';

import 'package:cs319_group4_activities/classes/user.dart';

import 'package:cs319_group4_activities/utils/transactions_ui.dart';
import 'package:cs319_group4_activities/utils/transactions_utils.dart';
import 'package:cs319_group4_activities/utils/users_utils.dart';

void main() async {
  List<User> users = await initializeUsers();
  bool session = true;
  bool loggedIn = false;

  String? command;

  // Default user account
  User currentUser = users[0];

  print("*********************");
  print("   iOS ATM GROUP 4   ");
  print("*********************\n");

  if (currentUser.isLocked) {
    stderr.writeln("****** ACCOUNT LOCKED ******");
    stderr.writeln(">> Your account has been locked due to multiple failed PIN code attempts.");
    stderr.writeln(">> Please contact your bank provider to ask for assistance and unlock your account.");
    stderr.writeln(">> The terminal will now close...");
    return;
  }

  loggedIn = uiPromptPinCode(currentUser);

  if (loggedIn) {
    while (session) {
      uiDashboard();

      stdout.write(">> ENTER COMMAND: ");
      command = stdin.readLineSync();

      if (command == TransactionTypes.balanceInquiry.code) {
        uiBalanceInquiry(currentUser);
      }
      else if (command == TransactionTypes.withdrawCash.code) {
        uiWithdrawCash(currentUser);
      }
      else if (command == TransactionTypes.transferMoney.code) {
        uiTransferMoney(currentUser, users);
      }
      else if (command == TransactionTypes.changePinCode.code) {
        uiChangePinCode(currentUser);
      }
      else if (command == TransactionTypes.payBills.code) {
        uiPayBills(currentUser);
      }
      else if (command == TransactionTypes.depositMoney.code) {
        uiDepositMoney(currentUser);
      }
      else if (command!.toUpperCase() == 'X') {
        print("** Thank you for using our ATM!");
        session = false;
      }
      else {
        stderr.writeln("!! Invalid command.\n");
      }
    }
  }

  saveUsers(users);
}
