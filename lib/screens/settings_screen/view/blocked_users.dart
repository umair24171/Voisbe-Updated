import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/navigation.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/settings_screen/controllers/settings_provider.dart';
import 'package:social_notes/screens/settings_screen/view/widgets/subscription_list_tile.dart';
import 'package:social_notes/screens/user_profile/other_user_profile.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  @override
  void initState() {
    Provider.of<SettingsProvider>(context, listen: false).getBlockedUsers(
        Provider.of<UserProvider>(context, listen: false).user!.uid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          backgroundColor: whiteColor,
          leading: IconButton(
            onPressed: () {
              navPop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: blackColor,
              size: 30,
            ),
          ),
          centerTitle: true,
          title: Text(
            'Blocked Users',
            style: TextStyle(
                color: blackColor,
                fontSize: 18,
                fontFamily: khulaBold,
                fontWeight: FontWeight.w700),
          ),
        ),
        body: Consumer<SettingsProvider>(builder: (context, settingsPro, _) {
          return ListView.builder(
            itemCount: settingsPro.blockedUsers.length,
            itemBuilder: (context, index) {
              UserModel user = settingsPro.blockedUsers[index];
              return BlockedUserListTile(
                user: user,
              );
            },
          );
        }));
  }
}

class BlockedUserListTile extends StatelessWidget {
  const BlockedUserListTile({
    super.key,
    required this.user,
  });
  final UserModel user;
  @override
  Widget build(BuildContext context) {
    var currentId = Provider.of<UserProvider>(context, listen: false).user!.uid;
    return ListTile(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtherUserProfile(userId: user.uid),
              ));
        },
        leading: CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(
            user.photoUrl,
          ),
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                user.name,
                style: TextStyle(
                    color: blackColor,
                    fontSize: 18,
                    fontFamily: khulaRegular,
                    fontWeight: FontWeight.w600),
              ),
            ),
            if (user.isVerified) verifiedIcon()
            // Image.network(
            //   'https://media.istockphoto.com/id/1396933001/vector/vector-blue-verified-badge.jpg?s=612x612&w=0&k=20&c=aBJ2JAzbOfQpv2OCSr0k8kYe0XHutOGBAJuVjvWvPrQ=',
            //   height: 20,
            //   width: 20,
            // )
          ],
        ),
        trailing: InkWell(
          onTap: () {
            Provider.of<SettingsProvider>(context, listen: false)
                .unblockUser(currentId, user.uid, context);
          },
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
              // width: 33,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: whiteColor,
                border: Border.all(
                  width: 1,
                  color: const Color(0xff868686),
                ),
              ),
              child: Text('Unblock',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: blackColor,
                      fontSize: 18,
                      fontFamily: khulaRegular,
                      fontWeight: FontWeight.w600))),
        ));
  }
}
