import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:poopapp/core/theme/app_colors.dart';
import 'package:poopapp/core/widgets/error_message.dart';
import 'package:poopapp/core/widgets/loading_indicator.dart';
import 'package:poopapp/features/poop_tracking/domain/entities/poop_entry.dart';
import 'package:poopapp/features/poop_tracking/presentation/bloc/child_bloc.dart';
import 'package:poopapp/features/poop_tracking/presentation/bloc/poop_bloc.dart';
import 'package:poopapp/features/poop_tracking/presentation/screens/add_poop_entry_screen.dart';
import 'package:poopapp/features/poop_tracking/presentation/widgets/poop_entry_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final childState = context.read<ChildBloc>().state;
    if (childState is CurrentChildLoadedState && childState.child != null) {
      final childId = childState.child!.id!;
      context.read<PoopBloc>().add(LoadAllPoopEntriesEvent(childId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poop History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
            tooltip: 'Filter Entries',
          ),
        ],
      ),
      body: BlocBuilder<PoopBloc, PoopState>(
        builder: (context, state) {
          if (state is PoopEntriesLoadedState) {
            return _buildEntriesList(state.entries);
          } else if (state is PoopLoadingState) {
            return const LoadingIndicator(message: 'Loading poop history...');
          } else {
            return ErrorMessage(
              message: 'Failed to load poop history.',
              onRetry: () {
                _loadData();
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildEntriesList(List<PoopEntry> entries) {
    if (entries.isEmpty) {
      return _buildEmptyState();
    }

    // Sort entries by date (most recent first)
    final sortedEntries = List<PoopEntry>.from(entries)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    // Group entries by month
    final Map<String, List<PoopEntry>> entriesByMonth = {};
    for (var entry in sortedEntries) {
      final monthKey = DateFormat('MMMM yyyy').format(entry.dateTime);
      if (!entriesByMonth.containsKey(monthKey)) {
        entriesByMonth[monthKey] = [];
      }
      entriesByMonth[monthKey]!.add(entry);
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadData();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: entriesByMonth.length,
        itemBuilder: (context, index) {
          final monthKey = entriesByMonth.keys.elementAt(index);
          final monthEntries = entriesByMonth[monthKey]!;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  monthKey,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Divider(),
              ...monthEntries.map((entry) => _buildEntryCard(entry)).toList(),
              const SizedBox(height: 16.0),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEntryCard(PoopEntry entry) {
    return BlocBuilder<ChildBloc, ChildState>(
      builder: (context, state) {
        if (state is CurrentChildLoadedState && state.child != null) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: PoopEntryCard(
              entry: entry,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddPoopEntryScreen(
                      child: state.child!,
                      poopEntry: entry,
                      isEditing: true,
                    ),
                  ),
                ).then((_) => _loadData());
              },
              onDelete: () {
                context.read<PoopBloc>().add(
                      DeletePoopEntryEvent(
                        entry.id!,
                        entry.childId,
                      ),
                    );
                _loadData();
              },
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
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
              Icons.history,
              size: 80.0,
              color: Colors.grey,
            ),
            const SizedBox(height: 24.0),
            const Text(
              'No poop history yet',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            const Text(
              'When you add poop entries, they will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton.icon(
              onPressed: () {
                final state = context.read<ChildBloc>().state;
                if (state is CurrentChildLoadedState && state.child != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPoopEntryScreen(
                        child: state.child!,
                      ),
                    ),
                  ).then((_) => _loadData());
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add First Entry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Filter Entries',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('All Entries'),
                onTap: () {
                  Navigator.pop(context);
                  _loadData();
                },
              ),
              ListTile(
                leading: const Icon(Icons.filter_list),
                title: const Text('Last 7 Days'),
                onTap: () {
                  Navigator.pop(context);
                  _filterByDateRange(
                    DateTime.now().subtract(const Duration(days: 7)),
                    DateTime.now(),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.filter_list),
                title: const Text('Last 30 Days'),
                onTap: () {
                  Navigator.pop(context);
                  _filterByDateRange(
                    DateTime.now().subtract(const Duration(days: 30)),
                    DateTime.now(),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.warning_amber),
                title: const Text('Concerns (Blood/Mucus)'),
                onTap: () {
                  Navigator.pop(context);
                  _filterByConcerns();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _filterByDateRange(DateTime startDate, DateTime endDate) {
    final childState = context.read<ChildBloc>().state;
    if (childState is CurrentChildLoadedState && childState.child != null) {
      final childId = childState.child!.id!;
      context.read<PoopBloc>().add(
            GetPoopEntriesByDateRangeEvent(
              childId: childId,
              startDate: startDate,
              endDate: endDate,
            ),
          );
    }
  }

  void _filterByConcerns() {
    final childState = context.read<ChildBloc>().state;
    if (childState is CurrentChildLoadedState && childState.child != null) {
      final childId = childState.child!.id!;
      context.read<PoopBloc>().add(
            GetPoopEntriesWithConcernsEvent(childId),
          );
    }
  }
} 