import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/routes/app_routes.dart';
import 'package:belwork/utils/app_log.dart';
import 'package:belwork/utils/app_size.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/texts/app_text.dart';

void callUpComingDialog() {
  try {
    showAdaptiveDialog(
      context: rootNavigatorKey.currentContext!,
      builder: (context) => Material(
        color: AppColors.instance.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          overlayColor: WidgetStatePropertyAll(AppColors.instance.transparent),
          child: Center(child: UpComingDialog()),
        ),
      ),
    );
  } catch (e) {
    errorLog("message", e);
  }
}

class UpComingDialog extends StatelessWidget {
  const UpComingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSize.size.width * 0.7,
      padding: EdgeInsets.all(AppSize.width(value: 15.0)),
      decoration: BoxDecoration(color: AppColors.instance.gray700, borderRadius: BorderRadius.circular(AppSize.width(value: 15.0))),
      child: Column(
        spacing: AppSize.width(value: 10),
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },

              child: Icon(Icons.close),
            ),
          ),
          AppText(
            text: "Something awesome is on the way!",
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w500,
            fontSize: AppSize.width(value: 18),
          ),

          AppText(text: "We’re almost ready to show you. Get ready to be amazed.", textAlign: TextAlign.center),
          Gap(height: 10),
        ],
      ),
    );
  }
}
