import 'package:json_annotation/json_annotation.dart';
import 'package:poopapp/features/poop_tracking/domain/entities/poop_entry.dart';

part 'poop_entry_model.g.dart';

@JsonSerializable()
class PoopEntryModel extends PoopEntry {
  const PoopEntryModel({
    super.id,
    required super.childId,
    required super.dateTime,
    required super.consistency,
    required super.color,
    super.feeling,
    super.notes,
    super.hasBlood = false,
    super.hasMucus = false,
    super.images,
  });
  
  factory PoopEntryModel.fromJson(Map<String, dynamic> json) => _$PoopEntryModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$PoopEntryModelToJson(this);
  
  factory PoopEntryModel.fromEntity(PoopEntry entry) {
    return PoopEntryModel(
      id: entry.id,
      childId: entry.childId,
      dateTime: entry.dateTime,
      consistency: entry.consistency,
      color: entry.color,
      feeling: entry.feeling,
      notes: entry.notes,
      hasBlood: entry.hasBlood,
      hasMucus: entry.hasMucus,
      images: entry.images,
    );
  }
  
  factory PoopEntryModel.fromMap(Map<String, dynamic> map) {
    return PoopEntryModel(
      id: map['id'] as int?,
      childId: map['child_id'] as int,
      dateTime: DateTime.parse(map['date_time'] as String),
      consistency: PoopConsistency.values[map['consistency'] as int],
      color: PoopColor.values[map['color'] as int],
      feeling: map['feeling'] != null ? FeelingSentiment.values[map['feeling'] as int] : null,
      notes: map['notes'] as String?,
      hasBlood: (map['has_blood'] as int) == 1,
      hasMucus: (map['has_mucus'] as int) == 1,
      images: map['images'] != null ? (map['images'] as String).split(',') : null,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'child_id': childId,
      'date_time': dateTime.toIso8601String(),
      'consistency': consistency.index,
      'color': color.index,
      'feeling': feeling?.index,
      'notes': notes,
      'has_blood': hasBlood ? 1 : 0,
      'has_mucus': hasMucus ? 1 : 0,
      'images': images?.join(','),
    };
  }
} 