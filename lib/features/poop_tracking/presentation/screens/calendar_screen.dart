import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:poopapp/core/theme/app_colors.dart';
import 'package:poopapp/core/widgets/error_message.dart';
import 'package:poopapp/core/widgets/loading_indicator.dart';
import 'package:poopapp/core/widgets/poop_emoji.dart';
import 'package:poopapp/features/poop_tracking/domain/entities/poop_entry.dart';
import 'package:poopapp/features/poop_tracking/presentation/bloc/child_bloc.dart';
import 'package:poopapp/features/poop_tracking/presentation/bloc/poop_bloc.dart';
import 'package:poopapp/features/poop_tracking/presentation/screens/add_poop_entry_screen.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late CalendarFormat _calendarFormat;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _calendarFormat = CalendarFormat.month;
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
        title: const Text('Poop Calendar'),
      ),
      body: BlocBuilder<PoopBloc, PoopState>(
        builder: (context, state) {
          if (state is PoopEntriesLoadedState) {
            return _buildCalendarView(state.entries);
          } else if (state is PoopLoadingState) {
            return const LoadingIndicator(message: 'Loading calendar data...');
          } else {
            return ErrorMessage(
              message: 'Failed to load calendar data.',
              onRetry: () {
                _loadData();
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEntryForSelectedDay,
        child: const Icon(Icons.add),
        tooltip: 'Add Entry',
      ),
    );
  }

  Widget _buildCalendarView(List<PoopEntry> entries) {
    // Create a map of days with entries
    final Map<DateTime, List<PoopEntry>> entriesByDay = {};
    for (var entry in entries) {
      final date = DateTime(
        entry.dateTime.year,
        entry.dateTime.month,
        entry.dateTime.day,
      );
      if (!entriesByDay.containsKey(date)) {
        entriesByDay[date] = [];
      }
      entriesByDay[date]!.add(entry);
    }

    // Get entries for the selected day
    final selectedDayEntries = entriesByDay[DateTime(
          _selectedDay.year,
          _selectedDay.month,
          _selectedDay.day,
        )] ??
        [];

    return Column(
      children: [
        _buildCalendar(entriesByDay),
        const Divider(height: 1),
        Expanded(
          child: _buildEntriesForSelectedDay(selectedDayEntries),
        ),
      ],
    );
  }

  Widget _buildCalendar(Map<DateTime, List<PoopEntry>> entriesByDay) {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.now().add(const Duration(days: 1)),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      eventLoader: (day) => entriesByDay[DateTime(
            day.year,
            day.month,
            day.day,
          )] ??
          [],
      calendarStyle: CalendarStyle(
        markersMaxCount: 3,
        markerDecoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          if (events.isEmpty) return null;
          
          // Cast to List<PoopEntry>
          final poopEntries = events.cast<PoopEntry>();
          
          // Show a more prominent marker for days with concerns (blood/mucus)
          final hasConcerns = poopEntries.any((entry) => entry.hasBlood || entry.hasMucus);
          
          return Container(
            margin: const EdgeInsets.only(top: 6.0),
            child: hasConcerns
                ? const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 12.0,
                  )
                : Container(
                    width: 8.0,
                    height: 8.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: poopEntries.length > 1 
                          ? AppColors.primary 
                          : AppColors.primary.withOpacity(0.5),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildEntriesForSelectedDay(List<PoopEntry> entries) {
    if (entries.isEmpty) {
      return _buildEmptyDayView();
    }

    // Sort entries by time (latest first)
    entries.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return RefreshIndicator(
      onRefresh: () async {
        _loadData();
      },
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSelectedDayHeader(),
          const SizedBox(height: 16.0),
          ...entries.map((entry) => _buildEntryItem(entry)).toList(),
        ],
      ),
    );
  }

  Widget _buildSelectedDayHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE, MMMM d, yyyy').format(_selectedDay),
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          BlocBuilder<PoopBloc, PoopState>(
            builder: (context, state) {
              if (state is PoopEntriesLoadedState) {
                final selectedDateEntries = state.entries
                    .where((entry) => isSameDay(entry.dateTime, _selectedDay))
                    .toList();
                
                return Text(
                  '${selectedDateEntries.length} ${selectedDateEntries.length == 1 ? 'entry' : 'entries'} on this day',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildEntryItem(PoopEntry entry) {
    return BlocBuilder<ChildBloc, ChildState>(
      builder: (context, state) {
        if (state is CurrentChildLoadedState && state.child != null) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: InkWell(
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
              borderRadius: BorderRadius.circular(12.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    PoopEmoji(
                      size: 40.0,
                      poopColor: entry.color,
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('h:mm a').format(entry.dateTime),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            _getConsistencyText(entry.consistency),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (entry.hasBlood || entry.hasMucus) ...[
                            const SizedBox(height: 4.0),
                            Row(
                              children: [
                                if (entry.hasBlood)
                                  _buildTag('Blood', Colors.red.shade100, Colors.red),
                                if (entry.hasBlood && entry.hasMucus)
                                  const SizedBox(width: 8.0),
                                if (entry.hasMucus)
                                  _buildTag('Mucus', Colors.orange.shade100, Colors.orange),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (entry.feeling != null) ...[
                      _buildFeelingEmoji(entry.feeling!),
                    ],
                  ],
                ),
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildFeelingEmoji(FeelingSentiment feeling) {
    String emoji;
    switch (feeling) {
      case FeelingSentiment.good:
        emoji = '😊';
        break;
      case FeelingSentiment.okay:
        emoji = '😐';
        break;
      case FeelingSentiment.bad:
        emoji = '😣';
        break;
      case FeelingSentiment.painful:
        emoji = '😫';
        break;
    }

    return Text(
      emoji,
      style: const TextStyle(
        fontSize: 24.0,
      ),
    );
  }

  Widget _buildTag(String label, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 2.0,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyDayView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('EEEE, MMMM d').format(_selectedDay),
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          const Icon(
            Icons.calendar_today,
            size: 64.0,
            color: Colors.grey,
          ),
          const SizedBox(height: 16.0),
          const Text(
            'No poop entries on this day',
            style: TextStyle(
              fontSize: 16.0,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24.0),
          ElevatedButton.icon(
            onPressed: _addEntryForSelectedDay,
            icon: const Icon(Icons.add),
            label: const Text('Add Entry for This Day'),
          ),
        ],
      ),
    );
  }

  void _addEntryForSelectedDay() {
    final childState = context.read<ChildBloc>().state;
    if (childState is CurrentChildLoadedState && childState.child != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddPoopEntryScreen(
            child: childState.child!,
          ),
        ),
      ).then((_) => _loadData());
    }
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
} 