class FeedbackData {
  final String id;
  final Map<String, double> location;
  final String category;
  final String comments;
  final DateTime timestamp;
  final String? userName;
  final String? userRole;
  final String? guardianName;
  final String? guardianRole;

  FeedbackData({
    required this.id,
    required this.location,
    required this.category,
    required this.comments,
    required this.timestamp,
    this.userName,
    this.userRole,
    this.guardianName,
    this.guardianRole,
  });

  factory FeedbackData.fromJson(Map<String, dynamic> feedback) {
    return FeedbackData(
      id: feedback['_id'],
      location: {
        'latitude': feedback['location']['latitude'].toDouble(),
        'longitude': feedback['location']['longitude'].toDouble(),
      },
      category: feedback['category'],
      comments: feedback['comment'],
      timestamp: DateTime.tryParse(feedback['timestamp'] ?? '') ?? DateTime.now(),

      // Handle the case where userId may not be present
      userName: feedback['userId'] != null ? feedback['userId']['name'] : null,
      userRole: feedback['userId'] != null ? feedback['userId']['role'] : null,

      // Handle the case where guardianId may not be present
      guardianName: feedback['guardianId'] != null ? feedback['guardianId']['name'] : null,
      guardianRole: feedback['guardianId'] != null ? feedback['guardianId']['role'] : null,
    );
  }
}



class UserData {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String password;
  final String confirmPasswrd;

  UserData({
    required this.id,
    required this.phoneNumber,
    required this.name,
    required this.password,
    required this.email,
    required this.confirmPasswrd,
  });

  factory UserData.fromJson(Map<String, dynamic> user) {
    return UserData(
        id: user['id'],
        phoneNumber: user['phoneNumber'],
        name: user['name'],
        password: user['password'],
        email: user['email'],
        confirmPasswrd: user['confirmPassword']);
  }
}

class User {
  final String name;
  final String email;
  final String phoneNumber;
  final String password;
  final String confirmPassword;
  final String role;

  User({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.confirmPassword,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "phone": phoneNumber,  // Map field names accordingly
      "password": password,
      "confirmPassword": confirmPassword,
      "role": role,
    };
  }
}

class Guardian {
  final String id;
  final String name;
  final String avatar;
  final String address;
  final String email;
  final String phoneNumber;
  final String password;
  final String role;
  final List<Map<String, String>>? userId; // List of maps containing name and phone (as String)

  Guardian({
    required this.id,
    required this.name,
    required this.avatar,
    required this.address,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.role,
    this.userId,
  });

  factory Guardian.fromJson(Map<String, dynamic> guardian) {
    return Guardian(
      id: guardian['_id'],
      name: guardian['name'],
      avatar: guardian['avatar'],
      address: guardian['address'],
      email: guardian['email'],
      phoneNumber: guardian['phoneNumber'],
      password: guardian['password'],
      role: guardian['role'],
      userId: guardian['userId'] != null
          ? (guardian['userId'] as List<dynamic>)
          .map((user) => Map<String, String>.from(user as Map))
          .toList()
          : null,
    );
  }
}


