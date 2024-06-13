import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/navigation.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/settings_screen/controllers/settings_provider.dart';
import 'package:social_notes/screens/settings_screen/view/widgets/subscription_list_tile.dart';

class EditSubscriptionsScreen extends StatefulWidget {
  const EditSubscriptionsScreen({super.key});

  @override
  State<EditSubscriptionsScreen> createState() =>
      _EditSubscriptionsScreenState();
}

class _EditSubscriptionsScreenState extends State<EditSubscriptionsScreen> {
  @override
  void initState() {
    var subPro = Provider.of<SettingsProvider>(context, listen: false);
    subPro.getUserSubscriptions(
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
            'Edit Subscriptions',
            style: TextStyle(
                color: blackColor,
                fontSize: 18,
                fontFamily: khulaBold,
                fontWeight: FontWeight.w700),
          ),
        ),
        body: Consumer<SettingsProvider>(builder: (context, settingPro, _) {
          return ListView.builder(
            itemCount: settingPro.userSubscriptions.length,
            itemBuilder: (context, index) {
              UserModel user = settingPro.userSubscriptions[index];
              return SubsccriptionListTile(
                  isVerified: user.isVerified,
                  image: user.photoUrl,
                  userId: user.uid,
                  currentUserId:
                      Provider.of<UserProvider>(context, listen: false)
                          .user!
                          .uid,
                  username: user.name,
                  subscritpionStatus: 'Cancel');
            },
          );
        }));
  }
}
