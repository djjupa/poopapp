import 'package:poopapp/features/poop_tracking/data/datasources/child_local_datasource.dart';
import 'package:poopapp/features/poop_tracking/data/models/child_model.dart';
import 'package:poopapp/features/poop_tracking/domain/entities/child.dart';
import 'package:poopapp/features/poop_tracking/domain/repositories/child_repository.dart';

class ChildRepositoryImpl implements ChildRepository {
  final ChildLocalDataSource localDataSource;

  ChildRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Child>> getAllChildren() async {
    final childModels = await localDataSource.getAllChildren();
    return childModels;
  }

  @override
  Future<Child?> getChildById(int id) async {
    return await localDataSource.getChildById(id);
  }

  @override
  Future<int> addChild(Child child) async {
    final childModel = ChildModel.fromEntity(child);
    return await localDataSource.addChild(childModel);
  }

  @override
  Future<void> updateChild(Child child) async {
    final childModel = ChildModel.fromEntity(child);
    await localDataSource.updateChild(childModel);
  }

  @override
  Future<void> deleteChild(int id) async {
    await localDataSource.deleteChild(id);
  }

  @override
  Future<Child?> getCurrentChild() async {
    return await localDataSource.getCurrentChild();
  }

  @override
  Future<void> setCurrentChild(int childId) async {
    await localDataSource.setCurrentChild(childId);
  }
} 