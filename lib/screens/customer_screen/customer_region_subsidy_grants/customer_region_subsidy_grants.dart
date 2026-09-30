import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/models/subsidy_response.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/screens/customer_screen/customer_region_subsidy_grants/provider/subsidy_provider.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/buttons/back_button_widget.dart';
import 'package:belwork/widgets/inputs/app_input_widget_tow.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class CustomerRegionSubsidyGrants extends ConsumerStatefulWidget {
  const CustomerRegionSubsidyGrants({super.key});

  @override
  ConsumerState<CustomerRegionSubsidyGrants> createState() =>
      _CustomerRegionSubsidyGrantsState();
}

class _CustomerRegionSubsidyGrantsState
    extends ConsumerState<CustomerRegionSubsidyGrants> {
  final TextEditingController _regionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  final List<String> _regions = const [
    "All",
    "Brussels",
    "Flanders",
    "Wallonia",
  ];

  String _selectedRegion = "All";

  @override
  void initState() {
    super.initState();
    _regionController.text = _selectedRegion;
  }

  @override
  void dispose() {
    _regionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openUrl(String url) async {
    try {
      String formattedUrl = url.trim();
      if (!formattedUrl.startsWith('http://') &&
          !formattedUrl.startsWith('https://')) {
        formattedUrl = 'https://$formattedUrl';
      }
      final Uri uri = Uri.parse(formattedUrl);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open the link')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening link: $e')),
        );
      }
    }
  }

  void _showRegionPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.instance.containerBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Gap(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.instance.gray400.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Gap(height: 12),
              AppText(
                text: "Select Region",
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.instance.textColor,
              ),
              const Divider(),
              ..._regions.map((region) {
                final isSelected = region == _selectedRegion;
                return ListTile(
                  title: AppText(
                    text: region,
                    fontSize: 16,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w400,
                    color: isSelected
                        ? AppColors.instance.primary
                        : AppColors.instance.textColor,
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: AppColors.instance.primary)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedRegion = region;
                      _regionController.text = region;
                    });
                    Navigator.pop(context);
                    _applyFilter();
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _applyFilter() {
    ref.read(subsidyProvider.notifier).filterSubsidies(
          region: _selectedRegion == "All" ? null : _selectedRegion,
          query: _searchController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final subsidiesAsync = ref.watch(subsidyProvider);

    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  BackButtonWidget(
                    onTap: () {
                      AppRoutes.instance.pop();
                    },
                  ),
                  const Gap(width: 12),
                  Expanded(
                    child: AppText(
                      text: "Regional subsidy grants",
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.instance.textColor,
                    ),
                  ),
                ],
              ),
              const Gap(height: 20),

              AppInputWidgetTwo(
                title: "Region",
                controller: _regionController,
                readOnly: true,
                hintText: "Select Region",
                suffixIcon: const Icon(Icons.keyboard_arrow_down),
                onTap: _showRegionPicker,
              ),

              // Subsidy search field
              AppInputWidgetTwo(
                title: "Subsidy for",
                controller: _searchController,
                hintText: "Search subsidies...",
                suffixIcon: const Icon(Icons.search),
                onChanged: (_) => _applyFilter(),
              ),
              const Gap(height: 20),

              AppButton(
                title: "Search",
                height: 48,
                backgroundColor: AppColors.instance.primary,
                titleColor: AppColors.instance.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                borderRadius: BorderRadius.circular(8),
                onTap: _applyFilter,
              ),
              const Gap(height: 20),

              // Grants List View
              Expanded(
                child: subsidiesAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, _) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText(
                          text: "Failed to load subsidies",
                          fontSize: 16,
                          color: AppColors.instance.error,
                        ),
                        const Gap(height: 10),
                        AppButton(
                          title: "Retry",
                          width: 120,
                          height: 40,
                          fontSize: 14,
                          onTap: () {
                            ref
                                .read(subsidyProvider.notifier)
                                .fetchSubsidies();
                          },
                        ),
                      ],
                    ),
                  ),
                  data: (grants) {
                    if (grants.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          await ref
                              .read(subsidyProvider.notifier)
                              .fetchSubsidies();
                        },
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            Gap(height: 60),
                            Center(
                              child: AppText(
                                text: "No subsidies found",
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        await ref
                            .read(subsidyProvider.notifier)
                            .fetchSubsidies();
                      },
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        itemCount: grants.length,
                        separatorBuilder: (context, index) =>
                            const Gap(height: 16),
                        itemBuilder: (context, index) {
                          final item = grants[index];
                          return _buildGrantCard(item);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrantCard(SubsidyItem item) {
    final amountText = (item.amount != null && item.amount!.isNotEmpty)
        ? (item.amount!.startsWith('€') ? item.amount! : '€${item.amount}')
        : '€0';

    final badge = item.region ?? "All";

    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFFECE5E8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount
              AppText(
                text: amountText,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: AppColors.instance.primary,
              ),
              const Gap(height: 2),
              // Subtitle
              AppText(
                text: "Up to the subsidy",
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.instance.gray400,
              ),
              const Gap(height: 12),
              // Grant Title
              AppText(
                text: item.title ?? "",
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.instance.textColor,
              ),
              const Gap(height: 4),
              // Grant Description
              AppText(
                text: item.description ?? "",
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.instance.gray400,
              ),
              const Gap(height: 14),
              // Action Link
              GestureDetector(
                onTap: () {
                  if (item.infoUrl != null && item.infoUrl!.trim().isNotEmpty) {
                    _openUrl(item.infoUrl!);
                  }
                },
                child: Text(
                  "Learn more",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.instance.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.instance.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            height: 42,
            width: 110,
            decoration: BoxDecoration(
              color: AppColors.instance.background,
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8)),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            constraints: const BoxConstraints(minWidth: 90),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFFF851B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: AppText(
                text: badge,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.instance.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
