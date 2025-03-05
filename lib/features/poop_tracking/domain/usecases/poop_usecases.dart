import 'package:poopapp/features/poop_tracking/domain/entities/poop_entry.dart';
import 'package:poopapp/features/poop_tracking/domain/repositories/poop_repository.dart';

class GetAllPoopEntriesUseCase {
  final PoopRepository repository;

  GetAllPoopEntriesUseCase(this.repository);

  Future<List<PoopEntry>> execute(int childId) async {
    return await repository.getAllPoopEntries(childId);
  }
}

class GetPoopEntriesByDateRangeUseCase {
  final PoopRepository repository;

  GetPoopEntriesByDateRangeUseCase(this.repository);

  Future<List<PoopEntry>> execute(int childId, DateTime startDate, DateTime endDate) async {
    return await repository.getPoopEntriesByDateRange(childId, startDate, endDate);
  }
}

class GetPoopEntryByIdUseCase {
  final PoopRepository repository;

  GetPoopEntryByIdUseCase(this.repository);

  Future<PoopEntry?> execute(int id) async {
    return await repository.getPoopEntryById(id);
  }
}

class AddPoopEntryUseCase {
  final PoopRepository repository;

  AddPoopEntryUseCase(this.repository);

  Future<int> execute(PoopEntry entry) async {
    return await repository.addPoopEntry(entry);
  }
}

class UpdatePoopEntryUseCase {
  final PoopRepository repository;

  UpdatePoopEntryUseCase(this.repository);

  Future<void> execute(PoopEntry entry) async {
    await repository.updatePoopEntry(entry);
  }
}

class DeletePoopEntryUseCase {
  final PoopRepository repository;

  DeletePoopEntryUseCase(this.repository);

  Future<void> execute(int id) async {
    await repository.deletePoopEntry(id);
  }
}

class GetPoopEntriesGroupedByDayUseCase {
  final PoopRepository repository;

  GetPoopEntriesGroupedByDayUseCase(this.repository);

  Future<Map<DateTime, List<PoopEntry>>> execute(int childId, DateTime month) async {
    return await repository.getPoopEntriesGroupedByDay(childId, month);
  }
}

class GetPoopCountByDateRangeUseCase {
  final PoopRepository repository;

  GetPoopCountByDateRangeUseCase(this.repository);

  Future<int> execute(int childId, DateTime startDate, DateTime endDate) async {
    return await repository.getPoopCountByDateRange(childId, startDate, endDate);
  }
} 