import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poopapp/features/poop_tracking/domain/entities/child.dart';
import 'package:poopapp/features/poop_tracking/domain/usecases/child_usecases.dart';

// Events
abstract class ChildEvent extends Equatable {
  const ChildEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllChildrenEvent extends ChildEvent {}

class LoadChildEvent extends ChildEvent {
  final int id;

  const LoadChildEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class AddChildEvent extends ChildEvent {
  final Child child;

  const AddChildEvent(this.child);

  @override
  List<Object?> get props => [child];
}

class UpdateChildEvent extends ChildEvent {
  final Child child;

  const UpdateChildEvent(this.child);

  @override
  List<Object?> get props => [child];
}

class DeleteChildEvent extends ChildEvent {
  final int id;

  const DeleteChildEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadCurrentChildEvent extends ChildEvent {}

class SetCurrentChildEvent extends ChildEvent {
  final int childId;

  const SetCurrentChildEvent(this.childId);

  @override
  List<Object?> get props => [childId];
}

// States
abstract class ChildState extends Equatable {
  const ChildState();

  @override
  List<Object?> get props => [];
}

class ChildInitialState extends ChildState {}

class ChildLoadingState extends ChildState {}

class ChildrenLoadedState extends ChildState {
  final List<Child> children;

  const ChildrenLoadedState(this.children);

  @override
  List<Object?> get props => [children];
}

class ChildLoadedState extends ChildState {
  final Child child;

  const ChildLoadedState(this.child);

  @override
  List<Object?> get props => [child];
}

class CurrentChildLoadedState extends ChildState {
  final Child? child;

  const CurrentChildLoadedState(this.child);

  @override
  List<Object?> get props => [child];
}

class ChildOperationSuccessState extends ChildState {
  final String message;

  const ChildOperationSuccessState(this.message);

  @override
  List<Object?> get props => [message];
}

class ChildErrorState extends ChildState {
  final String message;

  const ChildErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class ChildBloc extends Bloc<ChildEvent, ChildState> {
  final GetAllChildrenUseCase getAllChildren;
  final GetChildByIdUseCase getChildById;
  final AddChildUseCase addChild;
  final UpdateChildUseCase updateChild;
  final DeleteChildUseCase deleteChild;
  final GetCurrentChildUseCase getCurrentChild;
  final SetCurrentChildUseCase setCurrentChild;

  ChildBloc({
    required this.getAllChildren,
    required this.getChildById,
    required this.addChild,
    required this.updateChild,
    required this.deleteChild,
    required this.getCurrentChild,
    required this.setCurrentChild,
  }) : super(ChildInitialState()) {
    on<LoadAllChildrenEvent>(_onLoadAllChildren);
    on<LoadChildEvent>(_onLoadChild);
    on<AddChildEvent>(_onAddChild);
    on<UpdateChildEvent>(_onUpdateChild);
    on<DeleteChildEvent>(_onDeleteChild);
    on<LoadCurrentChildEvent>(_onLoadCurrentChild);
    on<SetCurrentChildEvent>(_onSetCurrentChild);
  }

  Future<void> _onLoadAllChildren(LoadAllChildrenEvent event, Emitter<ChildState> emit) async {
    emit(ChildLoadingState());
    try {
      final children = await getAllChildren.execute();
      emit(ChildrenLoadedState(children));
    } catch (e) {
      emit(ChildErrorState('Failed to load children: ${e.toString()}'));
    }
  }

  Future<void> _onLoadChild(LoadChildEvent event, Emitter<ChildState> emit) async {
    emit(ChildLoadingState());
    try {
      final child = await getChildById.execute(event.id);
      if (child != null) {
        emit(ChildLoadedState(child));
      } else {
        emit(const ChildErrorState('Child not found'));
      }
    } catch (e) {
      emit(ChildErrorState('Failed to load child: ${e.toString()}'));
    }
  }

  Future<void> _onAddChild(AddChildEvent event, Emitter<ChildState> emit) async {
    emit(ChildLoadingState());
    try {
      final id = await addChild.execute(event.child);
      emit(const ChildOperationSuccessState('Child added successfully'));
      add(LoadAllChildrenEvent());
      if (id > 0) {
        add(SetCurrentChildEvent(id));
      }
    } catch (e) {
      emit(ChildErrorState('Failed to add child: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateChild(UpdateChildEvent event, Emitter<ChildState> emit) async {
    emit(ChildLoadingState());
    try {
      await updateChild.execute(event.child);
      emit(const ChildOperationSuccessState('Child updated successfully'));
      add(LoadAllChildrenEvent());
      add(LoadCurrentChildEvent());
    } catch (e) {
      emit(ChildErrorState('Failed to update child: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteChild(DeleteChildEvent event, Emitter<ChildState> emit) async {
    emit(ChildLoadingState());
    try {
      await deleteChild.execute(event.id);
      emit(const ChildOperationSuccessState('Child deleted successfully'));
      add(LoadAllChildrenEvent());
      add(LoadCurrentChildEvent());
    } catch (e) {
      emit(ChildErrorState('Failed to delete child: ${e.toString()}'));
    }
  }

  Future<void> _onLoadCurrentChild(LoadCurrentChildEvent event, Emitter<ChildState> emit) async {
    emit(ChildLoadingState());
    try {
      final child = await getCurrentChild.execute();
      emit(CurrentChildLoadedState(child));
    } catch (e) {
      emit(ChildErrorState('Failed to load current child: ${e.toString()}'));
    }
  }

  Future<void> _onSetCurrentChild(SetCurrentChildEvent event, Emitter<ChildState> emit) async {
    emit(ChildLoadingState());
    try {
      await setCurrentChild.execute(event.childId);
      emit(const ChildOperationSuccessState('Current child set successfully'));
      add(LoadCurrentChildEvent());
    } catch (e) {
      emit(ChildErrorState('Failed to set current child: ${e.toString()}'));
    }
  }
} 