import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:poopapp/core/theme/app_colors.dart';
import 'package:poopapp/core/widgets/error_message.dart';
import 'package:poopapp/core/widgets/loading_indicator.dart';
import 'package:poopapp/features/poop_tracking/domain/entities/child.dart';
import 'package:poopapp/features/poop_tracking/presentation/bloc/child_bloc.dart';
import 'package:poopapp/features/poop_tracking/presentation/screens/add_child_screen.dart';
import 'package:poopapp/features/poop_tracking/presentation/widgets/child_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ChildBloc>().add(LoadAllChildrenEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profiles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewChild,
            tooltip: 'Add New Child',
          ),
        ],
      ),
      body: BlocBuilder<ChildBloc, ChildState>(
        builder: (context, state) {
          if (state is AllChildrenLoadedState) {
            return _buildProfilesList(state.children);
          } else if (state is ChildLoadingState) {
            return const LoadingIndicator(message: 'Loading profiles...');
          } else {
            return ErrorMessage(
              message: 'Failed to load child profiles.',
              onRetry: () {
                context.read<ChildBloc>().add(LoadAllChildrenEvent());
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildProfilesList(List<Child> children) {
    if (children.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ChildBloc>().add(LoadAllChildrenEvent());
      },
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Child Profiles',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24.0),
          const Text(
            'Tap a profile to edit or select it for tracking',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24.0),
          ...children.map((child) => _buildProfileCard(child)).toList(),
          const SizedBox(height: 24.0),
          Center(
            child: OutlinedButton.icon(
              onPressed: _addNewChild,
              icon: const Icon(Icons.add),
              label: const Text('Add New Child'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 12.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32.0),
          _buildStatisticsSection(children),
        ],
      ),
    );
  }

  Widget _buildProfileCard(Child child) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: child.isSelected
              ? AppColors.primary
              : Colors.transparent,
          width: child.isSelected ? 2.0 : 0.0,
        ),
      ),
      child: InkWell(
        onTap: () => _editChild(child),
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              ChildAvatar(
                name: child.name,
                avatarPath: child.avatarPath,
                size: 60.0,
                isSelected: child.isSelected,
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          child.name,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (child.isSelected) ...[
                          const SizedBox(width: 8.0),
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: 16.0,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    if (child.birthDate != null) ...[
                      Text(
                        'Birth Date: ${DateFormat('MMM d, yyyy').format(child.birthDate!)}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Age: ${_calculateAge(child.birthDate!)}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Text(
                          _getGenderText(child.gender),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        if (!child.isSelected)
                          ElevatedButton(
                            onPressed: () => _selectChild(child),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 8.0,
                              ),
                            ),
                            child: const Text('Select'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.child_care,
              size: 80.0,
              color: Colors.grey,
            ),
            const SizedBox(height: 24.0),
            const Text(
              'No Child Profiles Yet',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Add a child profile to start tracking their poop activity',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton.icon(
              onPressed: _addNewChild,
              icon: const Icon(Icons.add),
              label: const Text('Add Child Profile'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 12.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(List<Child> children) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Family Stats',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16.0),
          _buildStatRow('Total children', '${children.length}'),
          const SizedBox(height: 8.0),
          _buildStatRow(
            'Average age',
            _calculateAverageAge(children),
          ),
          const SizedBox(height: 8.0),
          _buildStatRow(
            'Gender distribution',
            _calculateGenderDistribution(children),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _calculateAverageAge(List<Child> children) {
    final childrenWithBirthDate = children.where((child) => child.birthDate != null).toList();
    
    if (childrenWithBirthDate.isEmpty) {
      return 'N/A';
    }
    
    final now = DateTime.now();
    double totalMonths = 0;
    
    for (final child in childrenWithBirthDate) {
      final birthDate = child.birthDate!;
      final months = (now.year - birthDate.year) * 12 + now.month - birthDate.month;
      totalMonths += months;
    }
    
    final avgMonths = totalMonths / childrenWithBirthDate.length;
    
    if (avgMonths >= 24) {
      return '${(avgMonths / 12).toStringAsFixed(1)} years';
    } else {
      return '${avgMonths.toStringAsFixed(1)} months';
    }
  }

  String _calculateGenderDistribution(List<Child> children) {
    int boys = 0;
    int girls = 0;
    int other = 0;
    
    for (final child in children) {
      switch (child.gender) {
        case Gender.male:
          boys++;
          break;
        case Gender.female:
          girls++;
          break;
        case Gender.unknown:
          other++;
          break;
      }
    }
    
    final result = StringBuffer();
    if (boys > 0) {
      result.write('$boys ${boys == 1 ? 'boy' : 'boys'}');
    }
    
    if (girls > 0) {
      if (result.isNotEmpty) result.write(', ');
      result.write('$girls ${girls == 1 ? 'girl' : 'girls'}');
    }
    
    if (other > 0) {
      if (result.isNotEmpty) result.write(', ');
      result.write('$other other');
    }
    
    return result.toString();
  }

  String _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    final years = today.year - birthDate.year;
    final months = today.month - birthDate.month;
    
    if (years > 0) {
      return '$years ${years == 1 ? 'year' : 'years'}';
    } else {
      return '$months ${months == 1 ? 'month' : 'months'}';
    }
  }

  String _getGenderText(Gender gender) {
    switch (gender) {
      case Gender.male:
        return 'Boy';
      case Gender.female:
        return 'Girl';
      case Gender.unknown:
        return 'Other';
    }
  }

  void _addNewChild() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddChildScreen(),
      ),
    ).then((_) {
      context.read<ChildBloc>().add(LoadAllChildrenEvent());
    });
  }

  void _editChild(Child child) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddChildScreen(
          child: child,
          isEditing: true,
        ),
      ),
    ).then((_) {
      context.read<ChildBloc>().add(LoadAllChildrenEvent());
    });
  }

  void _selectChild(Child child) {
    context.read<ChildBloc>().add(SelectChildEvent(child.id!));
  }
} 