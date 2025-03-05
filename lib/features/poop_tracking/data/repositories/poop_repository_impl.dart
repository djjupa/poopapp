import 'package:poopapp/features/poop_tracking/data/datasources/poop_local_datasource.dart';
import 'package:poopapp/features/poop_tracking/data/models/poop_entry_model.dart';
import 'package:poopapp/features/poop_tracking/domain/entities/poop_entry.dart';
import 'package:poopapp/features/poop_tracking/domain/repositories/poop_repository.dart';

class PoopRepositoryImpl implements PoopRepository {
  final PoopLocalDataSource localDataSource;

  PoopRepositoryImpl({required this.localDataSource});

  @override
  Future<List<PoopEntry>> getAllPoopEntries(int childId) async {
    final poopModels = await localDataSource.getAllPoopEntries(childId);
    return poopModels;
  }

  @override
  Future<List<PoopEntry>> getPoopEntriesByDateRange(int childId, DateTime startDate, DateTime endDate) async {
    final poopModels = await localDataSource.getPoopEntriesByDateRange(childId, startDate, endDate);
    return poopModels;
  }

  @override
  Future<PoopEntry?> getPoopEntryById(int id) async {
    return await localDataSource.getPoopEntryById(id);
  }

  @override
  Future<int> addPoopEntry(PoopEntry entry) async {
    final poopModel = PoopEntryModel.fromEntity(entry);
    return await localDataSource.addPoopEntry(poopModel);
  }

  @override
  Future<void> updatePoopEntry(PoopEntry entry) async {
    final poopModel = PoopEntryModel.fromEntity(entry);
    await localDataSource.updatePoopEntry(poopModel);
  }

  @override
  Future<void> deletePoopEntry(int id) async {
    await localDataSource.deletePoopEntry(id);
  }

  @override
  Future<Map<DateTime, List<PoopEntry>>> getPoopEntriesGroupedByDay(int childId, DateTime month) async {
    final Map<DateTime, List<PoopEntryModel>> groupedEntries = 
        await localDataSource.getPoopEntriesGroupedByDay(childId, month);
    
    // Convert to the domain entity
    final Map<DateTime, List<PoopEntry>> result = {};
    groupedEntries.forEach((key, value) {
      result[key] = value;
    });
    
    return result;
  }

  @override
  Future<int> getPoopCountByDateRange(int childId, DateTime startDate, DateTime endDate) async {
    return await localDataSource.getPoopCountByDateRange(childId, startDate, endDate);
  }
} 