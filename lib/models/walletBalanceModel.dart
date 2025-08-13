import 'package:flutter/material.dart';

class WalletBalanceModel {
  bool? ok;
  String? msg;
  Data? data;

  WalletBalanceModel({this.ok, this.msg, this.data});

  WalletBalanceModel.fromJson({
    @required Map<String, dynamic>? json,
    @required String? httpMsg,
  }) {
    if (json != null) {
      ok = json['ok'];
      msg = json['msg'];
      data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    } else {
      ok = false;
      msg = httpMsg;
      data = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ok'] = ok;
    data['msg'] = msg;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  dynamic balance;
  dynamic credit;
  dynamic debit;

  Data({this.balance, this.credit, this.debit});

  Data.fromJson(Map<String, dynamic> json) {
    balance = json['balance'];
    credit = json['credit'];
    debit = json['debit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['balance'] = balance;
    data['credit'] = credit;
    data['debit'] = debit;
    return data;
  }
}
