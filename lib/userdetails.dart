// To parse this JSON data, do
//
//     final userDetails = userDetailsFromJson(jsonString);

import 'dart:convert';

UserDetails userDetailsFromJson(String str) =>
    UserDetails.fromJson(json.decode(str));

String userDetailsToJson(UserDetails data) => json.encode(data.toJson());

class UserDetails {
  String siteId;
  String id;
  num availablePoints;
  num usedPoints;
  num expiredPoints;
  num lifetimePoints;
  num holdPoints;
  num usedPointsOnReward;
  num pointsToExpire;
  num pointsToNextTier;
  num spendToNextTier;
  DateTime pointsToExpireDate;
  double totalSpent;
  num creditsToCurrencyRatio;
  num creditsToCurrencyValue;
  num ytdCreditPoints;
  num ytdDebitPoints;
  num availableRedemptionPoints;
  num usedRedemptionPoints;

  UserDetails({
    required this.siteId,
    required this.id,
    required this.availablePoints,
    required this.usedPoints,
    required this.expiredPoints,
    required this.lifetimePoints,
    required this.holdPoints,
    required this.usedPointsOnReward,
    required this.pointsToExpire,
    required this.pointsToNextTier,
    required this.spendToNextTier,
    required this.pointsToExpireDate,
    required this.totalSpent,
    required this.creditsToCurrencyRatio,
    required this.creditsToCurrencyValue,
    required this.ytdCreditPoints,
    required this.ytdDebitPoints,
    required this.availableRedemptionPoints,
    required this.usedRedemptionPoints,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) => UserDetails(
        siteId: json["siteId"],
        id: json["id"],
        availablePoints: json["availablePoints"],
        usedPoints: json["usedPoints"],
        expiredPoints: json["expiredPoints"],
        lifetimePoints: json["lifetimePoints"],
        holdPoints: json["holdPoints"],
        usedPointsOnReward: json["usedPointsOnReward"],
        pointsToExpire: json["pointsToExpire"],
        pointsToNextTier: json["pointsToNextTier"],
        spendToNextTier: json["spendToNextTier"],
        pointsToExpireDate: DateTime.parse(json["pointsToExpireDate"]),
        totalSpent: json["totalSpent"]?.toDouble(),
        creditsToCurrencyRatio: json["creditsToCurrencyRatio"],
        creditsToCurrencyValue: json["creditsToCurrencyValue"],
        ytdCreditPoints: json["ytdCreditPoints"],
        ytdDebitPoints: json["ytdDebitPoints"],
        availableRedemptionPoints: json["availableRedemptionPoints"],
        usedRedemptionPoints: json["usedRedemptionPoints"],
      );

  Map<String, dynamic> toJson() => {
        "siteId": siteId,
        "id": id,
        "availablePoints": availablePoints,
        "usedPoints": usedPoints,
        "expiredPoints": expiredPoints,
        "lifetimePoints": lifetimePoints,
        "holdPoints": holdPoints,
        "usedPointsOnReward": usedPointsOnReward,
        "pointsToExpire": pointsToExpire,
        "pointsToNextTier": pointsToNextTier,
        "spendToNextTier": spendToNextTier,
        "pointsToExpireDate": pointsToExpireDate.toIso8601String(),
        "totalSpent": totalSpent,
        "creditsToCurrencyRatio": creditsToCurrencyRatio,
        "creditsToCurrencyValue": creditsToCurrencyValue,
        "ytdCreditPoints": ytdCreditPoints,
        "ytdDebitPoints": ytdDebitPoints,
        "availableRedemptionPoints": availableRedemptionPoints,
        "usedRedemptionPoints": usedRedemptionPoints,
      };
}
