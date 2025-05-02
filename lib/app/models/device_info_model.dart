import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceInfoModel {
  final String deviceId;
  final String deviceType;
  final String operatingSystem;
  final DateTime loginTime;
  final String userId;

  DeviceInfoModel({
    required this.deviceId,
    required this.deviceType,
    required this.operatingSystem,
    required this.loginTime,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'deviceType': deviceType,
      'operatingSystem': operatingSystem,
      'loginTime': loginTime,
      'userId': userId,
    };
  }

  factory DeviceInfoModel.fromMap(Map<String, dynamic> map) {
    return DeviceInfoModel(
      deviceId: map['deviceId'] ?? '',
      deviceType: map['deviceType'] ?? '',
      operatingSystem: map['operatingSystem'] ?? '',
      loginTime: (map['loginTime'] as Timestamp).toDate(),
      userId: map['userId'] ?? '',
    );
  }
}
