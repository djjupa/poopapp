import 'package:poopapp/features/poop_tracking/domain/entities/poop_entry.dart';

abstract class PoopRepository {
  Future<List<PoopEntry>> getAllPoopEntries(int childId);
  Future<List<PoopEntry>> getPoopEntriesByDateRange(int childId, DateTime startDate, DateTime endDate);
  Future<PoopEntry?> getPoopEntryById(int id);
  Future<int> addPoopEntry(PoopEntry entry);
  Future<void> updatePoopEntry(PoopEntry entry);
  Future<void> deletePoopEntry(int id);
  Future<Map<DateTime, List<PoopEntry>>> getPoopEntriesGroupedByDay(int childId, DateTime month);
  Future<int> getPoopCountByDateRange(int childId, DateTime startDate, DateTime endDate);
} 