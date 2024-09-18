library utils;

import 'dart:io';
import 'dart:convert';

import '../classes/user.dart';

export 'package:cs319_group4_activities/utils/users_utils.dart';

const userFilename = "./lib/files/user.json";

Future<List<User>> initializeUsers() async {
  File usersFile = File(userFilename);
  var usersDatabase = jsonDecode(usersFile.readAsStringSync());
  List<User> users = [];

  for (dynamic user in usersDatabase) {
    User u = User(
      user['id'],
      user['pin'],
      user['balance'],
      user['locked'],
      user['transactions'],
    );

    users.add(u);
  }

  return users;
}

void saveUsers(List<User> database) {
  File usersFile = File(userFilename);
  var usersList = database.map((user) => user.toJson()).toList();
  var encoder = JsonEncoder.withIndent("  ");
  var result = encoder.convert(usersList);

  usersFile.openWrite(mode: FileMode.write);
  usersFile.writeAsStringSync(result);
}