import 'package:flutter/material.dart';

class BookedDatesModel {
  final DateTime startDate;
  final DateTime endDate;
  final Color? bgColor;

  BookedDatesModel(
      {required this.startDate, required this.endDate, this.bgColor});
}
