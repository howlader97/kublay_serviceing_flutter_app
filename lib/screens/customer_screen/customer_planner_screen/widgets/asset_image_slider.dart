import 'package:flutter/material.dart';
import 'package:belwork/screens/customer_screen/customer_planner_screen/widgets/assets_images_slider_state.dart';

class AssetImageSlider extends StatefulWidget {
  final List<String> images;

  const AssetImageSlider({super.key, required this.images});

  @override
  State<AssetImageSlider> createState() => AssetImageSliderState();
}
