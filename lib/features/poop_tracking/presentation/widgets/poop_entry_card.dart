import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:poopapp/core/theme/app_colors.dart';
import 'package:poopapp/core/widgets/poop_emoji.dart';
import 'package:poopapp/features/poop_tracking/domain/entities/poop_entry.dart';

class PoopEntryCard extends StatelessWidget {
  final PoopEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  
  const PoopEntryCard({
    super.key,
    required this.entry,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PoopEmoji(
                    poopColor: entry.color,
                    size: 60.0,
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE, MMM d, yyyy • h:mm a').format(entry.dateTime),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          '${_getConsistencyText(entry.consistency)} • ${_getColorText(entry.color)}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (entry.hasBlood || entry.hasMucus) ...[
                          const SizedBox(height: 4.0),
                          Row(
                            children: [
                              if (entry.hasBlood)
                                _buildTag(context, 'Blood', AppColors.error),
                              if (entry.hasBlood && entry.hasMucus)
                                const SizedBox(width: 8.0),
                              if (entry.hasMucus)
                                _buildTag(context, 'Mucus', AppColors.warning),
                            ],
                          ),
                        ],
                        if (entry.feeling != null) ...[
                          const SizedBox(height: 8.0),
                          Row(
                            children: [
                              Text(
                                'Feeling: ',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                _getFeelingEmoji(entry.feeling!),
                                style: const TextStyle(fontSize: 18.0),
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                _getFeelingText(entry.feeling!),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      onPressed: () => _confirmDelete(context),
                    ),
                ],
              ),
              if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                const Divider(height: 24.0),
                Text(
                  'Notes:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  entry.notes!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.0,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getConsistencyText(PoopConsistency consistency) {
    switch (consistency) {
      case PoopConsistency.liquid:
        return 'Liquid';
      case PoopConsistency.soft:
        return 'Soft';
      case PoopConsistency.normal:
        return 'Normal';
      case PoopConsistency.hard:
        return 'Hard';
      case PoopConsistency.veryHard:
        return 'Very Hard';
    }
  }

  String _getColorText(PoopColor color) {
    switch (color) {
      case PoopColor.brown:
        return 'Brown';
      case PoopColor.darkBrown:
        return 'Dark Brown';
      case PoopColor.lightBrown:
        return 'Light Brown';
      case PoopColor.yellow:
        return 'Yellow';
      case PoopColor.green:
        return 'Green';
      case PoopColor.red:
        return 'Red';
      case PoopColor.black:
        return 'Black';
      case PoopColor.white:
        return 'White';
    }
  }

  String _getFeelingEmoji(FeelingSentiment feeling) {
    switch (feeling) {
      case FeelingSentiment.veryHappy:
        return '😄';
      case FeelingSentiment.happy:
        return '🙂';
      case FeelingSentiment.neutral:
        return '😐';
      case FeelingSentiment.uncomfortable:
        return '😕';
      case FeelingSentiment.painful:
        return '😣';
      case FeelingSentiment.verySad:
        return '😢';
      case FeelingSentiment.angry:
        return '😠';
      case FeelingSentiment.sick:
        return '🤢';
      case FeelingSentiment.embarrassed:
        return '😳';
    }
  }

  String _getFeelingText(FeelingSentiment feeling) {
    switch (feeling) {
      case FeelingSentiment.veryHappy:
        return 'Very Happy';
      case FeelingSentiment.happy:
        return 'Happy';
      case FeelingSentiment.neutral:
        return 'Neutral';
      case FeelingSentiment.uncomfortable:
        return 'Uncomfortable';
      case FeelingSentiment.painful:
        return 'Painful';
      case FeelingSentiment.verySad:
        return 'Very Sad';
      case FeelingSentiment.angry:
        return 'Angry';
      case FeelingSentiment.sick:
        return 'Sick';
      case FeelingSentiment.embarrassed:
        return 'Embarrassed';
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this poop entry? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true && onDelete != null) {
      onDelete!();
    }
  }
} 