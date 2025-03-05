import 'package:flutter/material.dart';
import 'package:poopapp/core/theme/app_colors.dart';
import 'package:poopapp/features/poop_tracking/domain/entities/poop_entry.dart';

class PoopCharacteristicsSelector extends StatelessWidget {
  final PoopConsistency? selectedConsistency;
  final PoopColor? selectedColor;
  final bool hasBlood;
  final bool hasMucus;
  final Function(PoopConsistency) onConsistencySelected;
  final Function(PoopColor) onColorSelected;
  final Function(bool) onHasBloodChanged;
  final Function(bool) onHasMucusChanged;

  const PoopCharacteristicsSelector({
    super.key,
    this.selectedConsistency,
    this.selectedColor,
    this.hasBlood = false,
    this.hasMucus = false,
    required this.onConsistencySelected,
    required this.onColorSelected,
    required this.onHasBloodChanged,
    required this.onHasMucusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
          child: Text(
            'Characteristics of the poop',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text('Consistency:'),
        ),
        _buildConsistencySelector(context),
        const SizedBox(height: 16.0),
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text('Color:'),
        ),
        _buildColorSelector(context),
        const SizedBox(height: 16.0),
        _buildAdditionalCharacteristics(context),
      ],
    );
  }

  Widget _buildConsistencySelector(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildConsistencyOption(
            context,
            'Liquid',
            PoopConsistency.liquid,
            'Completely watery, no solid pieces',
          ),
          _buildConsistencyOption(
            context,
            'Soft',
            PoopConsistency.soft,
            'Loose, pudding-like texture',
          ),
          _buildConsistencyOption(
            context,
            'Normal',
            PoopConsistency.normal,
            'Well-formed, smooth texture',
          ),
          _buildConsistencyOption(
            context,
            'Hard',
            PoopConsistency.hard,
            'Firm, requires some straining',
          ),
          _buildConsistencyOption(
            context,
            'Very Hard',
            PoopConsistency.veryHard,
            'Difficult to pass, separate hard lumps',
          ),
        ],
      ),
    );
  }

  Widget _buildConsistencyOption(
    BuildContext context,
    String label,
    PoopConsistency consistency,
    String description,
  ) {
    final isSelected = selectedConsistency == consistency;
    
    return GestureDetector(
      onTap: () => onConsistencySelected(consistency),
      child: Container(
        width: 100.0,
        margin: const EdgeInsets.only(right: 12.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: 2.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4.0),
            Text(
              description,
              style: TextStyle(
                fontSize: 12.0,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSelector(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildColorOption(context, 'Brown', PoopColor.brown, AppColors.poopBrown),
          _buildColorOption(context, 'Dark Brown', PoopColor.darkBrown, AppColors.poopDarkBrown),
          _buildColorOption(context, 'Light Brown', PoopColor.lightBrown, AppColors.poopLightBrown),
          _buildColorOption(context, 'Yellow', PoopColor.yellow, AppColors.poopYellow),
          _buildColorOption(context, 'Green', PoopColor.green, AppColors.poopGreen),
          _buildColorOption(context, 'Red', PoopColor.red, AppColors.poopRed),
          _buildColorOption(context, 'Black', PoopColor.black, Colors.black87),
          _buildColorOption(context, 'White', PoopColor.white, Colors.grey.shade300),
        ],
      ),
    );
  }

  Widget _buildColorOption(
    BuildContext context,
    String label,
    PoopColor color,
    Color displayColor,
  ) {
    final isSelected = selectedColor == color;
    
    return GestureDetector(
      onTap: () => onColorSelected(color),
      child: Container(
        width: 70.0,
        margin: const EdgeInsets.only(right: 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              height: 30.0,
              decoration: BoxDecoration(
                color: displayColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10.0)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                label,
                style: const TextStyle(fontSize: 12.0),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalCharacteristics(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Additional characteristics:'),
        const SizedBox(height: 8.0),
        Row(
          children: [
            _buildCharacteristicCheckbox(
              context,
              'Has blood',
              hasBlood,
              onHasBloodChanged,
            ),
            const SizedBox(width: 16.0),
            _buildCharacteristicCheckbox(
              context,
              'Has mucus',
              hasMucus,
              onHasMucusChanged,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCharacteristicCheckbox(
    BuildContext context,
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: value,
              onChanged: (newValue) => onChanged(newValue ?? false),
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }
} 