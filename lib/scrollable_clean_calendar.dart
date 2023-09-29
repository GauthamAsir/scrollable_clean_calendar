library scrollable_clean_calendar;

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:scrollable_clean_calendar/controllers/clean_calendar_controller.dart';
import 'package:scrollable_clean_calendar/models/day_values_model.dart';
import 'package:scrollable_clean_calendar/utils/enums.dart';
import 'package:scrollable_clean_calendar/widgets/days_widget.dart';
import 'package:scrollable_clean_calendar/widgets/month_widget.dart';
import 'package:scrollable_clean_calendar/widgets/weekdays_widget.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'models/booked_date_model.dart';

class ScrollableCleanCalendar extends StatefulWidget {
  final Color? pageNavigatorColor;

  /// Listview direction
  final Axis scrollDirection;

  /// The language locale
  final String locale;

  /// Scroll controller
  final ScrollController? scrollController;

  /// PageController if scroll direction is horizontal
  final PageController? pageController;

  /// If is to show or not the weekdays in calendar
  final bool showWeekdays;

  /// What layout (design) is going to be used
  final Layout? layout;

  /// The space between month and calendar
  final double spaceBetweenMonthAndCalendar;

  /// The space between calendars
  final double spaceBetweenCalendars;

  /// The horizontal space in the calendar dates
  final double calendarCrossAxisSpacing;

  /// The vertical space in the calendar dates
  final double calendarMainAxisSpacing;

  /// The parent padding
  final EdgeInsets? padding;

  /// The label text style of month
  final TextStyle? monthTextStyle;

  /// The label text align of month
  final TextAlign? monthTextAlign;

  /// The label text align of month
  final TextStyle? weekdayTextStyle;

  /// The label text style of day
  final TextStyle? dayTextStyle;

  /// The day selected background color
  final Color? daySelectedBackgroundColor;

  /// The day background color
  final Color? dayBackgroundColor;

  /// The day selected background color that is between day selected edges
  final Color? daySelectedBackgroundColorBetween;

  /// The day disable background color
  final Color? dayDisableBackgroundColor;

  /// The day disable color
  final Color? dayDisableColor;

  /// The radius of day items
  final double dayRadius;

  /// A builder to make a customized month
  final Widget Function(BuildContext context, String month)? monthBuilder;

  /// A builder to make a customized weekday
  final Widget Function(BuildContext context, String weekday)? weekdayBuilder;

  /// A builder to make a customized day of calendar
  final Widget Function(BuildContext context, DayValues values)? dayBuilder;

  /// The controller of ScrollableCleanCalendar
  final CleanCalendarController calendarController;

  final List<DateTime> blockedDatesList;

  final bool strikeUnSelectableDates;

  final bool beautifyBlockedDates;

  final bool disableSelection;

  final List<BookedDatesModel> bookedDates;

  const ScrollableCleanCalendar(
      {this.locale = 'en',
      this.scrollController,
      this.showWeekdays = true,
      this.beautifyBlockedDates = false,
      this.disableSelection = false,
      this.blockedDatesList = const [],
      this.bookedDates = const [],
      this.strikeUnSelectableDates = true,
      this.layout,
      this.calendarCrossAxisSpacing = 4,
      this.calendarMainAxisSpacing = 4,
      this.spaceBetweenCalendars = 24,
      this.spaceBetweenMonthAndCalendar = 24,
      this.padding,
      this.monthBuilder,
      this.weekdayBuilder,
      this.dayBuilder,
      this.monthTextAlign,
      this.monthTextStyle,
      this.weekdayTextStyle,
      this.daySelectedBackgroundColor,
      this.dayBackgroundColor,
      this.daySelectedBackgroundColorBetween,
      this.dayDisableBackgroundColor,
      this.dayDisableColor,
      this.dayTextStyle,
      this.dayRadius = 6,
      required this.calendarController,
      this.pageController,
      this.scrollDirection = Axis.vertical,
      this.pageNavigatorColor = Colors.white})
      : assert(layout != null ||
            (monthBuilder != null &&
                weekdayBuilder != null &&
                dayBuilder != null));

  @override
  State<ScrollableCleanCalendar> createState() =>
      _ScrollableCleanCalendarState();
}

class _ScrollableCleanCalendarState extends State<ScrollableCleanCalendar> {
  late PageController pageController;

  @override
  void initState() {
    pageController = widget.pageController ?? PageController();
    initializeDateFormatting();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final focusDate = widget.calendarController.initialFocusDate;
      if (focusDate != null) {
        widget.calendarController.jumpToMonth(date: focusDate);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.scrollDirection == Axis.horizontal
        ? pageViewCalendar()
        : widget.scrollController != null
            ? listViewCalendar()
            : scrollablePositionedListCalendar();
  }

  Widget listViewCalendar() {
    return ListView.separated(
      controller: widget.scrollController,
      scrollDirection: widget.scrollDirection,
      padding: widget.padding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      separatorBuilder: (_, __) =>
          SizedBox(height: widget.spaceBetweenCalendars),
      itemCount: widget.calendarController.months.length,
      itemBuilder: (context, index) {
        final month = widget.calendarController.months[index];

        return childCollumn(month);
      },
    );
  }

  Widget pageViewCalendar() {
    return Padding(
      padding: widget.padding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: PageView.builder(
        controller: pageController,
        physics: const ClampingScrollPhysics(),
        scrollDirection: widget.scrollDirection,
        // separatorBuilder: (_, __) =>
        //     SizedBox(height: widget.spaceBetweenCalendars),
        itemCount: widget.calendarController.months.length,
        itemBuilder: (context, index) {
          final month = widget.calendarController.months[index];

          return childCollumn(month);
        },
      ),
    );
  }

  Widget scrollablePositionedListCalendar() {
    return ScrollablePositionedList.separated(
      itemScrollController: widget.calendarController.itemScrollController,
      padding: widget.padding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      scrollDirection: widget.scrollDirection,
      separatorBuilder: (_, __) =>
          SizedBox(height: widget.spaceBetweenCalendars),
      itemCount: widget.calendarController.months.length,
      itemBuilder: (context, index) {
        final month = widget.calendarController.months[index];

        return childCollumn(month);
      },
    );
  }

  Widget childCollumn(DateTime month) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            InkWell(
              onTap: () {
                pageController.previousPage(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut);
                setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: widget.pageNavigatorColor ?? Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                          offset: Offset(0, 1),
                          spreadRadius: 0,
                          blurRadius: 6,
                          color: Color(0xff0000001a))
                    ]),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 16,
                  color: widget.pageNavigatorColor != null
                      ? (widget.pageNavigatorColor!.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white)
                      : Colors.black,
                ),
              ),
            ),
            Expanded(
              child: MonthWidget(
                month: month,
                locale: widget.locale,
                layout: widget.layout,
                monthBuilder: widget.monthBuilder,
                textAlign: widget.monthTextAlign,
                textStyle: widget.monthTextStyle,
              ),
            ),
            InkWell(
              onTap: () {
                pageController.nextPage(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut);
                setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: widget.pageNavigatorColor ?? Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                          offset: Offset(0, 1),
                          spreadRadius: 0,
                          blurRadius: 6,
                          color: Color(0xff0000001a))
                    ]),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: widget.pageNavigatorColor != null
                      ? (widget.pageNavigatorColor!.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white)
                      : Colors.black,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: widget.spaceBetweenMonthAndCalendar),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            WeekdaysWidget(
              showWeekdays: widget.showWeekdays,
              cleanCalendarController: widget.calendarController,
              locale: widget.locale,
              layout: widget.layout,
              weekdayBuilder: widget.weekdayBuilder,
              textStyle: widget.weekdayTextStyle,
            ),
            AnimatedBuilder(
              animation: widget.calendarController,
              builder: (_, __) {
                return DaysWidget(
                  month: month,
                  blockedDatesList: widget.blockedDatesList,
                  strikeUnSelectableDates: widget.strikeUnSelectableDates,
                  disableSelection: widget.disableSelection,
                  beautifyBlockedDates: widget.beautifyBlockedDates,
                  bookedDates: widget.bookedDates,
                  cleanCalendarController: widget.calendarController,
                  calendarCrossAxisSpacing: widget.calendarCrossAxisSpacing,
                  calendarMainAxisSpacing: widget.calendarMainAxisSpacing,
                  layout: widget.layout,
                  dayBuilder: widget.dayBuilder,
                  backgroundColor: widget.dayBackgroundColor,
                  selectedBackgroundColor: widget.daySelectedBackgroundColor,
                  selectedBackgroundColorBetween:
                      widget.daySelectedBackgroundColorBetween,
                  disableBackgroundColor: widget.dayDisableBackgroundColor,
                  dayDisableColor: widget.dayDisableColor,
                  radius: widget.dayRadius,
                  textStyle: widget.dayTextStyle,
                );
              },
            )
          ],
        )
      ],
    );
  }
}
