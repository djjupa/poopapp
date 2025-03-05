import 'package:poopapp/features/poop_tracking/domain/entities/child.dart';
import 'package:poopapp/features/poop_tracking/domain/repositories/child_repository.dart';

class GetAllChildrenUseCase {
  final ChildRepository repository;

  GetAllChildrenUseCase(this.repository);

  Future<List<Child>> execute() async {
    return await repository.getAllChildren();
  }
}

class GetChildByIdUseCase {
  final ChildRepository repository;

  GetChildByIdUseCase(this.repository);

  Future<Child?> execute(int id) async {
    return await repository.getChildById(id);
  }
}

class AddChildUseCase {
  final ChildRepository repository;

  AddChildUseCase(this.repository);

  Future<int> execute(Child child) async {
    return await repository.addChild(child);
  }
}

class UpdateChildUseCase {
  final ChildRepository repository;

  UpdateChildUseCase(this.repository);

  Future<void> execute(Child child) async {
    await repository.updateChild(child);
  }
}

class DeleteChildUseCase {
  final ChildRepository repository;

  DeleteChildUseCase(this.repository);

  Future<void> execute(int id) async {
    await repository.deleteChild(id);
  }
}

class GetCurrentChildUseCase {
  final ChildRepository repository;

  GetCurrentChildUseCase(this.repository);

  Future<Child?> execute() async {
    return await repository.getCurrentChild();
  }
}

class SetCurrentChildUseCase {
  final ChildRepository repository;

  SetCurrentChildUseCase(this.repository);

  Future<void> execute(int childId) async {
    await repository.setCurrentChild(childId);
  }
} 