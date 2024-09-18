library exceptions;

import 'package:cs319_group4_activities/utils/transactions_utils.dart';
export 'package:cs319_group4_activities/exceptions/transaction_exceptions.dart';

class IncorrectTransactionException implements Exception {
  final TransactionTypes transactionType;
  String? message;

  IncorrectTransactionException(this.transactionType);
  IncorrectTransactionException.withMessage(this.transactionType, {String? message});

  @override
  String toString() {
    return "IncorrectTransactionException: ${message ?? "$transactionType is not a debit transaction."}";
  }
}

class OutOfBalanceException implements Exception {
  final String message;

  OutOfBalanceException(this.message);

  @override
  String toString() {
    return "OutOfBalanceException: $message";
  }
}

class IncorrectPinCodeException implements Exception {
  final String message;

  IncorrectPinCodeException([this.message = "You entered an incorrect PIN code."]);

  @override
  String toString() {
    return "IncorrectPinCodeException: $message";
  }
}

class NoSuchUserException implements Exception {
  final String message;

  NoSuchUserException(this.message);

  @override
  String toString() {
    return "NoSuchUserException: $message";
  }
}