// To parse this JSON data, do
//
//     final activityDetails = activityDetailsFromJson(jsonString);

import 'dart:convert';

import 'package:intl/intl.dart';

List<ActivityDetails> activityDetailsFromJson(String str) => List<ActivityDetails>.from(json.decode(str).map((x) => ActivityDetails.fromJson(x)));

String activityDetailsToJson(List<ActivityDetails> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson()))).toString();

class ActivityDetails {
  String pointStatus;
  String actionId;
  String activity;
  String? debit;
  String displayText;
  String reason;
  String createDate;
  String? credit;
  String? pointType;
  String? orderId;

  ActivityDetails({
    required this.pointStatus,
    required this.actionId,
    required this.activity,
    this.debit,
    required this.displayText,
    required this.reason,
    required this.createDate,
    this.credit,
    this.pointType,
    this.orderId,
  });

  factory ActivityDetails.fromJson(Map<String, dynamic> json) {
  return
  ActivityDetails
  (
  pointStatus: pointStatusValues.map[json["pointStatus"]].toString(),
  actionId: json["actionId"].toString(),
  activity: activityValues.map[json["activity"]].toString(),
  debit: json["debit"].toString(),
  displayText: displayTextValues.map[json["displayText"]].toString(),
  reason: json["reason"].toString(),
  //createDate: this.convert(json["createDate"]).toString(),
      createDate:json["createDate"].toString(),
      credit: json["credit"].toString(),
  pointType: pointTypeValues.map[json["pointType"]].toString(),
  orderId: json["orderId"].toString(),
  );
}



  Map<String, dynamic> toJson() => {
    "pointStatus": pointStatusValues.reverse[pointStatus],
    "actionId": actionId,
    "activity": activityValues.reverse[activity],
    "debit": debit,
    "displayText": displayTextValues.reverse[displayText],
    "reason": reason,
    "createDate":convert(createDate),
    "credit": credit,
    "pointType": pointTypeValues.reverse[pointType],
    "orderId": orderId,
  };

  convert(date) {
    DateTime now = date? date : DateTime.now();
   // String formattedDate = DateFormat.yMMM().format(now);
    return DateFormat.yMMM().format(now);
  }
}

enum Activity {
  CREDIT,
  DEBIT
}

final activityValues = EnumValues({
  "CREDIT": Activity.CREDIT,
  "DEBIT": Activity.DEBIT
});

enum DisplayText {
  POINTS_EXPIRED,
  PURCHASE
}

final displayTextValues = EnumValues({
  "Points Expired": DisplayText.POINTS_EXPIRED,
  "Purchase": DisplayText.PURCHASE
});

enum PointStatus {
  EXPIRED,
  RELEASED
}

final pointStatusValues = EnumValues({
  "Expired": PointStatus.EXPIRED,
  "Released": PointStatus.RELEASED
});

enum PointType {
  PROMOTIONAL,
  STANDARD
}

final pointTypeValues = EnumValues({
  "Promotional": PointType.PROMOTIONAL,
  "Standard": PointType.STANDARD
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }



}
