// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class TodoModels {
  int id;

  String title;

  bool completed;
  TodoModels({
    required this.id,
    required this.title,
    required this.completed,
  });

  TodoModels copyWith({
    int? id,
    String? title,
    bool? completed,
  }) {
    return TodoModels(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'completed': completed,
    };
  }

  factory TodoModels.fromMap(Map<String, dynamic> map) {
    return TodoModels(
      id: map['id'] as int,
      title: map['title'] as String,
      completed: map['completed'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory TodoModels.fromJson(String source) =>
      TodoModels.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'TodoModels(id: $id, title: $title, completed: $completed)';

  @override
  bool operator ==(covariant TodoModels other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.completed == completed;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ completed.hashCode;
}
