import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/screens/customer_screen/customer_planner_screen/widgets/asset_image_slider.dart';
import 'package:belwork/widgets/app_image/app_image.dart';

class AssetImageSliderState extends State<AssetImageSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 150,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.images.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return AppImage(url: widget.images[index], width: double.infinity, fit: BoxFit.cover);
                  },
                ),
              ),
            ),

            if (_currentPage > 0)
              Positioned(
                left: 8,
                child: GestureDetector(
                  onTap: () {
                    _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle),
                    child: const Icon(Icons.chevron_left, color: Colors.black87, size: 22),
                  ),
                ),
              ),
            if (_currentPage < widget.images.length - 1)
              Positioned(
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(color: AppColors.instance.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.chevron_right, color: Colors.white, size: 22),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (widget.images.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.images.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentPage == index ? 24 : 16,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index ? AppColors.instance.primary : Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
