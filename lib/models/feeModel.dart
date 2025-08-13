class FeeModel {
  bool? ok;
  String? msg;
  Data? data;

  FeeModel({this.ok, this.msg, this.data});

  FeeModel.fromJson(Map<String, dynamic> json) {
    ok = json['ok'];
    msg = json['msg'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
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
  String? baseFee;
  String? totalKm;
  String? totalKmCharged;
  String? totalMinutes;
  String? totalMinCharged;
  String? discountPercentage;
  String? discountAmount;
  String? subTotal;
  String? grandTotal;
  String? vehicleTypeBaseFare;
  List<StopsBreakdown>? stopsBreakdown;

  Data(
      {this.baseFee,
      this.totalKm,
      this.totalKmCharged,
      this.totalMinutes,
      this.totalMinCharged,
      this.discountPercentage,
      this.discountAmount,
      this.subTotal,
      this.grandTotal,
      this.vehicleTypeBaseFare,
      this.stopsBreakdown});

  Data.fromJson(Map<String, dynamic> json) {
    baseFee = json['baseFee'].toString();
    totalKm = json['totalKm'].toString();
    totalKmCharged = json['totalKmCharged'].toString();
    totalMinutes = json['totalMinutes'].toString();
    totalMinCharged = json['totalMinCharged'].toString();
    discountPercentage = json['discountPercentage'].toString();
    discountAmount = json['discountAmount'].toString();
    subTotal = json['subTotal'].toString();
    grandTotal = json['grandTotal'].toString();
    vehicleTypeBaseFare = json['vehicleTypeBaseFare'].toString();
    if (json['stopsBreakdown'] != null) {
      stopsBreakdown = <StopsBreakdown>[];
      json['stopsBreakdown'].forEach((v) {
        stopsBreakdown!.add(new StopsBreakdown.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['baseFee'] = baseFee;
    data['totalKm'] = totalKm;
    data['totalKmCharged'] = totalKmCharged;
    data['totalMinutes'] = totalMinutes;
    data['totalMinCharged'] = totalMinCharged;
    data['discountPercentage'] = discountPercentage;
    data['discountAmount'] = discountAmount;
    data['subTotal'] = subTotal;
    data['grandTotal'] = grandTotal;
    data['vehicleTypeBaseFare'] = vehicleTypeBaseFare;
    if (stopsBreakdown != null) {
      data['stopsBreakdown'] =
          stopsBreakdown!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class StopsBreakdown {
  String? stopIndex;
  String? geofenceId;
  String? baseFare;
  String? kmFare;
  String? minFare;
  String? totalStopFare;

  StopsBreakdown(
      {this.stopIndex,
      this.geofenceId,
      this.baseFare,
      this.kmFare,
      this.minFare,
      this.totalStopFare});

  StopsBreakdown.fromJson(Map<String, dynamic> json) {
    stopIndex = json['stop_index'].toString();
    geofenceId = json['geofenceId'].toString();
    baseFare = json['base_fare'].toString();
    kmFare = json['km_fare'].toString();
    minFare = json['min_fare'].toString();
    totalStopFare = json['total_stop_fare'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stop_index'] = stopIndex;
    data['geofenceId'] = geofenceId;
    data['base_fare'] = baseFare;
    data['km_fare'] = kmFare;
    data['min_fare'] = minFare;
    data['total_stop_fare'] = totalStopFare;
    return data;
  }
}
