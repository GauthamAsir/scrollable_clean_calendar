import 'package:flutter/material.dart';

class BookedDatesModel {
  final DateTime startDate;
  final DateTime endDate;
  final Color? bgColor;
  final String? name;
  final String? icon;

  BookedDatesModel(
      {required this.startDate,
      required this.endDate,
      this.bgColor,
      this.name,
      this.icon});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookedDatesModel &&
          runtimeType == other.runtimeType &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode => startDate.hashCode ^ endDate.hashCode;
}
