import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class TechnicianMonthCalendarWidget extends StatefulWidget {
  final DateTime? initialSelectedDate;
  final ValueChanged<DateTime?>? onDateSelected;

  const TechnicianMonthCalendarWidget({super.key, this.initialSelectedDate, this.onDateSelected});

  @override
  State<TechnicianMonthCalendarWidget> createState() => _TechnicianMonthCalendarWidgetState();
}

class _TechnicianMonthCalendarWidgetState extends State<TechnicianMonthCalendarWidget> {
  late DateTime _focusedMonth;
  late DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = widget.initialSelectedDate ?? DateTime.now();
    _focusedMonth = DateTime(now.year, now.month, 1);
    _selectedDate = widget.initialSelectedDate;
  }

  String _getMonthYearString(DateTime date) {
    const months = ["JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"];
    return "${months[date.month - 1]} ${date.year}";
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final year = _focusedMonth.year;
    final month = _focusedMonth.month;

    final firstDayOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final offset = firstDayOfMonth.weekday - 1; // Monday = 1 -> offset 0
    final totalGridItems = offset + daysInMonth;

    const weekDays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.instance.containerBackground, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          // Month navigation header
          Row(
            children: [
              IconButton(
                color: AppColors.instance.textColor,
                onPressed: _previousMonth,
                icon: const Icon(Icons.chevron_left, size: 24),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const Gap(width: 8),
              AppText(text: _getMonthYearString(_focusedMonth), fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.instance.textColor),
              const Spacer(),
              IconButton(
                color: AppColors.instance.textColor,
                onPressed: _nextMonth,
                icon: const Icon(Icons.chevron_right, size: 24),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const Gap(height: 16),

          // Weekday header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.map((day) {
              return SizedBox(
                width: 39,
                child: Center(
                  child: AppText(text: day, fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.instance.gray4B),
                ),
              );
            }).toList(),
          ),
          const Gap(height: 12),

          // Calendar GridView
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalGridItems,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 10, crossAxisSpacing: 6),
            itemBuilder: (context, index) {
              if (index < offset) {
                return const SizedBox();
              }

              final dayNumber = index - offset + 1;
              final currentDate = DateTime(year, month, dayNumber);
              final isSelected = _isSameDay(_selectedDate, currentDate);

              return GestureDetector(
                onTap: () {
                  final isAlreadySelected = _isSameDay(_selectedDate, currentDate);
                  setState(() {
                    if (isAlreadySelected) {
                      _selectedDate = null;
                    } else {
                      _selectedDate = currentDate;
                    }
                  });
                  if (widget.onDateSelected != null) {
                    widget.onDateSelected!(_selectedDate);
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.instance.primary : AppColors.instance.white,
                    border: isSelected ? Border.all(color: const Color(0xFF007AFF), width: 2.5) : null,
                  ),
                  child: AppText(
                    text: dayNumber.toString(),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: isSelected ? AppColors.instance.white : AppColors.instance.textColor,
                  ),
                ),
              );
            },
          ),
          const Gap(height: 20),

          // Legend Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(color: AppColors.instance.primary, shape: BoxShape.circle),
                  ),
                  const Gap(width: 6),
                  AppText(text: "Task", fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.instance.gray4B),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(color: Color(0xFF007AFF), shape: BoxShape.circle),
                  ),
                  const Gap(width: 6),
                  AppText(text: "Select", fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.instance.gray4B),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.instance.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.instance.gray300, width: 1),
                    ),
                  ),
                  const Gap(width: 6),
                  AppText(text: "Free", fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.instance.gray4B),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
