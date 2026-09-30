import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/utils/app_size.dart';
import 'package:belwork/utils/languages/language_provider.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class LanguageModel {
  final String name;
  final String code;

  const LanguageModel({required this.name, required this.code});
}

const List<LanguageModel> _supportedLanguages = [
  LanguageModel(name: "English", code: "en_US"),
  LanguageModel(name: "Français", code: "fr_FR"),
  LanguageModel(name: "Néerlandais", code: "nl_NL"),
  LanguageModel(name: "Allemand", code: "de_DE"),
  LanguageModel(name: "Polonais", code: "pl_PL"),
 // LanguageModel(name: "Anglais (UK)", code: "en_GB"),
  LanguageModel(name: "Ukrainien", code: "uk_UA"),
  LanguageModel(name: "Bulgare", code: "bg_BG"),
  LanguageModel(name: "Arabe", code: "ar_SA"),
  LanguageModel(name: "Turc", code: "tr_TR"),
  LanguageModel(name: "Roumain", code: "ro_RO"),
  LanguageModel(name: "Espagnol", code: "es_ES"),
  LanguageModel(name: "Italien", code: "it_IT"),
  LanguageModel(name: "Portugais", code: "pt_PT"),
];

class AllLanguageScreen extends ConsumerStatefulWidget {
  const AllLanguageScreen({super.key});

  @override
  ConsumerState<AllLanguageScreen> createState() => _AllLanguageScreenState();
}

class _AllLanguageScreenState extends ConsumerState<AllLanguageScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredLanguages = _supportedLanguages.where((lang) {
      if (_searchQuery.trim().isEmpty) return true;
      return lang.name.toLowerCase().contains(_searchQuery.toLowerCase().trim()) ||
          lang.code.toLowerCase().contains(_searchQuery.toLowerCase().trim());
    }).toList();

    final selectedLanguage = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              leading: GestureDetector(
                onTap: () {
                  AppRoutes.instance.pop();
                },
                child: Icon(Icons.arrow_back_outlined, color: AppColors.instance.black07),
              ),
              backgroundColor: AppColors.instance.background,
              surfaceTintColor: AppColors.instance.background,
              title: _isSearching
                  ? TextField(
                      controller: _searchController,
                      autofocus: true,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search language...",
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: AppColors.instance.gray500, fontSize: 16),
                      ),
                      style: TextStyle(color: AppColors.instance.black07, fontSize: 16),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppText(
                            text: "My language",
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: AppColors.instance.black07,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isSearching = true;
                              });
                            },
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.withValues(alpha: 0.2)),
                              child: const Icon(Icons.search),
                            ),
                          ),
                        ],
                      ),
                    ),
              actions: _isSearching
                  ? [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _isSearching = false;
                            _searchQuery = "";
                            _searchController.clear();
                          });
                        },
                      ),
                    ]
                  : null,
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final language = filteredLanguages[index];
                  final isSelected = selectedLanguage == language.code;

                  return GestureDetector(
                    onTap: () {
                      ref.read(languageProvider.notifier).setLanguage(language.code);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        height: AppSize.height(value: 40),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? AppColors.instance.primary : Colors.grey,
                            width: isSelected ? 1.8 : 1.0,
                          ),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(
                              text: language.name,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? AppColors.instance.primary : AppColors.instance.bodyText,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.instance.green59),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(2),
                              child: isSelected
                                  ? Icon(Icons.check_circle, color: AppColors.instance.green59, size: 18)
                                  : const SizedBox(height: 18, width: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }, childCount: filteredLanguages.length),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0).copyWith(bottom: 20),
          child: AppButton(
            onTap: () {
              AppRoutes.instance.pop();
            },
            height: 50,
            title: "Next",
          ),
        ),
      ),
    );
  }
}
