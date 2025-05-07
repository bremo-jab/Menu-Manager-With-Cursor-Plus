import 'package:flutter/material.dart';

class TimeRange {
  final TimeOfDay start;
  final TimeOfDay end;

  TimeRange({
    required this.start,
    required this.end,
  });

  Map<String, dynamic> toMap() {
    return {
      'start': '${start.hour}:${start.minute}',
      'end': '${end.hour}:${end.minute}',
    };
  }

  factory TimeRange.fromMap(Map<String, dynamic> map) {
    final startParts = (map['start'] as String).split(':');
    final endParts = (map['end'] as String).split(':');

    return TimeRange(
      start: TimeOfDay(
        hour: int.parse(startParts[0]),
        minute: int.parse(startParts[1]),
      ),
      end: TimeOfDay(
        hour: int.parse(endParts[0]),
        minute: int.parse(endParts[1]),
      ),
    );
  }
}

class WorkingDayModel {
  final String name;
  final bool isOpen;
  final List<TimeRange> timeRanges;

  WorkingDayModel({
    required this.name,
    this.isOpen = true,
    this.timeRanges = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isOpen': isOpen,
      'timeRanges': timeRanges.map((range) => range.toMap()).toList(),
    };
  }

  factory WorkingDayModel.fromMap(Map<String, dynamic> map) {
    return WorkingDayModel(
      name: map['name'] ?? '',
      isOpen: map['isOpen'] ?? true,
      timeRanges: (map['timeRanges'] as List<dynamic>?)
              ?.map((range) => TimeRange.fromMap(range as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  WorkingDayModel copyWith({
    String? name,
    bool? isOpen,
    List<TimeRange>? timeRanges,
  }) {
    return WorkingDayModel(
      name: name ?? this.name,
      isOpen: isOpen ?? this.isOpen,
      timeRanges: timeRanges ?? this.timeRanges,
    );
  }
}
