import 'package:poopapp/core/constants/app_constants.dart';
import 'package:poopapp/core/utils/database_helper.dart';
import 'package:poopapp/features/poop_tracking/data/models/poop_entry_model.dart';
import 'package:intl/intl.dart';

abstract class PoopLocalDataSource {
  Future<List<PoopEntryModel>> getAllPoopEntries(int childId);
  Future<List<PoopEntryModel>> getPoopEntriesByDateRange(int childId, DateTime startDate, DateTime endDate);
  Future<PoopEntryModel?> getPoopEntryById(int id);
  Future<int> addPoopEntry(PoopEntryModel entry);
  Future<void> updatePoopEntry(PoopEntryModel entry);
  Future<void> deletePoopEntry(int id);
  Future<Map<DateTime, List<PoopEntryModel>>> getPoopEntriesGroupedByDay(int childId, DateTime month);
  Future<int> getPoopCountByDateRange(int childId, DateTime startDate, DateTime endDate);
}

class PoopLocalDataSourceImpl implements PoopLocalDataSource {
  final DatabaseHelper databaseHelper;

  PoopLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<List<PoopEntryModel>> getAllPoopEntries(int childId) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.poopTableName,
      where: 'child_id = ?',
      whereArgs: [childId],
      orderBy: 'date_time DESC',
    );
    return List.generate(maps.length, (i) => PoopEntryModel.fromMap(maps[i]));
  }

  @override
  Future<List<PoopEntryModel>> getPoopEntriesByDateRange(int childId, DateTime startDate, DateTime endDate) async {
    final db = await databaseHelper.database;
    final startDateString = startDate.toIso8601String();
    final endDateString = endDate.toIso8601String();
    
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.poopTableName,
      where: 'child_id = ? AND date_time BETWEEN ? AND ?',
      whereArgs: [childId, startDateString, endDateString],
      orderBy: 'date_time DESC',
    );
    return List.generate(maps.length, (i) => PoopEntryModel.fromMap(maps[i]));
  }

  @override
  Future<PoopEntryModel?> getPoopEntryById(int id) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.poopTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return PoopEntryModel.fromMap(maps.first);
  }

  @override
  Future<int> addPoopEntry(PoopEntryModel entry) async {
    final db = await databaseHelper.database;
    return await db.insert(
      AppConstants.poopTableName,
      entry.toMap(),
    );
  }

  @override
  Future<void> updatePoopEntry(PoopEntryModel entry) async {
    final db = await databaseHelper.database;
    await db.update(
      AppConstants.poopTableName,
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  @override
  Future<void> deletePoopEntry(int id) async {
    final db = await databaseHelper.database;
    await db.delete(
      AppConstants.poopTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<Map<DateTime, List<PoopEntryModel>>> getPoopEntriesGroupedByDay(int childId, DateTime month) async {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    
    final entries = await getPoopEntriesByDateRange(childId, firstDayOfMonth, lastDayOfMonth);
    
    final Map<DateTime, List<PoopEntryModel>> result = {};
    
    for (var entry in entries) {
      final date = DateTime(entry.dateTime.year, entry.dateTime.month, entry.dateTime.day);
      if (!result.containsKey(date)) {
        result[date] = [];
      }
      result[date]!.add(entry);
    }
    
    return result;
  }

  @override
  Future<int> getPoopCountByDateRange(int childId, DateTime startDate, DateTime endDate) async {
    final db = await databaseHelper.database;
    final startDateString = startDate.toIso8601String();
    final endDateString = endDate.toIso8601String();
    
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM ${AppConstants.poopTableName}
      WHERE child_id = ? AND date_time BETWEEN ? AND ?
    ''', [childId, startDateString, endDateString]);
    
    return result.first['count'] as int;
  }
} 