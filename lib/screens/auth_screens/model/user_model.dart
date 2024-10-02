import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String uid;
  String name;
  String username;
  String password;
  String email;
  String photoUrl;
  List following;
  List followers;
  String bio;
  String link;
  String contact;
  List blockedUsers;
  List blockedByUsers;
  List closeFriends;
  bool isSubscriptionEnable;
  double price;
  List soundPacks;
  String token;
  List subscribedUsers = [];
  List subscribedSoundPacks = [];
  bool isVerified;
  bool isPrivate;
  DateTime dateOfBirth;
  List followReq;
  List followTo;
  List mutedAccouts;
  bool isLike;
  bool isReply;
  bool isFollows;
  bool isTwoFa;
  List notificationsEnable;
  bool isOtpVerified;
  // bool deactivate;

  String pushToken;
  UserModel(
      {required this.uid,
      required this.username,
      required this.email,
      required this.photoUrl,
      required this.password,
      required this.closeFriends,
      required this.notificationsEnable,
      required this.isOtpVerified,
      // required this.deactivate,
      required this.isLike,
      required this.isReply,
      required this.isFollows,
      required this.isTwoFa,
      required this.following,
      required this.pushToken,
      required this.blockedUsers,
      required this.blockedByUsers,
      required this.isVerified,
      required this.dateOfBirth,
      required this.token,
      required this.bio,
      required this.subscribedUsers,
      required this.contact,
      required this.name,
      required this.subscribedSoundPacks,
      required this.isSubscriptionEnable,
      required this.mutedAccouts,
      required this.link,
      required this.isPrivate,
      required this.followReq,
      required this.followTo,
      required this.price,
      required this.soundPacks,
      required this.followers});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      // 'deactivate': deactivate,
      'uid': uid,
      'username': username,
      'email': email,
      'pushToken': pushToken,
      'photoUrl': photoUrl,
      'following': following,
      'password': password,
      'closeFriends': closeFriends,
      'mutedAccouts': mutedAccouts,
      'isOtpVerified': isOtpVerified,
      'isLike': isLike,
      'isFollows': isFollows,
      'isReply': isReply,
      'isPrivate': isPrivate,
      'token': token,
      'blockedUsers': blockedUsers,
      'dateOfBirth': dateOfBirth,
      'blockedByUsers': blockedByUsers,
      'followReq': followReq,
      'isVerified': isVerified,
      'followTo': followTo,
      'name': name,
      'followers': followers,
      'subscribedUsers': subscribedUsers, // Add this line
      'bio': bio,
      'subscribedSoundPacks': subscribedSoundPacks,
      'link': link,
      'price': price,
      'contact': contact,
      'isSubscriptionEnable': isSubscriptionEnable,
      'soundPacks': soundPacks,
      'isTwoFa': isTwoFa,
      'notificationsEnable': notificationsEnable
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
        isTwoFa: map['isTwoFa'] as bool,
        isFollows: map['isFollows'] as bool,
        isLike: map['isLike'] as bool,
        isOtpVerified: map['isOtpVerified'] as bool,
        isReply: map['isReply'],
        notificationsEnable: List.from((map['notificationsEnable'] as List)),
        // deactivate: map['deactivate'] as bool,
        uid: map['uid'] as String,
        username: map['username'] as String,
        email: map['email'] as String,
        pushToken: map['pushToken'] as String,
        isVerified: map['isVerified'] as bool,
        photoUrl: map['photoUrl'] as String,
        isPrivate: map['isPrivate'] as bool,
        dateOfBirth: (map['dateOfBirth'] as Timestamp).toDate(),
        token: map['token'] as String,
        password: map['password'] as String,
        following: List.from((map['following'] as List)),
        mutedAccouts: List.from((map['mutedAccouts'] as List)),
        followReq: List.from((map['followReq'] as List)),
        followTo: List.from((map['followTo'] as List)),
        subscribedUsers: List.from(
          (map['subscribedUsers'] as List),
        ),
        subscribedSoundPacks: List.from((map['subscribedSoundPacks'] as List)),
        bio: map['bio'] as String,
        contact: map['contact'] as String,
        isSubscriptionEnable: map['isSubscriptionEnable'] as bool,
        blockedUsers: List.from((map['blockedUsers'] as List)),
        blockedByUsers: List.from((map['blockedByUsers'] as List)),
        closeFriends: List.from((map['closeFriends'] as List)),
        name: map['name'] as String,
        link: map['link'] as String,
        price: double.parse(map['price'].toString()),
        soundPacks: List.from(
          (map['soundPacks'] as List),
        ),
        followers: List.from(
          (map['followers'] as List),
        ));
  }

  // String toJson() => json.encode(toMap());

  // factory UserModel.fromJson(String source) =>
  //     UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
