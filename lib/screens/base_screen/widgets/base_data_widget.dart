import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/constant/app_constant.dart';
import 'package:belwork/utils/app_size.dart';
import 'package:belwork/widgets/texts/app_html_text.dart';

class BaseDataWidget extends StatelessWidget {
  const BaseDataWidget({super.key, required this.data});
  final String data;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18,vertical: 18),
      padding: EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.instance.containerBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppSize.width(value: 20)),

        child: AppHtmlWidget(
          html: data,
          textStyle: TextStyle(fontFamily: AppConstant.instance.font, height: 1.5, color: AppColors.instance.dark600),
        ),
      ),
    );
  }
}
