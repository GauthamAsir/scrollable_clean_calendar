import 'booked_date_model.dart';

class DayValues {
  /// The current day in layout
  final DateTime day;

  /// The text (day)
  final String text;

  /// If the item is select or not
  final bool isSelected;

  /// The first day in the row for each week
  final bool isFirstDayOfWeek;

  /// The last day in the row for each week, but just the item seven
  final bool isLastDayOfWeek;

  /// The min date selected
  /// If [rangeMode] is false the rangeMinDate is the date selected (don't use [rangeMaxDate])
  final DateTime? selectedMinDate;

  /// The max date selected
  final DateTime? selectedMaxDate;

  /// The min date
  final DateTime minDate;

  /// The max date
  final DateTime maxDate;

  final bool isBlocked;

  final bool isBooked;
  final List<BookedDatesModel> bookedDatesModel;

  DayValues(
      {required this.day,
      required this.text,
      required this.isSelected,
      required this.isFirstDayOfWeek,
      required this.isLastDayOfWeek,
      this.selectedMinDate,
      this.selectedMaxDate,
      required this.minDate,
      required this.maxDate,
      required this.isBlocked,
      required this.isBooked,
      this.bookedDatesModel = const []});
}
