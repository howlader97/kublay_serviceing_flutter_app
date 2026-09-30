import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/screens/company_employee_screen/company_agenda_screen/provider/button_provider.dart';
import 'package:belwork/screens/company_employee_screen/company_agenda_screen/provider/company_agenda_provider.dart';
import 'package:belwork/screens/company_employee_screen/company_agenda_screen/widgets/complete_task_widget.dart';
import 'package:belwork/screens/company_employee_screen/company_agenda_screen/widgets/in_progress_widget.dart';
import 'package:belwork/screens/company_employee_screen/company_agenda_screen/widgets/new_task_widget.dart';
import 'package:belwork/screens/company_employee_screen/company_agenda_screen/widgets/profile_card_widgets.dart';
import 'package:belwork/screens/company_employee_screen/company_agenda_screen/widgets/seven_day_calendar_widget.dart';
import 'package:belwork/screens/company_employee_screen/company_profile_screen/provider/company_employee_profile_provider.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class CompanyAgendaScreen extends ConsumerStatefulWidget {
  const CompanyAgendaScreen({super.key});

  @override
  ConsumerState<CompanyAgendaScreen> createState() => _CompanyAgendaScreenState();
}

class _CompanyAgendaScreenState extends ConsumerState<CompanyAgendaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(companyAgendaProvider.notifier).fetchJobs();
      ref.read(companyEmployeeProfileProvider.notifier).fetchProfile(showLoading: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectButton = ref.watch(buttonProvider);
    final agendaState = ref.watch(companyAgendaProvider);
    final profileState = ref.watch(companyEmployeeProfileProvider);

    final empUser = profileState.profileResponse?.data?.user;
    final empData = profileState.profileResponse?.data;

    final avatarUrl = (empUser?.avatar != null && empUser!.avatar!.isNotEmpty)
        ? empUser.avatar!
        : 'https://thumbs.dreamstime.com/b/default-profile-picture-avatar-photo-placeholder-vector-illustration-default-profile-picture-avatar-photo-placeholder-vector-189495158.jpg?w=768';

    final name = (empUser?.name != null && empUser!.name!.isNotEmpty)
        ? empUser.name!
        : 'update profile';

    final designation = (empData?.skill != null && empData!.skill!.isNotEmpty)
        ? empData.skill!
        : (empData?.designation != null && empData!.designation!.isNotEmpty
            ? empData.designation!
            : 'Designation');

    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.instance.primary,
          onRefresh: () async {
            await Future.wait([
              ref.read(companyAgendaProvider.notifier).fetchJobs(showLoading: false),
              ref.read(companyEmployeeProfileProvider.notifier).fetchProfile(showLoading: false),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(height: 16),
                  ProfileCardWidget(
                    image: avatarUrl,
                    title: name,
                    subTitle: designation,
                  ),
                  const Gap(height: 10),
                  SevenDayCalendarWidget(
                    onDateSelected: (selectedDate) {
                      ref.read(companyAgendaProvider.notifier).setSelectedDate(selectedDate);
                    },
                  ),
                  const Gap(height: 10),
                  AppText(
                    text: "Assigned deployment",
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.instance.textColor,
                  ),
                  const Gap(height: 8),
                  Row(
                    children: [
                      AppButton(
                        onTap: () {
                          ref.read(buttonProvider.notifier).select(0);
                        },
                        backgroundColor: selectButton == 0 ? AppColors.instance.primary : AppColors.instance.transparent,
                        borderColor: selectButton == 0 ? AppColors.instance.primary : AppColors.instance.gray4B,
                        titleColor: selectButton == 0 ? AppColors.instance.white : AppColors.instance.gray4B,
                        title: "All Task",
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        padding: const EdgeInsets.all(6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      const Gap(width: 6),
                      AppButton(
                        onTap: () {
                          ref.read(buttonProvider.notifier).select(1);
                        },
                        backgroundColor: selectButton == 1 ? AppColors.instance.primary : AppColors.instance.transparent,
                        borderColor: selectButton == 1 ? AppColors.instance.primary : AppColors.instance.gray4B,
                        titleColor: selectButton == 1 ? AppColors.instance.white : AppColors.instance.gray4B,
                        title: "InProgress",
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        padding: const EdgeInsets.all(6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      const Gap(width: 6),
                      AppButton(
                        onTap: () {
                          ref.read(buttonProvider.notifier).select(2);
                        },
                        backgroundColor: selectButton == 2 ? AppColors.instance.primary : AppColors.instance.transparent,
                        borderColor: selectButton == 2 ? AppColors.instance.primary : AppColors.instance.gray4B,
                        titleColor: selectButton == 2 ? AppColors.instance.white : AppColors.instance.gray4B,
                        title: "Complete",
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        padding: const EdgeInsets.all(6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ],
                  ),
                  const Gap(height: 20),
                  if (agendaState.isLoading)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(
                          color: AppColors.instance.primary,
                        ),
                      ),
                    )
                  else if (selectButton == 0)
                    NewTaskWidget(jobs: agendaState.allJobs)
                  else if (selectButton == 1)
                    InProgressWidget(jobs: agendaState.inProgressJobs)
                  else if (selectButton == 2)
                    CompleteTaskWidget(jobs: agendaState.finishedJobs),
                  const Gap(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
