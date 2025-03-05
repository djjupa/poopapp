import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poopapp/core/constants/app_constants.dart';
import 'package:poopapp/core/theme/app_colors.dart';
import 'package:poopapp/core/widgets/error_message.dart';
import 'package:poopapp/core/widgets/loading_indicator.dart';
import 'package:poopapp/core/widgets/poop_emoji.dart';
import 'package:poopapp/features/poop_tracking/domain/entities/child.dart';
import 'package:poopapp/features/poop_tracking/domain/entities/poop_entry.dart';
import 'package:poopapp/features/poop_tracking/presentation/bloc/child_bloc.dart';
import 'package:poopapp/features/poop_tracking/presentation/bloc/poop_bloc.dart';
import 'package:poopapp/features/poop_tracking/presentation/screens/add_child_screen.dart';
import 'package:poopapp/features/poop_tracking/presentation/screens/add_poop_entry_screen.dart';
import 'package:poopapp/features/poop_tracking/presentation/screens/calendar_screen.dart';
import 'package:poopapp/features/poop_tracking/presentation/screens/history_screen.dart';
import 'package:poopapp/features/poop_tracking/presentation/screens/profile_screen.dart';
import 'package:poopapp/features/poop_tracking/presentation/widgets/child_avatar.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = const [
    _HomeTab(),
    CalendarScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    context.read<ChildBloc>().add(LoadCurrentChildEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChildBloc, ChildState>(
      builder: (context, state) {
        final hasChild = state is CurrentChildLoadedState && state.child != null;
        
        return Scaffold(
          body: hasChild
              ? _screens[_currentIndex]
              : state is ChildLoadingState
                  ? const LoadingIndicator(message: 'Loading profile...')
                  : _buildNoChildScreen(),
          bottomNavigationBar: hasChild
              ? BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.calendar_today),
                      label: 'Calendar',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.history),
                      label: 'History',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: 'Profile',
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }

  Widget _buildNoChildScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const PoopEmoji(size: 100.0),
            const SizedBox(height: 32.0),
            Text(
              'Welcome to ${AppConstants.appName}',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            const Text(
              'To get started, add a child profile to track their poop activity.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32.0),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddChildScreen(),
                  ),
                );
              },
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
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
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
    return BlocBuilder<ChildBloc, ChildState>(
      builder: (context, childState) {
        if (childState is CurrentChildLoadedState && childState.child != null) {
          final child = childState.child!;
          
          return RefreshIndicator(
            onRefresh: () async {
              context.read<ChildBloc>().add(LoadCurrentChildEvent());
              _loadData();
            },
            child: SafeArea(
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(child),
                  _buildPoopButtonSection(),
                  _buildRecentActivity(child),
                ],
              ),
            ),
          );
        } else if (childState is ChildLoadingState) {
          return const LoadingIndicator(message: 'Loading child profile...');
        } else {
          return ErrorMessage(
            message: 'Could not load child profile.',
            onRetry: () {
              context.read<ChildBloc>().add(LoadCurrentChildEvent());
            },
          );
        }
      },
    );
  }

  Widget _buildAppBar(Child child) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 150.0,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ChildAvatar(
              name: child.name,
              avatarPath: child.avatarPath,
              size: 30.0,
            ),
            const SizedBox(width: 8.0),
            Text(
              'Track ${child.name}\'s Activity',
              style: const TextStyle(fontSize: 16.0),
            ),
          ],
        ),
        centerTitle: true,
        background: Container(
          color: AppColors.primary,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppConstants.appName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 28.0,
                  ),
                ),
                const SizedBox(height: 36.0),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.switch_account),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            );
          },
          tooltip: 'Switch Child',
        ),
      ],
    );
  }

  Widget _buildPoopButtonSection() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Track Your Kid\'s Activity',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            GestureDetector(
              onTap: _addPoopEntry,
              child: Container(
                width: 120.0,
                height: 120.0,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: PoopEmoji(size: 60.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Tap the button to record a poop',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(Child child) {
    return BlocBuilder<PoopBloc, PoopState>(
      builder: (context, state) {
        if (state is PoopEntriesLoadedState) {
          return SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  state.entries.isEmpty
                      ? _buildNoActivity()
                      : _buildActivity(state.entries, child.id!),
                ],
              ),
            ),
          );
        } else if (state is PoopLoadingState) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: LoadingIndicator(message: 'Loading recent activity...'),
            ),
          );
        } else {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ErrorMessage(
                message: 'Failed to load recent activity.',
                onRetry: () {
                  _loadData();
                },
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildNoActivity() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48.0),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.info_outline,
              color: AppColors.textSecondary,
              size: 48.0,
            ),
            const SizedBox(height: 16.0),
            const Text(
              'No poop activity recorded yet',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Tap the poop button above to record the first one',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),
            ElevatedButton.icon(
              onPressed: _addPoopEntry,
              icon: const Icon(Icons.add),
              label: const Text('Add First Entry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivity(List<PoopEntry> entries, int childId) {
    final recentEntries = entries.take(5).toList();
    final today = DateTime.now();
    final DateTime startDate = today.subtract(const Duration(days: 7));
    final DateTime endDate = today;
    
    // Trigger count calculation
    context.read<PoopBloc>().add(
      GetPoopCountByDateRangeEvent(
        childId: childId,
        startDate: startDate,
        endDate: endDate,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWeekSummary(),
        const SizedBox(height: 24.0),
        for (var entry in recentEntries)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: PoopEmoji(poopColor: entry.color, size: 40.0),
            title: Text(_getConsistencyText(entry.consistency)),
            subtitle: Text(DateFormat('EEEE, MMM d • h:mm a').format(entry.dateTime)),
            onTap: () {
              _viewPoopEntry(entry);
            },
          ),
        if (entries.length > 5) ...[
          const SizedBox(height: 16.0),
          Center(
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _currentIndex = 2; // Switch to history tab
                });
              },
              icon: const Icon(Icons.history),
              label: const Text('View Full History'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWeekSummary() {
    return BlocBuilder<PoopBloc, PoopState>(
      buildWhen: (previous, current) => current is PoopCountLoadedState,
      builder: (context, state) {
        if (state is PoopCountLoadedState) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Past 7 days summary',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        '${state.count} poop ${state.count == 1 ? 'entry' : 'entries'} recorded',
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentIndex = 1; // Switch to calendar tab
                    });
                  },
                  child: const Text('View Calendar'),
                ),
              ],
            ),
          );
        } else {
          return const SizedBox(height: 16.0);
        }
      },
    );
  }

  void _addPoopEntry() {
    final childState = context.read<ChildBloc>().state;
    if (childState is CurrentChildLoadedState && childState.child != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddPoopEntryScreen(child: childState.child!),
        ),
      ).then((_) => _loadData());
    }
  }

  void _viewPoopEntry(PoopEntry entry) {
    final childState = context.read<ChildBloc>().state;
    if (childState is CurrentChildLoadedState && childState.child != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddPoopEntryScreen(
            child: childState.child!,
            poopEntry: entry,
            isEditing: true,
          ),
        ),
      ).then((_) => _loadData());
    }
  }

  String _getConsistencyText(PoopConsistency consistency) {
    switch (consistency) {
      case PoopConsistency.liquid:
        return 'Liquid Poop';
      case PoopConsistency.soft:
        return 'Soft Poop';
      case PoopConsistency.normal:
        return 'Normal Poop';
      case PoopConsistency.hard:
        return 'Hard Poop';
      case PoopConsistency.veryHard:
        return 'Very Hard Poop';
    }
  }
} 