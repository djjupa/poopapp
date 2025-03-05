import 'package:poopapp/core/constants/app_constants.dart';
import 'package:poopapp/core/utils/database_helper.dart';
import 'package:poopapp/features/poop_tracking/data/models/child_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ChildLocalDataSource {
  Future<List<ChildModel>> getAllChildren();
  Future<ChildModel?> getChildById(int id);
  Future<int> addChild(ChildModel child);
  Future<void> updateChild(ChildModel child);
  Future<void> deleteChild(int id);
  Future<ChildModel?> getCurrentChild();
  Future<void> setCurrentChild(int childId);
}

class ChildLocalDataSourceImpl implements ChildLocalDataSource {
  final DatabaseHelper databaseHelper;
  final SharedPreferences sharedPreferences;

  ChildLocalDataSourceImpl({
    required this.databaseHelper,
    required this.sharedPreferences,
  });

  @override
  Future<List<ChildModel>> getAllChildren() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.childTableName,
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => ChildModel.fromMap(maps[i]));
  }

  @override
  Future<ChildModel?> getChildById(int id) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.childTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return ChildModel.fromMap(maps.first);
  }

  @override
  Future<int> addChild(ChildModel child) async {
    final db = await databaseHelper.database;
    return await db.insert(
      AppConstants.childTableName,
      child.toMap(),
    );
  }

  @override
  Future<void> updateChild(ChildModel child) async {
    final db = await databaseHelper.database;
    await db.update(
      AppConstants.childTableName,
      child.toMap(),
      where: 'id = ?',
      whereArgs: [child.id],
    );
  }

  @override
  Future<void> deleteChild(int id) async {
    final db = await databaseHelper.database;
    await db.delete(
      AppConstants.childTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    // If current child is deleted, clear current child preference
    final currentChildId = sharedPreferences.getInt(AppConstants.currentChildKey);
    if (currentChildId == id) {
      await sharedPreferences.remove(AppConstants.currentChildKey);
    }
  }

  @override
  Future<ChildModel?> getCurrentChild() async {
    final currentChildId = sharedPreferences.getInt(AppConstants.currentChildKey);
    if (currentChildId == null) {
      // If no current child, get the first one as default
      final children = await getAllChildren();
      if (children.isNotEmpty) {
        await setCurrentChild(children.first.id!);
        return children.first;
      }
      return null;
    }
    return getChildById(currentChildId);
  }

  @override
  Future<void> setCurrentChild(int childId) async {
    await sharedPreferences.setInt(AppConstants.currentChildKey, childId);
  }
} 