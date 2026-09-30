import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/app_image/app_image.dart';
import 'package:belwork/widgets/buttons/app_button.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class TechnicianOpportunityCard extends StatefulWidget {
  final String? urgencyText;
  final Color? urgencyColor;
  final String badgeText;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final String title;
  final String? subtitlePrefix;
  final String? subtitleHighlight;
  final String? description;
  final String? customerName;
  final List<String>? images;
  final String buttonTitle;
  final VoidCallback? onChatTap;

  const TechnicianOpportunityCard({
    super.key,
    this.urgencyText,
    this.urgencyColor,
    required this.badgeText,
    this.badgeColor,
    this.badgeTextColor,
    required this.title,
    this.subtitlePrefix,
    this.subtitleHighlight,
    this.description,
    this.customerName,
    this.images,
    this.buttonTitle = "Chat & Send Quotation",
    this.onChatTap,
  });

  @override
  State<TechnicianOpportunityCard> createState() => _TechnicianOpportunityCardState();
}

class _TechnicianOpportunityCardState extends State<TechnicianOpportunityCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasImages = widget.images != null && widget.images!.isNotEmpty;
    const double notchWidth = 100;
    const double notchHeight = 41;

    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      child: Stack(
        children: [
          ClipPath(
            clipper: const OpportunityCardNotchClipper(notchWidth: notchWidth, notchHeight: notchHeight, radius: 8),
            child: Container(
              width: double.infinity,
              color: AppColors.instance.containerBackground,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.urgencyText != null && widget.urgencyText!.isNotEmpty) ...[
                    _buildUrgencyBadge(widget.urgencyText!, widget.urgencyColor),
                    const Gap(height: 12),
                  ],
                  Gap(height: 8),
                  if (hasImages) ...[
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 145,
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: widget.images!.length,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPage = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                return AppImage(url: widget.images![index], width: double.infinity, fit: BoxFit.cover);
                              },
                            ),
                          ),
                        ),
                        // Left Arrow Button
                        Positioned(
                          left: 8,
                          child: GestureDetector(
                            onTap: () {
                              if (_currentPage > 0) {
                                _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                              }
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle),
                              child: const Icon(Icons.chevron_left, color: Colors.black87, size: 22),
                            ),
                          ),
                        ),
                        // Right Arrow Button
                        Positioned(
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              if (_currentPage < widget.images!.length - 1) {
                                _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                              }
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
                    const Gap(height: 8),
                    if (widget.images!.length > 1)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.images!.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: _currentPage == index ? 24 : 16,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _currentPage == index ? AppColors.instance.primary : AppColors.instance.gray4B.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    const Gap(height: 12),
                  ],

                  AppText(text: widget.title, fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.instance.textColor),

                  // Subtitle line (e.g. Target recurrent inspect: November / Location: 2.8 km away)
                  if (widget.subtitlePrefix != null || widget.subtitleHighlight != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (widget.subtitlePrefix != null)
                          AppText(text: widget.subtitlePrefix!, fontWeight: FontWeight.w500, fontSize: 14, color: AppColors.instance.textColor),
                        if (widget.subtitleHighlight != null)
                          AppText(text: widget.subtitleHighlight!, fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.instance.primary),
                      ],
                    ),
                  ],

                  // Description
                  if (widget.description != null && widget.description!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    AppText(text: widget.description!, fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.instance.gray4B, maxLines: 3),
                  ],

                  // Customer Name
                  if (widget.customerName != null && widget.customerName!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    AppText(text: widget.customerName!, fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.instance.textColor),
                  ],

                  const Gap(height: 10),

                  AppButton(
                    onTap: widget.onChatTap ?? () {},
                    title: widget.buttonTitle,
                    backgroundColor: AppColors.instance.primary,
                    titleColor: AppColors.instance.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    borderRadius: BorderRadius.circular(10),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 90,
              height: 33,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: widget.badgeColor ?? const Color(0xFFF07D1E), borderRadius: BorderRadius.circular(4)),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                  child: AppText(text: widget.badgeText, fontSize: 12, fontWeight: FontWeight.w400, color: widget.badgeTextColor ?? Colors.black)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencyBadge(String urgency, Color? customColor) {
    Color badgeColor;
    if (customColor != null) {
      badgeColor = customColor;
    } else if (urgency.toUpperCase().contains('HIGH')) {
      badgeColor = const Color(0xFFFF4D4F);
    } else if (urgency.toUpperCase().contains('MEDIUM')) {
      badgeColor = const Color(0xFFF58220);
    } else {
      badgeColor = AppColors.instance.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor, width: 1.2),
      ),
      child: AppText(text: urgency, fontSize: 11, fontWeight: FontWeight.bold, color: badgeColor),
    );
  }
}

class OpportunityCardNotchClipper extends CustomClipper<Path> {
  final double notchWidth;
  final double notchHeight;
  final double radius;

  const OpportunityCardNotchClipper({this.notchWidth = 105, this.notchHeight = 40, this.radius = 12});

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    final r = radius;

    path.moveTo(r, 0);

    path.lineTo(w - notchWidth - r, 0);

    path.quadraticBezierTo(w - notchWidth, 0, w - notchWidth, r);

    path.lineTo(w - notchWidth, notchHeight - r);

    path.quadraticBezierTo(w - notchWidth, notchHeight, w - notchWidth + r, notchHeight);

    path.lineTo(w - r, notchHeight);

    path.quadraticBezierTo(w, notchHeight, w, notchHeight + r);

    path.lineTo(w, h - r);

    path.quadraticBezierTo(w, h, w - r, h);

    path.lineTo(r, h);

    path.quadraticBezierTo(0, h, 0, h - r);

    path.lineTo(0, r);

    path.quadraticBezierTo(0, 0, r, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
