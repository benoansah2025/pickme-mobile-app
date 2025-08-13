class UserModel {
  bool? ok;
  String? msg;
  Data? data;

  UserModel({this.ok, this.msg, this.data});

  UserModel.fromJson(Map<String, dynamic> json) {
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
  String? authToken;
  String? otpCode;
  String? otpMessage;
  UserData? user;

  Data({this.authToken, this.otpCode, this.otpMessage, this.user});

  Data.fromJson(Map<String, dynamic> json) {
    authToken = json['authToken'];
    otpCode = json['otpCode'];
    otpMessage = json['otpMessage'];
    user = json['user'] != null ? new UserData.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['authToken'] = authToken;
    data['otpCode'] = otpCode;
    data['otpMessage'] = otpMessage;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class UserData {
  String? userid;
  String? name;
  String? phone;
  String? email;
  dynamic dob;
  dynamic gender;
  dynamic picture;
  String? firebaseKey;
  String? status;
  dynamic lastLogin;
  bool? emailVerified;
  String? dateCreated;
  String? walletBalance;
  String? paymentPin;

  UserData({
    this.userid,
    this.name,
    this.phone,
    this.email,
    this.dob,
    this.gender,
    this.picture,
    this.firebaseKey,
    this.walletBalance,
    this.paymentPin,
    this.status,
    this.lastLogin,
    this.emailVerified,
    this.dateCreated,
  });

  UserData.fromJson(Map<String, dynamic> json) {
    userid = json['userid'];
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
    dob = json['dob'];
    gender = json['gender'];
    picture = json['picture'];
    walletBalance = json['walletBalance'].toString();
    paymentPin = json['paymentPin'];
    firebaseKey = json['firebaseKey'];
    status = json['status'];
    lastLogin = json['lastLogin'];
    emailVerified = json['emailVerified'];
    dateCreated = json['dateCreated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userid'] = userid;
    data['name'] = name;
    data['phone'] = phone;
    data['email'] = email;
    data['dob'] = dob;
    data['gender'] = gender;
    data['picture'] = picture;
    data['walletBalance'] = walletBalance;
    data['paymentPin'] = paymentPin;
    data['firebaseKey'] = firebaseKey;
    data['status'] = status;
    data['lastLogin'] = lastLogin;
    data['emailVerified'] = emailVerified;
    data['dateCreated'] = dateCreated;
    return data;
  }
}

UserModel? userModel;
