import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class HomeOpportunityToggleBanner extends StatefulWidget {
  final ValueChanged<bool>? onToggleChanged;

  const HomeOpportunityToggleBanner({super.key, this.onToggleChanged});

  @override
  State<HomeOpportunityToggleBanner> createState() => _HomeOpportunityToggleBannerState();
}

class _HomeOpportunityToggleBannerState extends State<HomeOpportunityToggleBanner> {
  bool _isEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: AppColors.instance.primary, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: AppText(text: "Opportunities along my route", fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.instance.white),
          ),
          Switch(
            value: _isEnabled,
            onChanged: (value) {
              setState(() {
                _isEnabled = value;
              });
              widget.onToggleChanged?.call(value);
            },
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF7A122E),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}
