import 'package:equatable/equatable.dart';

enum PoopConsistency {
  liquid,
  soft,
  normal,
  hard,
  veryHard,
}

enum PoopColor {
  brown,
  darkBrown,
  lightBrown,
  yellow,
  green,
  red,
  black,
  white,
}

enum FeelingSentiment {
  veryHappy,
  happy,
  neutral,
  uncomfortable,
  painful,
  verySad,
  angry,
  sick,
  embarrassed,
}

class PoopEntry extends Equatable {
  final int? id;
  final int childId;
  final DateTime dateTime;
  final PoopConsistency consistency;
  final PoopColor color;
  final FeelingSentiment? feeling;
  final String? notes;
  final bool hasBlood;
  final bool hasMucus;
  final List<String>? images;
  
  const PoopEntry({
    this.id,
    required this.childId,
    required this.dateTime,
    required this.consistency,
    required this.color,
    this.feeling,
    this.notes,
    this.hasBlood = false,
    this.hasMucus = false,
    this.images,
  });
  
  @override
  List<Object?> get props => [
    id,
    childId,
    dateTime,
    consistency,
    color,
    feeling,
    notes,
    hasBlood,
    hasMucus,
    images,
  ];
} 