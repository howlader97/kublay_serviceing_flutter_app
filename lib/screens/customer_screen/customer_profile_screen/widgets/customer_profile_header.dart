import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/models/user_profile_model.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/routes/app_routes_key.dart';
import 'package:belwork/widgets/app_image/app_image_circular.dart';
import 'package:belwork/widgets/buttons/back_button_widget.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class CustomerProfileHeader extends StatelessWidget {
  final UserData? profile;

  const CustomerProfileHeader({super.key, this.profile});

  static const String _defaultAvatar =
      "https://thumbs.dreamstime.com/b/default-profile-picture-avatar-photo-placeholder-vector-illustration-default-profile-picture-avatar-photo-placeholder-vector-189495158.jpg?w=768";

  @override
  Widget build(BuildContext context) {
    final String avatarUrl =
        (profile?.avatar != null && profile!.avatar!.trim().isNotEmpty)
            ? profile!.avatar!
            : _defaultAvatar;
    final String name =
        (profile?.name != null && profile!.name!.trim().isNotEmpty)
            ? profile!.name!
            : "Ronald Richards";
    final String contact =
        (profile?.contact != null && profile!.contact!.trim().isNotEmpty)
            ? profile!.contact!
            : (profile?.email != null && profile!.email!.trim().isNotEmpty)
                ? profile!.email!
                : "+32 478 123 456";
    final String location =
        (profile?.address != null && profile!.address!.trim().isNotEmpty)
            ? profile!.address!
            : "Location";

    return Column(
      children: [
        Center(
          child: AppImageCircular(
            url: avatarUrl,
            height: 90,
            width: 90,
            color: AppColors.instance.containerBackground,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppText(
              text: name,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.instance.textColor14,
              isDynamic: false,
            ),
            const SizedBox(width: 8),
            BackButtonWidget(
              onTap: () {
                AppRoutes.instance
                    .pushNamed(AppRoutesKey.instance.customerProfileEdit);
              },
              width: 28,
              height: 28,
              child: const Icon(
                Icons.edit_outlined,
                color: Colors.black87,
                size: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.call_outlined,
                size: 16, color: AppColors.instance.textColor14),
            const SizedBox(width: 4),
            AppText(
              text: contact,
              fontSize: 13,
              color: AppColors.instance.textColor14,
              isDynamic: false,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on_outlined,
                size: 16, color: AppColors.instance.textColor14),
            const SizedBox(width: 4),
            AppText(
              text: location,
              fontSize: 13,
              color: AppColors.instance.textColor14,
            ),
          ],
        ),
      ],
    );
  }
}
