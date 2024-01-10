import 'package:flutter/material.dart';
import 'package:scrollable_clean_calendar/controllers/clean_calendar_controller.dart';
import 'package:scrollable_clean_calendar/models/booked_date_model.dart';
import 'package:scrollable_clean_calendar/models/day_values_model.dart';
import 'package:scrollable_clean_calendar/utils/enums.dart';
import 'package:scrollable_clean_calendar/utils/extensions.dart';
import 'package:scrollable_clean_calendar/widgets/network_image_item.dart';

class DaysWidget extends StatelessWidget {
  final CleanCalendarController cleanCalendarController;
  final DateTime month;
  final double calendarCrossAxisSpacing;
  final double calendarMainAxisSpacing;
  final Layout? layout;
  final Widget Function(
    BuildContext context,
    DayValues values,
  )? dayBuilder;
  final Color? selectedBackgroundColor;
  final Color? backgroundColor;
  final Color? selectedBackgroundColorBetween;
  final Color? disableBackgroundColor;
  final Color? dayDisableColor;
  final double radius;
  final TextStyle? textStyle;
  final List<DateTime> blockedDatesList;
  final bool strikeUnSelectableDates;
  final bool beautifyBlockedDates;
  final bool disableSelection;
  final List<BookedDatesModel> bookedDates;

  const DaysWidget(
      {Key? key,
      required this.month,
      required this.cleanCalendarController,
      required this.calendarCrossAxisSpacing,
      required this.beautifyBlockedDates,
      required this.disableSelection,
      required this.calendarMainAxisSpacing,
      required this.layout,
      required this.dayBuilder,
      required this.selectedBackgroundColor,
      required this.backgroundColor,
      required this.selectedBackgroundColorBetween,
      required this.disableBackgroundColor,
      required this.dayDisableColor,
      required this.radius,
      required this.textStyle,
      required this.blockedDatesList,
      required this.strikeUnSelectableDates,
      required this.bookedDates})
      : super(key: key);

  (bool, List<BookedDatesModel>) isDateBooked(DateTime inputDate) {
    List<BookedDatesModel> ls = [];

    for (int i = 0; i < bookedDates.length; i++) {
      var bookedDate = bookedDates[i];

      // Check if the input date is between the start and end dates of the booked date

      if (inputDate.isSameDayOrAfter(bookedDate.startDate) &&
          inputDate.isSameDayOrBefore(bookedDate.endDate)) {
        ls.add(bookedDate);
      }
    }
    return (ls.isNotEmpty, ls); // Date is available
  }

  @override
  Widget build(BuildContext context) {
    // Start weekday - Days per week - The first weekday of this month
    // 7 - 7 - 1 = -1 = 1
    // 6 - 7 - 1 = -2 = 2

    // What it means? The first weekday does not change, but the start weekday have changed,
    // so in the layout we need to change where the calendar first day is going to start.
    int monthPositionStartDay = (cleanCalendarController.weekdayStart -
            DateTime.daysPerWeek -
            DateTime(month.year, month.month).weekday)
        .abs();
    monthPositionStartDay = monthPositionStartDay > DateTime.daysPerWeek
        ? monthPositionStartDay - DateTime.daysPerWeek
        : monthPositionStartDay;

    final start = monthPositionStartDay == 7 ? 0 : monthPositionStartDay;

    // If the monthPositionStartDay is equal to 7, then in this layout logic will cause a trouble, beacause it will
    // have a line in blank and in this case 7 is the same as 0.

    return GridView.count(
      crossAxisCount: DateTime.daysPerWeek,
      physics: const NeverScrollableScrollPhysics(),
      addRepaintBoundaries: false,
      padding: EdgeInsets.zero,
      // childAspectRatio: 1.5,
      crossAxisSpacing: calendarCrossAxisSpacing,
      mainAxisSpacing: calendarMainAxisSpacing,
      shrinkWrap: true,
      children: List.generate(
          DateTime(month.year, month.month + 1, 0).day + start, (index) {
        if (index < start) return const SizedBox.shrink();
        final day = DateTime(month.year, month.month, (index + 1 - start));
        final text = (index + 1 - start).toString();

        bool isSelected = false;

        if (cleanCalendarController.rangeMinDate != null) {
          if (cleanCalendarController.rangeMinDate != null &&
              cleanCalendarController.rangeMaxDate != null) {
            isSelected = day
                    .isSameDayOrAfter(cleanCalendarController.rangeMinDate!) &&
                day.isSameDayOrBefore(cleanCalendarController.rangeMaxDate!);
          } else {
            isSelected =
                day.isAtSameMomentAs(cleanCalendarController.rangeMinDate!);
          }
        }

        Widget widget;

        var (a, b) = isDateBooked(day);

        // if (a) {
        //   print(
        //       '==========>> ${b.length} :::: ${b.first.startDate} -- ${b.first.endDate}');
        // }

        final dayValues = DayValues(
          day: day,
          isBlocked: blockedDatesList.contains(day),
          isBooked: a,
          bookedDatesModel: b,
          isFirstDayOfWeek: day.weekday == cleanCalendarController.weekdayStart,
          isLastDayOfWeek: day.weekday == cleanCalendarController.weekdayEnd,
          isSelected: isSelected,
          maxDate: cleanCalendarController.maxDate,
          minDate: cleanCalendarController.minDate,
          text: text,
          selectedMaxDate: cleanCalendarController.rangeMaxDate,
          selectedMinDate: cleanCalendarController.rangeMinDate,
        );

        if (dayBuilder != null) {
          widget = dayBuilder!(context, dayValues);
        } else {
          widget = <Layout, Widget Function()>{
            Layout.DEFAULT: () => _pattern(context, dayValues),
            Layout.BEAUTY: () {
              return _beauty(context, dayValues);
            },
          }[layout]!();
        }

        return GestureDetector(
          onTap: () {
            if (dayValues.isBlocked || disableSelection) {
              return;
            }

            if (day.isBefore(cleanCalendarController.minDate) &&
                !day.isSameDay(cleanCalendarController.minDate)) {
              if (cleanCalendarController.onPreviousMinDateTapped != null) {
                cleanCalendarController.onPreviousMinDateTapped!(day);
              }
            } else if (day.isAfter(cleanCalendarController.maxDate)) {
              if (cleanCalendarController.onAfterMaxDateTapped != null) {
                cleanCalendarController.onAfterMaxDateTapped!(day);
              }
            } else {
              if (!cleanCalendarController.readOnly) {
                cleanCalendarController.onDayClick(day);
              }
            }
          },
          child: widget,
        );
      }),
    );
  }

  Widget _pattern(BuildContext context, DayValues values) {
    Color bgColor = backgroundColor ?? Theme.of(context).colorScheme.surface;
    TextStyle txtStyle =
        (textStyle ?? Theme.of(context).textTheme.bodyLarge)!.copyWith(
      color: getSurfaceColor(
          backgroundColor ?? Theme.of(context).colorScheme.onSurface),
    );

    if (values.isSelected) {
      if ((values.selectedMinDate != null &&
              values.day.isSameDay(values.selectedMinDate!)) ||
          (values.selectedMaxDate != null &&
              values.day.isSameDay(values.selectedMaxDate!))) {
        bgColor =
            selectedBackgroundColor ?? Theme.of(context).colorScheme.primary;
        txtStyle =
            (textStyle ?? Theme.of(context).textTheme.bodyLarge)!.copyWith(
          color: getSurfaceColor(selectedBackgroundColor ??
              Theme.of(context).colorScheme.onPrimary),
        );
      } else {
        bgColor = (selectedBackgroundColorBetween ??
                Theme.of(context).colorScheme.primary)
            .withOpacity(.2);
        txtStyle =
            (textStyle ?? Theme.of(context).textTheme.bodyLarge)!.copyWith(
          color: getSurfaceColor(
              selectedBackgroundColor ?? Theme.of(context).colorScheme.primary),
        );
      }
    } else if (values.day.isSameDay(values.minDate)) {
      bgColor = Colors.transparent;
      txtStyle = (textStyle ?? Theme.of(context).textTheme.bodyLarge)!.copyWith(
        color: getSurfaceColor(
            selectedBackgroundColor ?? Theme.of(context).colorScheme.primary),
      );
    } else if ((values.day.isBefore(values.minDate) ||
            values.day.isAfter(values.maxDate)) &&
        strikeUnSelectableDates) {
      bgColor = disableBackgroundColor ??
          Theme.of(context).colorScheme.surface.withOpacity(.4);
      txtStyle = (textStyle ?? Theme.of(context).textTheme.bodyLarge)!.copyWith(
        color: getSurfaceColor(dayDisableColor ??
            Theme.of(context).colorScheme.onSurface.withOpacity(.5)),
        decoration: TextDecoration.lineThrough,
      );
    }

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(radius),
        border: values.day.isSameDay(values.minDate)
            ? Border.all(
                color: selectedBackgroundColor ??
                    Theme.of(context).colorScheme.primary,
                width: 2,
              )
            : null,
      ),
      child: Text(
        values.text,
        textAlign: TextAlign.center,
        style: txtStyle,
      ),
    );
  }

  Color getSurfaceColor(Color color) {
    return color.computeLuminance() < .5 ? Colors.black : Colors.white;
  }

  Widget _beauty(BuildContext context, DayValues values) {
    BorderRadiusGeometry? borderRadius;
    Color bgColor = Colors.transparent;

    bool showIcon = false;
    String iconLink = '';

    BorderRadiusGeometry? overlayBorderRadius;
    Color overlayBgColor = Colors.transparent;

    BorderRadiusGeometry? extraOverlayBorderRadius;
    Color extraOverlayBgColor = Colors.transparent;

    TextStyle txtStyle =
        (textStyle ?? Theme.of(context).textTheme.bodyLarge)!.copyWith(
      color: getSurfaceColor(
          backgroundColor ?? Theme.of(context).colorScheme.onSurface),
      // fontWeight: values.isFirstDayOfWeek || values.isLastDayOfWeek
      //     ? FontWeight.bold
      //     : null,
      fontSize: 14,
      height: 0.07,
      fontWeight: FontWeight.w400,
    );

    if (values.isSelected && !values.isBooked) {
      if (values.isFirstDayOfWeek) {
        // borderRadius = BorderRadius.all(Radius.circular(radius));
        borderRadius = BorderRadius.only(
          topLeft: Radius.circular(radius),
          bottomLeft: Radius.circular(radius),
        );
      } else if (values.isLastDayOfWeek) {
        // borderRadius = BorderRadius.all(Radius.circular(radius));
        borderRadius = BorderRadius.only(
          topRight: Radius.circular(radius),
          bottomRight: Radius.circular(radius),
        );
      }

      if ((values.selectedMinDate != null &&
              values.day.isSameDay(values.selectedMinDate!)) ||
          (values.selectedMaxDate != null &&
              values.day.isSameDay(values.selectedMaxDate!))) {
        bgColor =
            selectedBackgroundColor ?? Theme.of(context).colorScheme.primary;
        overlayBgColor = (selectedBackgroundColorBetween ??
                Theme.of(context).colorScheme.primary)
            .withOpacity(.2);
        txtStyle =
            (textStyle ?? Theme.of(context).textTheme.bodyLarge)!.copyWith(
          color: getSurfaceColor(selectedBackgroundColor ??
              Theme.of(context).colorScheme.onPrimary),
          fontWeight: FontWeight.bold,
        );

        if (values.selectedMinDate == values.selectedMaxDate) {
          borderRadius = BorderRadius.circular(radius);
        } else if (values.selectedMinDate != null &&
            values.day.isSameDay(values.selectedMinDate!)) {
          borderRadius = BorderRadius.all(Radius.circular(radius));
          overlayBorderRadius = BorderRadius.only(
            topLeft: Radius.circular(radius),
            bottomLeft: Radius.circular(radius),
          );
        } else if (values.selectedMaxDate != null &&
            values.day.isSameDay(values.selectedMaxDate!)) {
          borderRadius = BorderRadius.all(Radius.circular(radius));
          overlayBorderRadius = BorderRadius.only(
            topRight: Radius.circular(radius),
            bottomRight: Radius.circular(radius),
          );
        }
      } else {
        bgColor = (selectedBackgroundColorBetween ??
                Theme.of(context).colorScheme.primary)
            .withOpacity(.2);
        txtStyle =
            (textStyle ?? Theme.of(context).textTheme.bodyLarge)!.copyWith(
          color: getSurfaceColor(
              selectedBackgroundColor ?? Theme.of(context).colorScheme.primary),
          // fontWeight: values.isFirstDayOfWeek || values.isLastDayOfWeek
          //     ? FontWeight.bold
          //     : null,
        );
      }

      if (values.selectedMinDate != null && values.selectedMaxDate == null) {
        overlayBorderRadius = BorderRadius.all(Radius.circular(radius));
      } else if (values.selectedMinDate == null &&
          values.selectedMaxDate != null) {
        overlayBorderRadius = BorderRadius.all(Radius.circular(radius));
      }
    } else if (values.day.isSameDay(values.minDate)) {
    } else if (values.day.isBefore(values.minDate) ||
        values.day.isAfter(values.maxDate)) {
      txtStyle = (textStyle ?? Theme.of(context).textTheme.bodyLarge)!.copyWith(
        color: getSurfaceColor(dayDisableColor ??
            Theme.of(context).colorScheme.onSurface.withOpacity(.5)),
        decoration: strikeUnSelectableDates ? TextDecoration.lineThrough : null,
        fontWeight: values.isFirstDayOfWeek || values.isLastDayOfWeek
            ? FontWeight.bold
            : null,
      );
    }

    if (values.isBlocked) {
      txtStyle = (textStyle ?? Theme.of(context).textTheme.bodyLarge)!.copyWith(
        color: getSurfaceColor(dayDisableColor ??
            Theme.of(context).colorScheme.onSurface.withOpacity(.5)),
        decoration: strikeUnSelectableDates ? TextDecoration.lineThrough : null,
        fontWeight: values.isFirstDayOfWeek || values.isLastDayOfWeek
            ? FontWeight.bold
            : null,
      );
    }

    if (bookedDates.isNotEmpty &&
        beautifyBlockedDates &&
        values.isBooked &&
        values.bookedDatesModel.isNotEmpty) {
      bool isSelected = values.day
              .isSameDayOrAfter(values.bookedDatesModel.first.startDate) &&
          values.day.isSameDayOrBefore(values.bookedDatesModel.first.endDate);

      if (isSelected) {
        if (values.isFirstDayOfWeek) {
          // borderRadius = BorderRadius.all(Radius.circular(radius));
          borderRadius = BorderRadius.only(
            topLeft: Radius.circular(radius),
            bottomLeft: Radius.circular(radius),
          );
        } else if (values.isLastDayOfWeek) {
          // borderRadius = BorderRadius.all(Radius.circular(radius));
          borderRadius = BorderRadius.only(
            topRight: Radius.circular(radius),
            bottomRight: Radius.circular(radius),
          );
        }

        if ((values.day.isSameDay(values.bookedDatesModel.first.startDate)) ||
            (values.day.isSameDay(values.bookedDatesModel.first.endDate))) {
          bgColor = values.bookedDatesModel.first.bgColor ??
              Theme.of(context).colorScheme.primary;

          overlayBgColor = (values.bookedDatesModel.first.bgColor ??
                  Theme.of(context).colorScheme.primary)
              .withOpacity(.2);
          txtStyle =
              (textStyle ?? Theme.of(context).textTheme.bodyLarge)!.copyWith(
            color: getSurfaceColor(selectedBackgroundColor ??
                Theme.of(context).colorScheme.onPrimary),
            fontWeight: FontWeight.bold,
          );

          if (values.bookedDatesModel.first.startDate ==
              values.bookedDatesModel.first.endDate) {
            borderRadius = BorderRadius.circular(radius);
          } else if (values.day
              .isSameDay(values.bookedDatesModel.first.startDate)) {
            borderRadius = BorderRadius.all(Radius.circular(radius));
            overlayBorderRadius = BorderRadius.only(
              topLeft: Radius.circular(radius),
              bottomLeft: Radius.circular(radius),
            );
          } else if (values.day
              .isSameDay(values.bookedDatesModel.first.endDate)) {
            borderRadius = BorderRadius.all(Radius.circular(radius));
            overlayBorderRadius = BorderRadius.only(
              topRight: Radius.circular(radius),
              bottomRight: Radius.circular(radius),
            );
          }

          if (values.day.isSameDay(values.bookedDatesModel.first.startDate)) {
            showIcon = true;
            iconLink = values.bookedDatesModel.first.icon ?? '';
          }

          if (values.day.isSameDay(values.bookedDatesModel.first.endDate)) {
            if (values.bookedDatesModel.length > 1) {
              if (values.day.isSameDay(values.bookedDatesModel[1].startDate)) {
                showIcon = true;
                iconLink = values.bookedDatesModel[1].icon ?? '';
                borderRadius = BorderRadius.circular(radius);
                overlayBorderRadius = BorderRadius.only(
                  topLeft: Radius.circular(radius),
                  bottomLeft: Radius.circular(radius),
                );
                overlayBgColor = (values.bookedDatesModel[1].bgColor ??
                        Theme.of(context).colorScheme.primary)
                    .withOpacity(.2);

                extraOverlayBgColor = (values.bookedDatesModel.first.bgColor ??
                        Theme.of(context).colorScheme.primary)
                    .withOpacity(.2);
                extraOverlayBorderRadius = BorderRadius.only(
                  topRight: Radius.circular(radius),
                  bottomRight: Radius.circular(radius),
                );

                // overlayBorderRadius = BorderRadius.circular(radius);
              }
            }
          }
        } else {
          bgColor = (values.bookedDatesModel.first.bgColor ??
                  Theme.of(context).colorScheme.primary)
              .withOpacity(.2);
          txtStyle =
              (textStyle ?? Theme.of(context).textTheme.bodyLarge)!.copyWith(
            color: getSurfaceColor(selectedBackgroundColor ??
                Theme.of(context).colorScheme.primary),
            // fontWeight: values.isFirstDayOfWeek || values.isLastDayOfWeek
            //     ? FontWeight.bold
            //     : null,
          );
        }
        // overlayBorderRadius = BorderRadius.zero;
        // overlayBorderRadius = BorderRadius.all(Radius.circular(radius));

        // if (values.selectedMinDate != null && values.selectedMaxDate == null) {
        //   overlayBorderRadius = BorderRadius.all(Radius.circular(radius));
        // } else if (values.selectedMinDate == null &&
        //     values.selectedMaxDate != null) {
        //   overlayBorderRadius = BorderRadius.all(Radius.circular(radius));
        // }
      } else if (values.day.isSameDay(values.minDate)) {
      } else if (values.day.isBefore(values.bookedDatesModel.first.startDate) ||
          values.day.isAfter(values.maxDate)) {
        txtStyle =
            (textStyle ?? Theme.of(context).textTheme.bodyLarge)!.copyWith(
          color: getSurfaceColor(dayDisableColor ??
              Theme.of(context).colorScheme.onSurface.withOpacity(.5)),
          fontSize: 14,
          height: 0.07,
          decoration:
              strikeUnSelectableDates ? TextDecoration.lineThrough : null,
          fontWeight: values.isFirstDayOfWeek || values.isLastDayOfWeek
              ? FontWeight.bold
              : null,
        );
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: extraOverlayBgColor,
        borderRadius: extraOverlayBorderRadius,
        // shape: BoxShape.circle
      ),
      child: Container(
        // width: 28, height: 28,
        decoration: BoxDecoration(
          color: overlayBgColor,
          borderRadius: overlayBorderRadius,
          // shape: BoxShape.circle
        ),
        child: showIcon
            ? CachedNetworkImageItem(
                iconLink,
                radius: 100,
              )
            : Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: borderRadius,
                  // shape: BoxShape.circle
                ),
                child: Text(
                  values.text,
                  textAlign: TextAlign.center,
                  style: txtStyle,
                ),
              ),
      ),
    );
  }
}
