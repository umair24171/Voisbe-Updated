// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class PaymentInfoModel {
  final String paymentId;
  final String userId;
  final String fullName;
  final String accountNo;
  final String swiftCode;
  final String bankName;
  final String bankAddress;

  PaymentInfoModel(
      {required this.paymentId,
      required this.userId,
      required this.fullName,
      required this.accountNo,
      required this.swiftCode,
      required this.bankName,
      required this.bankAddress});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'paymentId': paymentId,
      'userId': userId,
      'fullName': fullName,
      'accountNo': accountNo,
      'swiftCode': swiftCode,
      'bankName': bankName,
      'bankAddress': bankAddress,
    };
  }

  factory PaymentInfoModel.fromMap(Map<String, dynamic> map) {
    return PaymentInfoModel(
      paymentId: map['paymentId'] as String,
      userId: map['userId'] as String,
      fullName: map['fullName'] as String,
      accountNo: map['accountNo'] as String,
      swiftCode: map['swiftCode'] as String,
      bankName: map['bankName'] as String,
      bankAddress: map['bankAddress'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory PaymentInfoModel.fromJson(String source) =>
      PaymentInfoModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
