class TestModel {
  final int userId;
  final int id;
  final String title;
  final bool completed;

  TestModel({
    required this.userId,
    required this.id,
    required this.title,
    required this.completed,
  });

  // Correctly implementing the fromJson factory constructor
  factory TestModel.fromJson(Map<String, dynamic> json) {
    return TestModel(
      userId: json['userId'] as int,
      id: json['id'] as int,
      title: json['title'] as String,
      completed: json['completed'] as bool,
    );
  }
  @override
  String toString() {
    return 'TestModel(userId: $userId, id: $id, title: "$title", completed: $completed)';
  }
}
