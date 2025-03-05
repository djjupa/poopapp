import 'package:equatable/equatable.dart';

class Child extends Equatable {
  final int? id;
  final String name;
  final DateTime birthDate;
  final String? avatarPath;
  
  const Child({
    this.id,
    required this.name,
    required this.birthDate,
    this.avatarPath,
  });
  
  @override
  List<Object?> get props => [id, name, birthDate, avatarPath];
} 