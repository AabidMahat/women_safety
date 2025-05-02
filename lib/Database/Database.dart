class FeedbackData {
  final String id;
  final Map<String, double> location;// Store coordinates as [longitude, latitude]
  final String category;
  final String comments;
  final DateTime timestamp;
  final String? userName;
  final String? userRole;
  final String ? userAvatar;
  final String? guardianName;
  final String? guardianRole;
  final String? guardianAvatar;

  FeedbackData({
    required this.id,
    required this.location,
    required this.category,
    required this.comments,
    required this.timestamp,
    this.userName,
    this.userRole,
    this.userAvatar,
    this.guardianName,
    this.guardianRole,
    this.guardianAvatar
  });

  factory FeedbackData.fromJson(Map<String, dynamic> feedback) {
    return FeedbackData(
      id: feedback['_id'],
      location: {
        'latitude': feedback['location']['latitude'].toDouble(),
        'longitude': feedback['location']['longitude'].toDouble(),
      }, // Parse the coordinates array
      category: feedback['category'],
      comments: feedback['comment'],
      timestamp: DateTime.tryParse(feedback['timestamp'] ?? '') ?? DateTime.now(),

      // Handle the case where userId may not be present
      userName: feedback['userId'] != null ? feedback['userId']['name'] : null,
      userRole: feedback['userId'] != null ? feedback['userId']['role'] : null,
      userAvatar: feedback['userId'] != null ? feedback['userId']['avatar'] : null,


      // Handle the case where guardianId may not be present
      guardianName: feedback['guardianId'] != null ? feedback['guardianId']['name'] : null,
      guardianRole: feedback['guardianId'] != null ? feedback['guardianId']['role'] : null,
      guardianAvatar: feedback['guardianId'] != null ? feedback['guardianId']['avatar'] : null,

    );
  }
}


class UserData {
  final String avatar;
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String password;
  final String confirmPassword;
  final String messageTemplate;
  final List<String> videoUrls;
  final List<String> audioUrls;
  final List<Map<String, dynamic>> guardians;

  UserData({
    required this.avatar,
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.confirmPassword,
    required this.messageTemplate,
    required this.videoUrls,
    required this.audioUrls,
    required this.guardians,
  });

  // Factory constructor to create a UserData instance from JSON
  factory UserData.fromJson(Map<String, dynamic> user) {
    return UserData(
      avatar: user['avatar'] ?? 'default.png',
      id: user['id'] ?? '',
      name: user['name'] ?? 'Unknown',
      email: user['email'] ?? '',
      phoneNumber: user['phoneNumber'] ?? '',
      password: user['password'] ?? '',
      confirmPassword: user['confirmPassword'] ?? '',
      messageTemplate: user['message_template'] ?? '',
      videoUrls: List<String>.from(user['videoUrl'] ?? []),
      audioUrls: List<String>.from(user['audioUrl'] ?? []),
      guardians: List<Map<String, dynamic>>.from(user['guardian'] ?? []),
    );
  }

  // Default user instance to use in case of an error or empty data
  static UserData defaultUser() {
    return UserData(
      avatar: "default.png",
      id: "",
      name: "Unknown",
      email: "",
      phoneNumber: "",
      password: "",
      confirmPassword: "",
      messageTemplate: "",
      videoUrls: [],
      audioUrls: [],
      guardians: [],
    );
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
      "phone": phoneNumber, // Map field names accordingly
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
  final List<Map<String, String>>?
      userId; // List of maps containing name and phone (as String)

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

class AudioFile {
  final String url;
  final String name;
  final String uploaderName;
  DateTime uploadTime;

  AudioFile({
    required this.url,
    required this.name,
    required this.uploaderName,
    required this.uploadTime,
  });
}

class VideoFile {
  final String url;
  final String name;
  DateTime uploadTime;
  final String uploaderName;

  VideoFile(
      {required this.url,
      required this.name,
      required this.uploadTime,
      required this.uploaderName});
}

class Request {
  final String id;
  final String name;
  final String phoneNumber;

  Request({required this.id, required this.name, required this.phoneNumber});

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      id: json['_id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
    );
  }
}

class UserAssignedGuardian {
  final String name;
  final String phoneNumber;
  final String status;

  UserAssignedGuardian(
      {required this.name, required this.phoneNumber, required this.status});

  factory UserAssignedGuardian.fromJson(Map<String, dynamic> json) {
    return UserAssignedGuardian(
      name: json['guardians']['name'],
      phoneNumber: json['guardians']['phoneNumber'],
      status: json['status'],
    );
  }
}


class Community{
  final String id;
  final String name;
  final String createdBy;
  DateTime createdAt;
  final String description;
  final String imageUrl;
  final int memberCount;

  Community(
      {required this.id, required this.name,required this.createdBy,
        required this.createdAt, required this.description,
        required this.imageUrl, this.memberCount=0});

  factory Community.fromJson(Map<String, dynamic> json){
    return Community(
      id: json["_id"],
      name: json["name"],
      createdBy: json["createdBy"],
      imageUrl: json["profileImage"],
      description: json["description"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? "") ?? DateTime.now(),
      memberCount: json["memberCount"] ?? 0,
    );
  }

}


class Post{
  final String id;
  final String title;
  final String createdBy;
  DateTime createdAt;
  final String description;
  final int likesCount;
  List<String> images;

  Post(
      {required this.id, required this.title,required this.createdBy,
        required this.createdAt, required this.description, this.likesCount=0, required this.images});

  factory Post.fromJson(Map<String, dynamic> json){
    return Post(
      id: json["_id"],
      title: json["title"],
      createdBy: json["createdBy"]["_id"],
      description: json["description"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? "") ?? DateTime.now(),
      likesCount: json["likesCount"] ?? 0,
      images : (json['images'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ??
        [],
    );
  }

}

class Comment{
  final String userName;
  final String comment;
  final String userImage;
  final DateTime createdAt;

  Comment(
      {required this.userName,required this.comment,
        required this.userImage, required this.createdAt});

  factory Comment.fromJson(Map<String, dynamic> json){
    return Comment(
        userName: json["userName"],
        comment: json["comment"],
        userImage: json["userImage"],
        createdAt: DateTime.tryParse(json["createdAt"] ?? "") ?? DateTime.now(),
    );
  }
}
