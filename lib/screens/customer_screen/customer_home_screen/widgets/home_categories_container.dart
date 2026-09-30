import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/models/service_category_response.dart';
import 'package:belwork/widgets/app_image/app_image.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class HomeCategoriesContainer extends StatelessWidget {
  const HomeCategoriesContainer({
    super.key,
    required this.category,
  });

  final ServiceCategoryModel? category;

  @override
  Widget build(BuildContext context) {
    final String title = category?.name ?? '';
    final String rawDescription = (category?.description ?? '').trim();
    final String description = rawDescription.isNotEmpty
        ? '${rawDescription[0].toUpperCase()}${rawDescription.substring(1)}'
        : '';
    final String imageUrl = category?.avatar ?? '';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.instance.containerBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              child: AppImage(
                url: imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: title,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.instance.textColor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  isDynamic: true,

                ),
                const SizedBox(height: 2),
                AppText(
                  text: description,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.instance.bodyText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
