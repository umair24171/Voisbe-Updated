import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/home_screen/provider/display_notes_provider.dart';
import 'package:social_notes/screens/user_profile/other_user_profile.dart';
import 'package:social_notes/screens/user_profile/provider/user_profile_provider.dart';

class LikeScreen extends StatelessWidget {
  const LikeScreen({super.key, required this.likes});
  final List likes;

  // @override
  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context, listen: false).user;
    // var otherUser =
    //     Provider.of<UserProfileProvider>(context, listen: false).otherUser;
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        surfaceTintColor: whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: Text(
          'Likes',
          style: TextStyle(
              fontSize: 18,
              fontFamily: khulaRegular,
              fontWeight: FontWeight.w700),
        ),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('uid', whereIn: likes)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    UserModel user =
                        UserModel.fromMap(snapshot.data!.docs[index].data());
                    return ListTile(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OtherUserProfile(userId: user.uid),
                            ));
                      },
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(user.photoUrl),
                      ),
                      title: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              user.name,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: khulaRegular,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          if (user.isVerified) verifiedIcon()
                          // Image.network(
                          //   'https://media.istockphoto.com/id/1396933001/vector/vector-blue-verified-badge.jpg?s=612x612&w=0&k=20&c=aBJ2JAzbOfQpv2OCSr0k8kYe0XHutOGBAJuVjvWvPrQ=',
                          //   height: 20,
                          //   width: 20,
                          // ),
                        ],
                      ),
                      // subtitle: Text(
                      //   'User Bio',
                      //   style: TextStyle(
                      //       fontSize: 14,
                      //       fontFamily: khulaRegular,
                      //       fontWeight: FontWeight.w400),
                      // ),
                      trailing: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              UserModel followUSer =
                                  UserModel.fromMap(snapshot.data!.data()!);
                              bool isContains = followUSer.followers
                                  .contains(userProvider!.uid);
                              String text = '';
                              if (followUSer.isPrivate) {
                                if (followUSer.followReq
                                    .contains(userProvider.uid)) {
                                  text = 'Requested';
                                } else if (followUSer.followers
                                    .contains(userProvider.uid)) {
                                  text = 'Following';
                                } else if (followUSer.following
                                    .contains(userProvider.uid)) {
                                  text = 'Follow back';
                                } else {
                                  text = 'Follow';
                                }
                              } else {
                                if (followUSer.followers
                                    .contains(userProvider.uid)) {
                                  text = 'Following';
                                } else if (followUSer.following
                                    .contains(userProvider.uid)) {
                                  text = 'Follow back';
                                } else {
                                  text = 'Follow';
                                }
                              }
                              return ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: const Size(105, 20),
                                    padding: const EdgeInsets.all(0),
                                    minimumSize: const Size(105, 35),
                                    elevation: 0,
                                    backgroundColor: isContains
                                        ? Colors.transparent
                                        : blackColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: BorderSide(
                                            color: isContains
                                                ? blackColor
                                                : Colors.transparent,
                                            width: 1)),
                                  ),
                                  onPressed: () {
                                    Provider.of<UserProfileProvider>(context,
                                            listen: false)
                                        .followUser(userProvider, user);
                                  },
                                  child: Text(
                                    text,
                                    style: TextStyle(
                                        color: isContains
                                            ? blackColor
                                            : whiteColor,
                                        fontSize: 14,
                                        fontFamily: khulaRegular,
                                        fontWeight: FontWeight.w700),
                                  ));
                            } else {
                              return SizedBox();
                            }
                          }),
                    );
                  });
            } else {
              return SizedBox();
            }
          }),
    );
  }
}
