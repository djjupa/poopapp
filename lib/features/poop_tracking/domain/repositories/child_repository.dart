import 'package:poopapp/features/poop_tracking/domain/entities/child.dart';

abstract class ChildRepository {
  Future<List<Child>> getAllChildren();
  Future<Child?> getChildById(int id);
  Future<int> addChild(Child child);
  Future<void> updateChild(Child child);
  Future<void> deleteChild(int id);
  Future<Child?> getCurrentChild();
  Future<void> setCurrentChild(int childId);
} 