import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/buttons/back_button_widget.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class CustomerInvoiceScreen extends StatelessWidget {
  const CustomerInvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.instance.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
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
                    const Gap(width: 16),
                    AppText(text: "Work details", fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.instance.textColor),
                  ],
                ),
                const Gap(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.instance.containerBackground, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: "Emergency Bathroom Pipe Repair & Leakage sealing",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.instance.black,
                      ),
                      const Gap(height: 8),

                      AppText(
                        text: "That's the complete Contractor journey end-to-end. Let me know if you want the Super Admin flow next.",
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.instance.gray4B,
                      ),
                      const Gap(height: 16),

                      // Timings & Status Section
                      _buildLabelValueRow("Start time", "05:15 Pm (09/05/2026)"),
                      const Gap(height: 8),
                      _buildLabelValueRow("End time", "05:15 Pm 10/05/2026"),
                      const Gap(height: 8),
                      _buildLabelValueRow("Statas", "Complete"),
                      const Gap(height: 16),

                      Divider(color: AppColors.instance.gray4B.withValues(alpha: 0.2), height: 1),
                      const Gap(height: 16),

                      // Technician & Breakdown Costs Section
                      _buildLabelValueRow("Technician name", "Ronald Richards"),
                      const Gap(height: 8),
                      _buildLabelValueRow("Labor (4h @ €65/hr)", "€260"),
                      const Gap(height: 8),
                      _buildLabelValueRow("Materials Cost", "€120"),
                      const Gap(height: 8),
                      _buildLabelValueRow("Parts & Seals", "€80"),
                      const Gap(height: 16),

                      Divider(color: AppColors.instance.gray4B.withValues(alpha: 0.2), height: 1),
                      const Gap(height: 16),

                      // Totals Breakdown Section
                      _buildLabelValueRow("Subtotal (Net)", "€460.00"),
                      const Gap(height: 8),
                      _buildLabelValueRow("VAT Amount (6%)", "€27.60"),
                      const Gap(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppText(text: "Grand total", fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.instance.black),
                          AppText(text: "€487", fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.instance.black),
                        ],
                      ),
                      const Gap(height: 24),

                      // Action Button: Download Invoice
                      AppButton(
                        onTap: () {},
                        title: "Download Invoice",
                        backgroundColor: AppColors.instance.primary,
                        titleColor: AppColors.instance.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        borderRadius: BorderRadius.circular(10),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabelValueRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(text: label, fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.instance.black),
        AppText(text: value, fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.instance.black),
      ],
    );
  }
}
