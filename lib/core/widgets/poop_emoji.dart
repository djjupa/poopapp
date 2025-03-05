import 'package:flutter/material.dart';
import 'package:poopapp/core/theme/app_colors.dart';
import 'package:poopapp/features/poop_tracking/domain/entities/poop_entry.dart';

class PoopEmoji extends StatelessWidget {
  final double size;
  final PoopColor? poopColor;
  final bool animated;
  
  const PoopEmoji({
    super.key,
    this.size = 40.0,
    this.poopColor,
    this.animated = false,
  });

  Color _getPoopColor() {
    if (poopColor == null) {
      return AppColors.poopBrown;
    }
    
    switch (poopColor!) {
      case PoopColor.brown:
        return AppColors.poopBrown;
      case PoopColor.darkBrown:
        return AppColors.poopDarkBrown;
      case PoopColor.lightBrown:
        return AppColors.poopLightBrown;
      case PoopColor.yellow:
        return AppColors.poopYellow;
      case PoopColor.green:
        return AppColors.poopGreen;
      case PoopColor.red:
        return AppColors.poopRed;
      case PoopColor.black:
        return Colors.black87;
      case PoopColor.white:
        return Colors.white70;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getPoopColor(),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          '💩',
          style: TextStyle(
            fontSize: size * 0.6,
          ),
        ),
      ),
    );
  }
} 