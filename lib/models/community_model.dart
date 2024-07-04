import 'package:cloud_firestore/cloud_firestore.dart';


class Post {
  String id;
  String userId;
  String userName;
  String content;
  DateTime timestamp;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.timestamp,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'content': content,
      'timestamp': timestamp,
    };
  }
}

class Comment {
  String id;
  String userId;
  String userName;
  String content;
  DateTime timestamp;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.timestamp,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'content': content,
      'timestamp': timestamp,
    };
  }
}
