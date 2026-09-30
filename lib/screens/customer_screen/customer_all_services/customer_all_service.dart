import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/screens/customer_screen/customer_home_screen/provider/service_category_provider.dart';
import 'package:belwork/screens/customer_screen/customer_home_screen/widgets/home_categories_container.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/buttons/back_button_widget.dart';
import 'package:belwork/widgets/inputs/app_input_widget.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class CustomerAllService extends ConsumerStatefulWidget {
  const CustomerAllService({super.key});

  @override
  ConsumerState<CustomerAllService> createState() => _CustomerAllServiceState();
}

class _CustomerAllServiceState extends ConsumerState<CustomerAllService> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(serviceCategoryProvider);

    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Column(
              children: [
                Row(
                  children: [
                    BackButtonWidget(
                      onTap: () {
                        AppRoutes.instance.pop();
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                    ),
                    const Gap(width: 10),
                    AppText(
                      text: "Here is all services",
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      color: AppColors.instance.black,
                    ),
                  ],
                ),
                const Gap(height: 16),
                AppInputWidget(
                  controller: _searchController,
                  fillColor: AppColors.instance.containerBackground,
                 hintStyle: TextStyle(color: Colors.black),
                  textColor: Colors.black,
                  hintText: "Search by name, location",
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                const Gap(height: 16),
                categoriesAsync.when(
                  data: (categories) {
                    final filteredCategories = categories.where((cat) {
                      if (_searchQuery.isEmpty) return true;
                      final name = cat.name?.toLowerCase() ?? '';
                      final desc = cat.description?.toLowerCase() ?? '';
                      return name.contains(_searchQuery) ||
                          desc.contains(_searchQuery);
                    }).toList();

                    if (filteredCategories.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 36),
                          child: AppText(
                            text: 'No services found',
                            fontSize: 14,
                            color: AppColors.instance.gray500,
                          ),
                        ),
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredCategories.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.96,
                        mainAxisExtent: 164,
                      ),
                      itemBuilder: (context, index) {
                        final category = filteredCategories[index];
                        return GestureDetector(
                          onTap: () {
                            AppRoutes.instance.pushNamed(
                              AppRoutesKey.instance.technicianList,
                              extra: category.id,
                            );
                          },
                          child: HomeCategoriesContainer(category: category),
                        );
                      },
                    );
                  },
                  loading: () => _buildShimmerGrid(),
                  error: (err, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: AppText(
                        text: 'Failed to load services',
                        fontSize: 14,
                        color: AppColors.instance.red73,
                      ),
                    ),
                  ),
                ),
                const Gap(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.96,
        mainAxisExtent: 164,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.instance.containerBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.instance.gray200.withValues(alpha: 0.4),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.instance.gray200.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 70,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.instance.gray200.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
