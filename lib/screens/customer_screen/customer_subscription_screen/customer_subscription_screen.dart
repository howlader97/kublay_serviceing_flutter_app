import 'package:belwork/utils/languages/app_language_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belwork/constant/app_asserts_icons_path.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/screens/customer_screen/customer_subscription_screen/provider/select_subscription_provider.dart';
import 'package:belwork/screens/customer_screen/customer_subscription_screen/widgets/subscription_card.dart';
import 'package:belwork/utils/app_size.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/app_image/app_image.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/buttons/back_button_widget.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class CustomerSubscriptionScreen extends StatelessWidget {
  const CustomerSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Row(
                  children: [
                    BackButtonWidget(
                      onTap: () {
                        AppRoutes.instance.pop();
                      },
                    ),
                    Gap(width: 15),
                    AppText(text: AppLanguageKey.subscription, fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.instance.textColor),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: ClipRRect(
                child: Align(
                  child: AppImage(path: AppAssertsIconsPath.instance.crownIcon, height: AppSize.height(value: 150)),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 38),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.instance.containerBackground.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                    border: Border(
                      top: BorderSide(color: Color(0xFFD42123), width: .5),
                      left: BorderSide(color: Color(0xFFD42123), width: .5),
                      right: BorderSide(color: Color(0xFFD42123), width: .5),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(text: "What benefit", fontWeight: FontWeight.w600, fontSize: 24, color: AppColors.instance.textColor),
                        Gap(height: 15),
                        Padding(
                          padding: const EdgeInsets.only(left: 18.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // AppText(
                              //   text: ". Unlimited encrypted messages.",
                              //   fontWeight: FontWeight.w400,
                              //   fontSize: 16,
                              //   color: AppColors.instance.textColor,
                              // ),
                              // AppText(
                              //   text: ". Unlimited secure audio and video calls.",
                              //   fontWeight: FontWeight.w400,
                              //   fontSize: 16,
                              //   color: AppColors.instance.textColor,
                              // ),
                              // AppText(text: ". Unlimited", fontWeight: FontWeight.w400, fontSize: 16, color: AppColors.instance.textColor),
                              AppText(
                                text: ". Active (no restrictions).",
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: AppColors.instance.textColor,
                              ),
                              AppText(
                                text: ". Full access to chat history + ability to draft offline messages.",
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: AppColors.instance.textColor,
                              ),
                              Gap(height: 10),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
                child: AppText(text: "Join Membership", fontWeight: FontWeight.w600, fontSize: 24, color: AppColors.instance.textColor),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Consumer(
                        builder: (context, ref, child) {
                          final select = ref.watch(selectSubscriptionProvider);
                          return SubscriptionCard(
                            onTap: () {
                              ref.read(selectSubscriptionProvider.notifier).state = 0;
                            },
                            title: 'Premium Tier',
                            subtitle: 'Billed Monthly',
                            price: '€29.99',
                            isSelected: select == 0,
                            color: select == 0 ? AppColors.instance.containerBackground : AppColors.instance.transparent,
                          );
                        },
                      ),
                    ),
                    Gap(width: 10),
                    Expanded(
                      child: Consumer(
                        builder: (context, ref, child) {
                          final select = ref.watch(selectSubscriptionProvider);
                          return SubscriptionCard(
                            onTap: () {
                              ref.read(selectSubscriptionProvider.notifier).state = 1;
                            },
                            title: 'Free Tier',
                            subtitle: 'One month free',
                            price: '€0',
                            isSelected: select == 1,
                            color: select == 1 ? AppColors.instance.containerBackground : AppColors.instance.transparent,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20),
                child: AppButton(height: 50, title: "Join Now"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
