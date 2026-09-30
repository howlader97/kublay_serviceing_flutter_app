import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/buttons/back_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/screens/base_screen/terms_and_conditions_screen/provider/terms_and_conditions_screen_provider.dart';
import 'package:belwork/screens/base_screen/widgets/base_data_widget.dart';
import 'package:belwork/screens/base_screen/widgets/base_no_found_data_widget.dart';
import 'package:belwork/widgets/texts/app_text.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.instance.white400,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Row(
                  children: [
                    BackButtonWidget(
                      onTap: () {
                        AppRoutes.instance.pop();
                      },
                    ),
                    const Gap(width: 16),
                    AppText(
                      text: "Terms & Condition",
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.instance.textColor,
                    ),
                  ],
                ),
              ),
              Consumer(
                builder: (context, ref, child) {
                  var provider = ref.watch(termsAndConditionsScreenProvider);
                  return provider.when(
                    data: (data) {
                      if (data == null ||
                          (data.content.isEmpty && data.title.isEmpty)) {
                        return BaseNoFoundDataWidget();
                      }
                      final displayContent = data.content.isNotEmpty
                          ? data.content
                          : data.title;
                      return BaseDataWidget(data: displayContent);
                    },
                    error: (error, stackTrace) => BaseNoFoundDataWidget(),
                    loading: () => Skeletonizer(
                      enabled: true,
                      child: BaseNoFoundDataWidget(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
