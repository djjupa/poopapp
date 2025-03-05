import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poopapp/features/poop_tracking/domain/entities/poop_entry.dart';
import 'package:poopapp/features/poop_tracking/domain/usecases/poop_usecases.dart';

// Events
abstract class PoopEvent extends Equatable {
  const PoopEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllPoopEntriesEvent extends PoopEvent {
  final int childId;

  const LoadAllPoopEntriesEvent(this.childId);

  @override
  List<Object?> get props => [childId];
}

class LoadPoopEntriesByDateRangeEvent extends PoopEvent {
  final int childId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadPoopEntriesByDateRangeEvent({
    required this.childId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [childId, startDate, endDate];
}

class LoadPoopEntryEvent extends PoopEvent {
  final int id;

  const LoadPoopEntryEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class AddPoopEntryEvent extends PoopEvent {
  final PoopEntry entry;

  const AddPoopEntryEvent(this.entry);

  @override
  List<Object?> get props => [entry];
}

class UpdatePoopEntryEvent extends PoopEvent {
  final PoopEntry entry;

  const UpdatePoopEntryEvent(this.entry);

  @override
  List<Object?> get props => [entry];
}

class DeletePoopEntryEvent extends PoopEvent {
  final int id;

  const DeletePoopEntryEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadPoopEntriesGroupedByDayEvent extends PoopEvent {
  final int childId;
  final DateTime month;

  const LoadPoopEntriesGroupedByDayEvent({
    required this.childId,
    required this.month,
  });

  @override
  List<Object?> get props => [childId, month];
}

class GetPoopCountByDateRangeEvent extends PoopEvent {
  final int childId;
  final DateTime startDate;
  final DateTime endDate;

  const GetPoopCountByDateRangeEvent({
    required this.childId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [childId, startDate, endDate];
}

// States
abstract class PoopState extends Equatable {
  const PoopState();

  @override
  List<Object?> get props => [];
}

class PoopInitialState extends PoopState {}

class PoopLoadingState extends PoopState {}

class PoopEntriesLoadedState extends PoopState {
  final List<PoopEntry> entries;

  const PoopEntriesLoadedState(this.entries);

  @override
  List<Object?> get props => [entries];
}

class PoopEntryLoadedState extends PoopState {
  final PoopEntry entry;

  const PoopEntryLoadedState(this.entry);

  @override
  List<Object?> get props => [entry];
}

class PoopEntriesGroupedByDayLoadedState extends PoopState {
  final Map<DateTime, List<PoopEntry>> groupedEntries;

  const PoopEntriesGroupedByDayLoadedState(this.groupedEntries);

  @override
  List<Object?> get props => [groupedEntries];
}

class PoopCountLoadedState extends PoopState {
  final int count;

  const PoopCountLoadedState(this.count);

  @override
  List<Object?> get props => [count];
}

class PoopOperationSuccessState extends PoopState {
  final String message;

  const PoopOperationSuccessState(this.message);

  @override
  List<Object?> get props => [message];
}

class PoopErrorState extends PoopState {
  final String message;

  const PoopErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class PoopBloc extends Bloc<PoopEvent, PoopState> {
  final GetAllPoopEntriesUseCase getAllPoopEntries;
  final GetPoopEntriesByDateRangeUseCase getPoopEntriesByDateRange;
  final GetPoopEntryByIdUseCase getPoopEntryById;
  final AddPoopEntryUseCase addPoopEntry;
  final UpdatePoopEntryUseCase updatePoopEntry;
  final DeletePoopEntryUseCase deletePoopEntry;
  final GetPoopEntriesGroupedByDayUseCase getPoopEntriesGroupedByDay;
  final GetPoopCountByDateRangeUseCase getPoopCountByDateRange;

  PoopBloc({
    required this.getAllPoopEntries,
    required this.getPoopEntriesByDateRange,
    required this.getPoopEntryById,
    required this.addPoopEntry,
    required this.updatePoopEntry,
    required this.deletePoopEntry,
    required this.getPoopEntriesGroupedByDay,
    required this.getPoopCountByDateRange,
  }) : super(PoopInitialState()) {
    on<LoadAllPoopEntriesEvent>(_onLoadAllPoopEntries);
    on<LoadPoopEntriesByDateRangeEvent>(_onLoadPoopEntriesByDateRange);
    on<LoadPoopEntryEvent>(_onLoadPoopEntry);
    on<AddPoopEntryEvent>(_onAddPoopEntry);
    on<UpdatePoopEntryEvent>(_onUpdatePoopEntry);
    on<DeletePoopEntryEvent>(_onDeletePoopEntry);
    on<LoadPoopEntriesGroupedByDayEvent>(_onLoadPoopEntriesGroupedByDay);
    on<GetPoopCountByDateRangeEvent>(_onGetPoopCountByDateRange);
  }

  Future<void> _onLoadAllPoopEntries(LoadAllPoopEntriesEvent event, Emitter<PoopState> emit) async {
    emit(PoopLoadingState());
    try {
      final entries = await getAllPoopEntries.execute(event.childId);
      emit(PoopEntriesLoadedState(entries));
    } catch (e) {
      emit(PoopErrorState('Failed to load poop entries: ${e.toString()}'));
    }
  }

  Future<void> _onLoadPoopEntriesByDateRange(LoadPoopEntriesByDateRangeEvent event, Emitter<PoopState> emit) async {
    emit(PoopLoadingState());
    try {
      final entries = await getPoopEntriesByDateRange.execute(
        event.childId,
        event.startDate,
        event.endDate,
      );
      emit(PoopEntriesLoadedState(entries));
    } catch (e) {
      emit(PoopErrorState('Failed to load poop entries by date range: ${e.toString()}'));
    }
  }

  Future<void> _onLoadPoopEntry(LoadPoopEntryEvent event, Emitter<PoopState> emit) async {
    emit(PoopLoadingState());
    try {
      final entry = await getPoopEntryById.execute(event.id);
      if (entry != null) {
        emit(PoopEntryLoadedState(entry));
      } else {
        emit(const PoopErrorState('Poop entry not found'));
      }
    } catch (e) {
      emit(PoopErrorState('Failed to load poop entry: ${e.toString()}'));
    }
  }

  Future<void> _onAddPoopEntry(AddPoopEntryEvent event, Emitter<PoopState> emit) async {
    emit(PoopLoadingState());
    try {
      await addPoopEntry.execute(event.entry);
      emit(const PoopOperationSuccessState('Poop entry added successfully'));
      add(LoadAllPoopEntriesEvent(event.entry.childId));
    } catch (e) {
      emit(PoopErrorState('Failed to add poop entry: ${e.toString()}'));
    }
  }

  Future<void> _onUpdatePoopEntry(UpdatePoopEntryEvent event, Emitter<PoopState> emit) async {
    emit(PoopLoadingState());
    try {
      await updatePoopEntry.execute(event.entry);
      emit(const PoopOperationSuccessState('Poop entry updated successfully'));
      add(LoadAllPoopEntriesEvent(event.entry.childId));
    } catch (e) {
      emit(PoopErrorState('Failed to update poop entry: ${e.toString()}'));
    }
  }

  Future<void> _onDeletePoopEntry(DeletePoopEntryEvent event, Emitter<PoopState> emit) async {
    emit(PoopLoadingState());
    try {
      final poopEntry = await getPoopEntryById.execute(event.id);
      if (poopEntry != null) {
        await deletePoopEntry.execute(event.id);
        emit(const PoopOperationSuccessState('Poop entry deleted successfully'));
        add(LoadAllPoopEntriesEvent(poopEntry.childId));
      } else {
        emit(const PoopErrorState('Poop entry not found'));
      }
    } catch (e) {
      emit(PoopErrorState('Failed to delete poop entry: ${e.toString()}'));
    }
  }

  Future<void> _onLoadPoopEntriesGroupedByDay(LoadPoopEntriesGroupedByDayEvent event, Emitter<PoopState> emit) async {
    emit(PoopLoadingState());
    try {
      final groupedEntries = await getPoopEntriesGroupedByDay.execute(
        event.childId,
        event.month,
      );
      emit(PoopEntriesGroupedByDayLoadedState(groupedEntries));
    } catch (e) {
      emit(PoopErrorState('Failed to load grouped poop entries: ${e.toString()}'));
    }
  }

  Future<void> _onGetPoopCountByDateRange(GetPoopCountByDateRangeEvent event, Emitter<PoopState> emit) async {
    emit(PoopLoadingState());
    try {
      final count = await getPoopCountByDateRange.execute(
        event.childId,
        event.startDate,
        event.endDate,
      );
      emit(PoopCountLoadedState(count));
    } catch (e) {
      emit(PoopErrorState('Failed to get poop count: ${e.toString()}'));
    }
  }
} 