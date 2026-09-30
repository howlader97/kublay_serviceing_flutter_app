import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/utils/app_size.dart';
import 'package:belwork/utils/gap.dart';
import 'package:belwork/widgets/texts/app_text.dart';

class AppDropdownField extends ConsumerStatefulWidget {
  final String title;
  final StateProvider<String?> provider;
  final List<String> options;
  final String? hintText;

  const AppDropdownField({super.key, required this.title, required this.provider, required this.options, this.hintText});

  @override
  ConsumerState<AppDropdownField> createState() => _AppDropdownFieldState();
}

class _AppDropdownFieldState extends ConsumerState<AppDropdownField> with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _dropdownKey = GlobalKey();
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _expandAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _closeDropdown();
    _animationController.dispose();
    super.dispose();
  }

  void _closeDropdown() {
    if (_isOpen) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      if (mounted) {
        _animationController.reverse();
        setState(() {
          _isOpen = false;
        });
      }
    }
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward();
    setState(() {
      _isOpen = true;
    });
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = _dropdownKey.currentContext!.findRenderObject() as RenderBox;
    Size size = renderBox.size;
    final selectedValue = ref.read(widget.provider);

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: _closeDropdown,
            behavior: HitTestBehavior.translucent,
            child: SizedBox(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height),
          ),
          Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0.0, size.height + 4.0),
              child: SizedBox(
                width: size.width,
                child: Material(
                  elevation: 6.0,
                  borderRadius: BorderRadius.circular(AppSize.width(value: 8.0)),
                  color: AppColors.instance.white,
                  shadowColor: Colors.black.withValues(alpha: 0.2),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.instance.white,
                      borderRadius: BorderRadius.circular(AppSize.width(value: 8.0)),
                      border: Border.all(color: AppColors.instance.textColor.withValues(alpha: 0.3)),
                    ),
                    child: FadeTransition(
                      opacity: _expandAnimation,
                      child: SizeTransition(
                        sizeFactor: _expandAnimation,
                        axisAlignment: -1.0,
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: widget.options.length,
                          separatorBuilder: (context, index) => Divider(height: 1, color: AppColors.instance.textColor.withValues(alpha: 0.1)),
                          itemBuilder: (context, index) {
                            final option = widget.options[index];
                            final isSelected = option == selectedValue;
                            return InkWell(
                              onTap: () {
                                ref.read(widget.provider.notifier).state = option;
                                _closeDropdown();
                              },
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: AppSize.width(value: 15.0),
                                  right: AppSize.width(value: 30.0),
                                  top: AppSize.height(value: 12),
                                  bottom: AppSize.height(value: 12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    AppText(
                                      text: option,
                                      fontSize: 16,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                      color: isSelected ? AppColors.instance.primary : AppColors.instance.black300,
                                    ),
                                    if (isSelected) Icon(Icons.check_rounded, color: AppColors.instance.primary, size: 20),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedValue = ref.watch(widget.provider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSize.width(value: 20.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(height: 15),
          AppText(text: widget.title, fontWeight: FontWeight.w500, color: AppColors.instance.black900, fontSize: 18),
          const Gap(height: 10),
          CompositedTransformTarget(
            link: _layerLink,
            child: GestureDetector(
              key: _dropdownKey,
              onTap: _toggleDropdown,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: AppSize.width(value: 15.0), vertical: AppSize.height(value: 13)),
                decoration: BoxDecoration(
                  color: AppColors.instance.transparent,
                  borderRadius: BorderRadius.circular(AppSize.width(value: 8.0)),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.8)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(
                      text: selectedValue ?? widget.hintText ?? widget.title,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.instance.black300,
                    ),
                    RotationTransition(
                      turns: Tween<double>(begin: 0.0, end: 0.5).animate(_expandAnimation),
                      child: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.instance.black300, size: 24),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
