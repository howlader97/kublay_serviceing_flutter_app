import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/screens/technician_screen/technician_planner_screen/provider/technician_planner_provider.dart';
import 'package:belwork/screens/technician_screen/technician_planner_screen/widgets/all_assignment.dart';
import 'package:belwork/screens/technician_screen/technician_planner_screen/widgets/complete_assignment.dart';
import 'package:belwork/screens/technician_screen/technician_planner_screen/widgets/on_progressing_assignment.dart';
import 'package:belwork/screens/technician_screen/technician_planner_screen/widgets/technician_month_calendar_widget.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/texts/app_text.dart';
import '../../company_employee_screen/company_agenda_screen/provider/button_provider.dart';

class TechnicianPlannerScreen extends ConsumerStatefulWidget {
  const TechnicianPlannerScreen({super.key});

  @override
  ConsumerState<TechnicianPlannerScreen> createState() =>
      _TechnicianPlannerScreenState();
}

class _TechnicianPlannerScreenState
    extends ConsumerState<TechnicianPlannerScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(technicianPlannerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final select = ref.watch(buttonProvider);
    final plannerState = ref.watch(technicianPlannerProvider);

    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(technicianPlannerProvider.notifier)
                .fetchJobs(isRefresh: true);
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(height: 10),
                  AppText(
                    text: "Agenda slot management",
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.instance.textColor,
                  ),
                  const Gap(height: 20),
                  TechnicianMonthCalendarWidget(
                    initialSelectedDate: plannerState.selectedDate,
                    onDateSelected: (selectedDate) {
                      ref
                          .read(technicianPlannerProvider.notifier)
                          .selectDate(selectedDate);
                    },
                  ),
                  const Gap(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Row(
                      children: [
                        AppButton(
                          onTap: () {
                            ref.read(buttonProvider.notifier).select(0);
                          },
                          backgroundColor: select == 0
                              ? AppColors.instance.primary
                              : AppColors.instance.transparent,
                          borderColor: select == 0
                              ? AppColors.instance.primary
                              : AppColors.instance.gray4B,
                          titleColor: select == 0
                              ? AppColors.instance.white
                              : AppColors.instance.gray4B,
                          title: "All",
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          padding: const EdgeInsets.all(6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        const Gap(width: 6),
                        AppButton(
                          onTap: () {
                            ref.read(buttonProvider.notifier).select(1);
                          },
                          backgroundColor: select == 1
                              ? AppColors.instance.primary
                              : AppColors.instance.transparent,
                          borderColor: select == 1
                              ? AppColors.instance.primary
                              : AppColors.instance.gray4B,
                          titleColor: select == 1
                              ? AppColors.instance.white
                              : AppColors.instance.gray4B,
                          title: "InProgress",
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          padding: const EdgeInsets.all(6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        const Gap(width: 6),
                        AppButton(
                          onTap: () {
                            ref.read(buttonProvider.notifier).select(2);
                          },
                          backgroundColor: select == 2
                              ? AppColors.instance.primary
                              : AppColors.instance.transparent,
                          borderColor: select == 2
                              ? AppColors.instance.primary
                              : AppColors.instance.gray4B,
                          titleColor: select == 2
                              ? AppColors.instance.white
                              : AppColors.instance.gray4B,
                          title: "Complete",
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          padding: const EdgeInsets.all(6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ],
                    ),
                  ),
                  const Gap(height: 10),
                  if (plannerState.isLoading)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.instance.primary,
                        ),
                      ),
                    )
                  else ...[
                    if (select == 0)
                      AllAssignment(jobs: plannerState.jobs)
                    else if (select == 1)
                      OnProgressingAssignment(jobs: plannerState.jobs)
                    else if (select == 2)
                      CompleteAssignment(jobs: plannerState.jobs),
                    if (plannerState.isLoadingMore)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.instance.primary,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
