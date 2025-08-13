import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SalesSummaryModel {
  bool? ok;
  String? msg;
  SalesSummaryData? data;
  bool? paymentDoneToday;

  SalesSummaryModel({
    this.ok,
    this.msg,
    this.data,
    this.paymentDoneToday,
  });

  SalesSummaryModel.fromJson({
    @required Map<String, dynamic>? json,
    @required String? httpMsg,
  }) {
    if (json != null) {
      ok = json['ok'];
      msg = json['msg'];
      data = json['data'] != null ? new SalesSummaryData.fromJson(json['data']) : null;

      paymentDoneToday = false; // Initialize to false
      if (data != null && data!.salesPaymentHistory != null) {
        for (var i = 0; i < data!.salesPaymentHistory!.length; i++) {
          if (data!.salesPaymentHistory![i].datePaid != null) {
            // Define the format of the input string
            DateFormat inputFormat = DateFormat("dd MMM, yyyy hh:mm");

            // Parse the string into a DateTime object
            String dateString = data!.salesPaymentHistory![i].datePaid!;
            DateTime date = inputFormat.parse(dateString.substring(0, dateString.length - 3));
            final now = DateTime.now();
            if (date.year == now.year && date.month == now.month && date.day == now.day) {
              paymentDoneToday = true;
            }
          }
        }
      }
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

class SalesSummaryData {
  String? amountToPayDaily;
  String? salesPaymentStatus;
  String? paymentStartTime;
  String? paymentEndTime;
  int? todayEarnings;
  List<SalesPaymentHistory>? salesPaymentHistory;
  SalesPayments? salesPayments;
  bool? allowPayment;

  SalesSummaryData(
      {this.amountToPayDaily,
      this.salesPaymentStatus,
      this.paymentStartTime,
      this.paymentEndTime,
      this.todayEarnings,
      this.salesPaymentHistory,
      this.salesPayments,
      this.allowPayment});

  SalesSummaryData.fromJson(Map<String, dynamic> json) {
    amountToPayDaily = json['amountToPayDaily'];
    salesPaymentStatus = json['salesPaymentStatus'];
    paymentStartTime = json['paymentStartTime'];
    paymentEndTime = json['paymentEndTime'];
    todayEarnings = json['todayEarnings'];
    if (json['salesPaymentHistory'] != null) {
      salesPaymentHistory = <SalesPaymentHistory>[];
      json['salesPaymentHistory'].forEach((v) {
        salesPaymentHistory!.add(new SalesPaymentHistory.fromJson(v));
      });
    }
    salesPayments = json['salesPayments'] != null ? new SalesPayments.fromJson(json['salesPayments']) : null;

    allowPayment = true;
    // checking if payment end time is up set allowPayment to false and also if payment start time is up set allowPayment to true
    if (paymentStartTime != null && paymentEndTime != null) {
      final now = DateTime.now();

      // Combine today's date with the start and end times
      final startTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(paymentStartTime!.split(":")[0]),
        int.parse(paymentStartTime!.split(":")[1]),
        int.parse(paymentStartTime!.split(":")[2]),
      );

      final endTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(paymentEndTime!.split(":")[0]),
        int.parse(paymentEndTime!.split(":")[1]),
        int.parse(paymentEndTime!.split(":")[2]),
      );

      // Allow payment only if the current time is within the start and end time range
      if (now.isAfter(startTime) && now.isBefore(endTime)) {
        allowPayment = true;
      } else {
        allowPayment = false;
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['amountToPayDaily'] = amountToPayDaily;
    data['salesPaymentStatus'] = salesPaymentStatus;
    data['paymentStartTime'] = paymentStartTime;
    data['paymentEndTime'] = paymentEndTime;
    data['todayEarnings'] = todayEarnings;
    if (salesPaymentHistory != null) {
      data['salesPaymentHistory'] = salesPaymentHistory!.map((v) => v.toJson()).toList();
    }
    if (salesPayments != null) {
      data['salesPayments'] = salesPayments!.toJson();
    }
    return data;
  }
}

class SalesPaymentHistory {
  String? transid;
  int? amount;
  String? title;
  String? description;
  String? paymentMethod;
  String? reference;
  String? datePaid;

  SalesPaymentHistory({
    this.transid,
    this.amount,
    this.title,
    this.description,
    this.paymentMethod,
    this.reference,
    this.datePaid,
  });

  SalesPaymentHistory.fromJson(Map<String, dynamic> json) {
    transid = json['transid'];
    amount = json['amount'];
    title = json['title'];
    description = json['description'];
    paymentMethod = json['paymentMethod'];
    reference = json['reference'];
    datePaid = json['datePaid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['transid'] = transid;
    data['amount'] = amount;
    data['title'] = title;
    data['description'] = description;
    data['paymentMethod'] = paymentMethod;
    data['reference'] = reference;
    data['datePaid'] = datePaid;
    return data;
  }
}

class SalesPayments {
  List<SalesPaymentHistory>? self;
  List<SalesPaymentHistory>? others;

  SalesPayments({this.self, this.others});

  SalesPayments.fromJson(Map<String, dynamic> json) {
    if (json['self'] != null) {
      self = <SalesPaymentHistory>[];
      json['self'].forEach((v) {
        self!.add(new SalesPaymentHistory.fromJson(v));
      });
    }
    if (json['others'] != null) {
      others = <SalesPaymentHistory>[];
      json['others'].forEach((v) {
        others!.add(new SalesPaymentHistory.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (self != null) {
      data['self'] = self!.map((v) => v.toJson()).toList();
    }
    if (others != null) {
      data['others'] = others!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
