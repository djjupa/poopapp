import 'dart:io';
import 'package:flutter/material.dart';
import 'package:poopapp/core/theme/app_colors.dart';

class ChildAvatar extends StatelessWidget {
  final String? avatarPath;
  final String name;
  final double size;
  final VoidCallback? onTap;
  final bool isSelected;
  
  const ChildAvatar({
    super.key,
    this.avatarPath,
    required this.name,
    this.size = 60.0,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryLight.withOpacity(0.1),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 3.0,
              ),
            ),
            child: ClipOval(
              child: avatarPath != null
                  ? _buildImage()
                  : Center(
                      child: Text(
                        _getInitials(),
                        style: TextStyle(
                          fontSize: size / 2.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
            ),
          ),
          if (name.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (avatarPath!.startsWith('http')) {
      return Image.network(
        avatarPath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Text(
              _getInitials(),
              style: TextStyle(
                fontSize: size / 2.5,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          );
        },
      );
    } else {
      return Image.file(
        File(avatarPath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Text(
              _getInitials(),
              style: TextStyle(
                fontSize: size / 2.5,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          );
        },
      );
    }
  }

  String _getInitials() {
    if (name.isEmpty) return '';
    final nameParts = name.trim().split(' ');
    if (nameParts.length > 1) {
      return nameParts[0][0].toUpperCase() + nameParts[1][0].toUpperCase();
    } else {
      return name[0].toUpperCase();
    }
  }
} 