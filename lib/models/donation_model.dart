class DonationModel {
  final String id;
  final String userId;
  final String title;
  final String status; // 'active' | 'completed' | 'cancelled'
  final DateTime createdAt;

  DonationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.status,
    required this.createdAt,
  });

  factory DonationModel.fromMap(Map<String, dynamic> map) {
    return DonationModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String? ?? 'Donation',
      status: map['status'] as String? ?? 'active',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}


