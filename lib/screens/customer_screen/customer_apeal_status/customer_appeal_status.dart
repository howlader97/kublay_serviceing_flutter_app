import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/app_image/app_image.dart';
import 'package:belwork/widgets/buttons/back_button_widget.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class AppealStatusItemModel {
  final String id;
  final String name;
  final String avatarUrl;
  final int rating;
  final String statusText;
  final bool isAccepted;
  final String time;
  final String comment;

  const AppealStatusItemModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.rating,
    required this.statusText,
    required this.isAccepted,
    required this.time,
    required this.comment,
  });
}

class CustomerAppealStatus extends StatelessWidget {
  const CustomerAppealStatus({super.key});

  static const List<AppealStatusItemModel> appealList = [
    AppealStatusItemModel(
      id: '1',
      name: 'Eleanor Summers',
      avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=300&q=80',
      rating: 1,
      statusText: 'APPEAL ACCEPTED',
      isAccepted: true,
      time: 'Today, 16:40',
      comment: "What can I say it's fast food, it's Burger King.No different to any of the other burger kings, nice with adequate seating",
    ),
    AppealStatusItemModel(
      id: '2',
      name: 'Victoria Champain',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
      rating: 2,
      statusText: 'APPEAL REJECTED',
      isAccepted: false,
      time: 'Today, 09:12',
      comment:
          "Food, as always, is good both upstairs and downstairs is always clean (download the bk app for deals etc.) sit upstairs every time, more relaxed feel.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildHeader(), const Gap(height: 20), _buildAppealList()]),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        BackButtonWidget(
          onTap: () {
            AppRoutes.instance.pop();
          },
        ),
        const Gap(width: 14),
        AppText(text: 'Appeal statuses', fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.instance.textColor),
      ],
    );
  }

  Widget _buildAppealList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: appealList.length,
      separatorBuilder: (context, index) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 14.0),
        child: Divider(height: 1, color: Color(0xFFEBE6E8)),
      ),
      itemBuilder: (context, index) {
        final item = appealList[index];
        return _buildAppealItem(item);
      },
    );
  }

  Widget _buildAppealItem(AppealStatusItemModel item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row: Avatar, Name & Rating, Status Badge
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // User Avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: SizedBox(
                width: 44,
                height: 44,
                child: AppImage(url: item.avatarUrl, width: 44, height: 44, fit: BoxFit.cover),
              ),
            ),
            const Gap(width: 12),

            // User Name and Stars
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(text: item.name, fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.instance.textColor),
                  const Gap(height: 4),
                  Row(
                    children: List.generate(
                      item.rating,
                      (index) => const Padding(
                        padding: EdgeInsets.only(right: 3.0),
                        child: Icon(Icons.star, color: Color(0xFFFFBE00), size: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Status Badge (ACCEPTED / REJECTED)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: item.isAccepted ? const Color(0xFF6FCF97).withValues(alpha: 0.12) : const Color(0xFFFF7073).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: item.isAccepted ? const Color(0xFF6FCF97) : AppColors.instance.red73, width: 1),
              ),
              child: AppText(
                text: item.statusText,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: item.isAccepted ? const Color(0xFF27AE60) : AppColors.instance.red3c,
              ),
            ),
          ],
        ),
        const Gap(height: 10),

        // Date / Time
        AppText(text: item.time, fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.instance.gray4B),
        const Gap(height: 6),

        // Review / Comment text
        AppText(text: item.comment, fontSize: 13.5, fontWeight: FontWeight.w400, color: AppColors.instance.gray500),
      ],
    );
  }
}
