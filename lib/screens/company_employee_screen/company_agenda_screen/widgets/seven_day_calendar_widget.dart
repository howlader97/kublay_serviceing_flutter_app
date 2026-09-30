import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class SevenDayCalendarWidget extends StatefulWidget {
  final ValueChanged<DateTime>? onDateSelected;

  const SevenDayCalendarWidget({super.key, this.onDateSelected});

  @override
  State<SevenDayCalendarWidget> createState() => _SevenDayCalendarWidgetState();
}

class _SevenDayCalendarWidgetState extends State<SevenDayCalendarWidget> {
  late final List<DateTime> _days;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _days = List.generate(7, (index) => today.add(Duration(days: index)));
    _selectedIndex = 0; // First item is today by default
  }

  String _getWeekdayName(DateTime date) {
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return weekdays[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_days.length, (index) {
          final date = _days[index];
          final isSelected = index == _selectedIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
                if (widget.onDateSelected != null) {
                  widget.onDateSelected!(date);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.instance.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      text: _getWeekdayName(date),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: isSelected ? AppColors.instance.containerBackground : AppColors.instance.gray4B,
                      textAlign: TextAlign.center,
                    ),
                    const Gap(height: 10),
                    AppText(
                      text: date.day.toString(),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.instance.containerBackground : AppColors.instance.textColor,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
