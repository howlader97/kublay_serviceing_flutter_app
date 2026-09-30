import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/screens/technician_screen/technician_manage_screen/widgets/add_catelog_dialog.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class CatelogButton extends StatelessWidget {
  const CatelogButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(text: "Catalog", fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.instance.textColor),
        GestureDetector(
          onTap: () {
            showDialog<Map<String, dynamic>>(context: context, builder: (_) => const AddCatalogDialog());
          },
          child: AppText(text: "Add new", fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.instance.primary),
        ),
      ],
    );
  }
}
