import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/app_image/app_image.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/buttons/back_button_widget.dart';
import 'package:belwork/widgets/buttons/detail_row.dart';
import 'package:belwork/services/storage/storage_services.dart';
import 'package:belwork/widgets/dialogs/login_required_dialog.dart';
import 'package:belwork/widgets/texts/app_text.dart';
import 'package:belwork/utils/languages/app_translator.dart';
import 'package:belwork/utils/languages/language_provider.dart';

class TechnicianModel {
  final String id;
  final String name;
  final String category;
  final String distance;
  final String hourlyRate;
  final String responseTime;
  final double rating;
  final String imageUrl;
  final bool isVerified;

  const TechnicianModel({
    required this.id,
    required this.name,
    required this.category,
    required this.distance,
    required this.hourlyRate,
    required this.responseTime,
    required this.rating,
    required this.imageUrl,
    this.isVerified = true,
  });
}

class CustomerTechnicianList extends ConsumerStatefulWidget {
  const CustomerTechnicianList({super.key});

  static const List<TechnicianModel> technicians = [
    TechnicianModel(
      id: '1',
      name: 'Brooklyn Simmons',
      category: 'Plumbing',
      distance: '2km',
      hourlyRate: '€65',
      responseTime: '24/7',
      rating: 4.5,
      imageUrl: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&w=800&q=80',
      isVerified: true,
    ),
    TechnicianModel(
      id: '2',
      name: 'Brooklyn Simmons',
      category: 'Plumbing',
      distance: '2km',
      hourlyRate: '€65',
      responseTime: '24/7',
      rating: 4.5,
      imageUrl: 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?auto=format&fit=crop&w=800&q=80',
      isVerified: true,
    ),
    TechnicianModel(
      id: '3',
      name: 'Alex Mercer',
      category: 'Electrician',
      distance: '3.5km',
      hourlyRate: '€70',
      responseTime: '15 min',
      rating: 4.8,
      imageUrl: 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=800&q=80',
      isVerified: true,
    ),
  ];

  @override
  ConsumerState<CustomerTechnicianList> createState() => _CustomerTechnicianListState();
}

class _CustomerTechnicianListState extends ConsumerState<CustomerTechnicianList> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: SingleChildScrollView(
          // physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const Gap(height: 16),
              _buildSosBanner(context),
              const Gap(height: 16),
              _buildSearchBar(context),
              const Gap(height: 16),

              // ListView.builder for Technicians
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: CustomerTechnicianList.technicians.length,
                itemBuilder: (context, index) {
                  final item = CustomerTechnicianList.technicians[index];
                  return _buildTechnicianCard(context, item);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        BackButtonWidget(
          onTap: () {
            AppRoutes.instance.pop();
          },
        ),
        const Gap(width: 14),
        AppText(text: 'Artisan/Technician', fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.instance.textColor),
      ],
    );
  }

  Widget _buildSosBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.instance.red73,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: const Color(0xFFFF6565).withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            decoration: BoxDecoration(color: AppColors.instance.red3c, borderRadius: BorderRadius.circular(12)),
            child: const AppText(text: 'Stop', color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: AppText(text: 'craftsman available 24/7', color: AppColors.instance.white50, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final selectedLanguage = ref.watch(languageProvider);
    const hint = 'Search by name, Service category';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(color: AppColors.instance.containerBackground, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(Icons.search, color: AppColors.instance.gray500, size: 22),
          const Gap(width: 10),
          Expanded(
            child: FutureBuilder<String>(
              key: ValueKey('${hint}_$selectedLanguage'),
              future: AppTranslator.translate(hint, selectedLanguage),
              builder: (context, snapshot) {
                final translatedHint = snapshot.data ?? hint;
                return TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: translatedHint,
                    hintStyle: TextStyle(color: AppColors.instance.gray500, fontSize: 14, fontWeight: FontWeight.w400),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicianCard(BuildContext context, TechnicianModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: AppColors.instance.containerBackground, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: AppImage(url: item.imageUrl, height: 166, width: double.infinity, fit: BoxFit.cover),
          ),

          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name & Rating Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        AppText(text: item.name, fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.instance.textColor),
                        if (item.isVerified) ...[const Gap(width: 4), const Icon(Icons.verified, color: Color(0xFF2196F3), size: 16)],
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Color(0xFFFFBE00), size: 16),
                        const Gap(width: 4),
                        AppText(text: '${item.rating}', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.instance.textColor),
                      ],
                    ),
                  ],
                ),
                const Gap(height: 8),

                DetailRow(label: 'Category', value: item.category),
                DetailRow(label: 'Distance', value: item.distance),
                DetailRow(label: 'Hourly rate', value: item.hourlyRate),
                DetailRow(label: 'Response time', value: item.responseTime),
                const Gap(height: 14),
                AppButton(
                  title: 'Chat',
                  height: 42,
                  backgroundColor: AppColors.instance.primary,
                  titleColor: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  onTap: () async {
                    final token = await StorageServices.instance.getToken();
                    if (token.trim().isEmpty) {
                      if (context.mounted) {
                        showLoginRequiredDialog(
                          context,
                          message: "You need to log in to chat with technicians.",
                        );
                      }
                      return;
                    }

                    AppRoutes.instance.pushNamed(
                      AppRoutesKey.instance.chatScreen,
                    );
                  },
                ),
                const Gap(height: 8),
                AppButton(
                  title: 'View Profile',
                  height: 42,
                  backgroundColor: Colors.transparent,
                  borderColor: AppColors.instance.primary,
                  titleColor: AppColors.instance.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  onTap: () {
                    AppRoutes.instance.pushNamed(AppRoutesKey.instance.customerToTechnicianProfile);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
