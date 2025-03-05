import 'package:flutter/material.dart';
import 'package:poopapp/features/poop_tracking/domain/entities/poop_entry.dart';

class FeelingSelectorWidget extends StatelessWidget {
  final FeelingSentiment? selectedFeeling;
  final Function(FeelingSentiment) onFeelingSelected;
  
  const FeelingSelectorWidget({
    super.key,
    this.selectedFeeling,
    required this.onFeelingSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            'How did it feel for the kid?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 5,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.0,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          children: [
            _buildEmojiButton(context, FeelingSentiment.veryHappy, '😄'),
            _buildEmojiButton(context, FeelingSentiment.happy, '🙂'),
            _buildEmojiButton(context, FeelingSentiment.neutral, '😐'),
            _buildEmojiButton(context, FeelingSentiment.uncomfortable, '😕'),
            _buildEmojiButton(context, FeelingSentiment.painful, '😣'),
            _buildEmojiButton(context, FeelingSentiment.verySad, '😢'),
            _buildEmojiButton(context, FeelingSentiment.angry, '😠'),
            _buildEmojiButton(context, FeelingSentiment.sick, '🤢'),
            _buildEmojiButton(context, FeelingSentiment.embarrassed, '😳'),
          ],
        ),
      ],
    );
  }

  Widget _buildEmojiButton(BuildContext context, FeelingSentiment feeling, String emoji) {
    final isSelected = selectedFeeling == feeling;
    
    return GestureDetector(
      onTap: () => onFeelingSelected(feeling),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary 
                : Colors.grey.shade300,
            width: 2.0,
          ),
        ),
        child: Center(
          child: Text(
            emoji,
            style: TextStyle(
              fontSize: 24.0,
              color: isSelected ? Colors.white : null,
            ),
          ),
        ),
      ),
    );
  }
} 