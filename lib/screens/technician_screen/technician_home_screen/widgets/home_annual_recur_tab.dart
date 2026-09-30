import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/screens/technician_screen/technician_home_screen/provider/technician_opportunity_provider.dart';
import 'package:belwork/widgets/texts/app_text.dart';
import 'technician_opportunity_card.dart';

class HomeAnnualRecurTab extends ConsumerWidget {
  const HomeAnnualRecurTab({super.key});

  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  static String _formatInspectMonth(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final parsed = DateTime.tryParse(dateStr);
      if (parsed != null) {
        return _months[parsed.month - 1];
      }
      return dateStr;
    } catch (_) {
      return dateStr;
    }
  }

  static String _getBadgeText(String? recurrenceType) {
    if (recurrenceType == 'ANNUAL_INSPECTION') {
      return 'Annual recur';
    } else if (recurrenceType == 'REGULAR') {
      return 'REGULAR';
    }
    return recurrenceType ?? 'Annual recur';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(technicianOpportunityProvider);

    return jobsAsync.when(
      data: (allJobs) {
        final annualRecurJobs = allJobs.where((item) {
          final recur = item.recurrenceType ?? '';
          return recur == 'ANNUAL_INSPECTION';
        }).toList();

        if (annualRecurJobs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Center(
              child: AppText(
                text: "No annual recur opportunities found",
                fontSize: 14,
                color: AppColors.instance.gray500,
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: annualRecurJobs.length,
          itemBuilder: (context, index) {
            final item = annualRecurJobs[index];
            final badgeStr = _getBadgeText(item.recurrenceType);
            final inspectMonth = _formatInspectMonth(item.wishRepairDate);
            final customerNameStr = item.user?.name != null
                ? item.user!.name!
                : (item.user?.email ?? '');

            return TechnicianOpportunityCard(
              urgencyText: (item.urgency != null && item.urgency!.isNotEmpty)
                  ? item.urgency
                  : item.region,
              urgencyColor: const Color(0xFFF58220),
              badgeText: badgeStr,
              badgeColor: const Color(0xFFF07D1E),
              badgeTextColor: Colors.black,
              title: item.title ?? item.homeAsset ?? 'Opportunity Job',
              subtitlePrefix: inspectMonth.isNotEmpty
                  ? "Target recurrent inspect: "
                  : (item.region != null ? "Location: " : null),
              subtitleHighlight: inspectMonth.isNotEmpty
                  ? inspectMonth
                  : (item.region ?? ''),
              description: item.description,
              customerName: customerNameStr,
              images: item.images,
              onChatTap: () {
                AppRoutes.instance.pushNamed(
                    AppRoutesKey.instance.technicianQuotationToCustomerScreen,
                    extra: item);
              },
            );
          },
        );
      },
      loading: () => ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 2,
        itemBuilder: (context, index) {
          return Container(
            height: 180,
            margin: const EdgeInsets.only(bottom: 22),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
      ),
      error: (err, stack) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: AppText(
            text: "Failed to load annual recur opportunities",
            fontSize: 14,
            color: AppColors.instance.red73,
          ),
        ),
      ),
    );
  }
}
