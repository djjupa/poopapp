import 'package:json_annotation/json_annotation.dart';
import 'package:poopapp/features/poop_tracking/domain/entities/child.dart';

part 'child_model.g.dart';

@JsonSerializable()
class ChildModel extends Child {
  const ChildModel({
    super.id,
    required super.name,
    required super.birthDate,
    super.avatarPath,
  });
  
  factory ChildModel.fromJson(Map<String, dynamic> json) => _$ChildModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$ChildModelToJson(this);
  
  factory ChildModel.fromEntity(Child child) {
    return ChildModel(
      id: child.id,
      name: child.name,
      birthDate: child.birthDate,
      avatarPath: child.avatarPath,
    );
  }
  
  factory ChildModel.fromMap(Map<String, dynamic> map) {
    return ChildModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      birthDate: DateTime.parse(map['birth_date'] as String),
      avatarPath: map['avatar_path'] as String?,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'birth_date': birthDate.toIso8601String(),
      'avatar_path': avatarPath,
    };
  }
} 