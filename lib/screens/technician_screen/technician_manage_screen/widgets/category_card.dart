import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/app_image/app_image.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class CategoryCard extends StatelessWidget {
  final String image;
  final String title;
  final String service;
  final String priceText;
  const CategoryCard({super.key, required this.image, required this.title, required this.service, required this.priceText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppColors.instance.containerBackground),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
            child: AppImage(width: double.infinity, height: 110, url: image),
          ),
          Gap(height: 8),
          Row(
            children: [
              Expanded(
                child: AppText(text: title, fontWeight: FontWeight.w600, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              AppText(text: service, fontSize: 12, color: AppColors.instance.primary),
            ],
          ),
          Gap(height: 8),
          AppText(text: priceText, fontSize: 12,maxLines: 1,),
        ],
      ),
    );
  }
}
