import 'package:flutter/foundation.dart';

class WalletTransactionsModel {
  bool? ok;
  List<Data>? data;

  WalletTransactionsModel({this.ok, this.data});

  WalletTransactionsModel.fromJson({
    @required Map<String, dynamic>? json,
    @required String? httpMsg,
  }) {
    if (json != null) {
      ok = json['ok'];
      if (json['data'] != null) {
        data = <Data>[];
        json['data'].forEach((v) {
          data!.add(new Data.fromJson(v));
        });
      }
    } else {
      ok = false;
      data = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ok'] = ok;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? transid;
  dynamic amount;
  String? reference;
  String? transType;
  String? channel;
  String? dateCreated;

  Data({this.transid, this.amount, this.reference, this.transType, this.channel, this.dateCreated});

  Data.fromJson(Map<String, dynamic> json) {
    transid = json['transid'];
    amount = json['amount'];
    reference = json['reference'];
    transType = json['transType'];
    channel = json['channel'];
    dateCreated = json['dateCreated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['transid'] = transid;
    data['amount'] = amount;
    data['reference'] = reference;
    data['transType'] = transType;
    data['channel'] = channel;
    data['dateCreated'] = dateCreated;
    return data;
  }
}
