import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/navigation.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/profile_screen/model/report_user.dart';
import 'package:social_notes/screens/settings_screen/controllers/settings_provider.dart';
import 'package:social_notes/screens/user_profile/provider/user_profile_provider.dart';
import 'package:social_notes/screens/user_profile/view/widgets/confirm_report.dart';
import 'package:uuid/uuid.dart';

class ReportUser extends StatelessWidget {
  const ReportUser({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // var otherUser =
    //     Provider.of<UserProfileProvider>(context, listen: false).otherUser;
    var currentUser = Provider.of<UserProvider>(context, listen: false).user;
    return Consumer<UserProfileProvider>(builder: (context, otherUser, _) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Container(
              height: 6,
              width: 55,
              decoration: BoxDecoration(
                  color: const Color(0xffdcdcdc),
                  borderRadius: BorderRadius.circular(30)),
            ),
          ),
          Text(
            'Report User',
            style: TextStyle(
                fontFamily: khulaRegular,
                fontSize: 20,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            height: 10,
          ),
          Divider(
            endIndent: 0,
            indent: 0,
            height: 1,
            color: Colors.black.withOpacity(0.1),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 30,
            ),
            child: Text(
              'Why are you reporting this user?',
              style: TextStyle(
                  fontFamily: khulaRegular,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              'Your report is anonymous. If someone is in immediate danger, call the local emergency services - don’t wait.',
              style: TextStyle(
                  fontFamily: khulaRegular,
                  fontSize: 12,
                  fontWeight: FontWeight.w400),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Divider(
            endIndent: 0,
            indent: 0,
            height: 1,
            color: Colors.black.withOpacity(0.1),
          ),
          const SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: () async {
              navPop(context);
              String reportId = const Uuid().v4();
              ReportUserModel report = ReportUserModel(
                  reportId: reportId,
                  reportedUser: otherUser.otherUser!.name,
                  reportMessage: 'It\'s posting inappropriate content',
                  reportedBy: currentUser!.name);
              Provider.of<SettingsProvider>(context, listen: false)
                  .reportUser(report, context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15)
                  .copyWith(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'It\'s posting inappropriate content',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: khulaRegular,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_outlined,
                    color: blackColor,
                  )
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Divider(
            endIndent: 0,
            indent: 0,
            height: 1,
            color: Colors.black.withOpacity(0.1),
          ),
          const SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: () async {
              navPop(context);
              String reportId = const Uuid().v4();
              ReportUserModel report = ReportUserModel(
                  reportId: reportId,
                  reportedUser: otherUser.otherUser!.name,
                  reportMessage: 'It\'s pretending to be someone else',
                  reportedBy: currentUser!.name);
              Provider.of<SettingsProvider>(context, listen: false)
                  .reportUser(report, context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15)
                  .copyWith(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'It\'s pretending to be someone else',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: khulaRegular,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_outlined,
                    color: blackColor,
                  )
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Divider(
            endIndent: 0,
            indent: 0,
            height: 1,
            color: Colors.black.withOpacity(0.1),
          ),
          const SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: () async {
              navPop(context);
              String reportId = const Uuid().v4();
              ReportUserModel report = ReportUserModel(
                  reportId: reportId,
                  reportedUser: otherUser.otherUser!.name,
                  reportMessage: 'It may be under the age of 13',
                  reportedBy: currentUser!.name);
              Provider.of<SettingsProvider>(context, listen: false)
                  .reportUser(report, context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15)
                  .copyWith(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'It may be under the age of 13',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: khulaRegular,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_outlined,
                    color: blackColor,
                  )
                ],
              ),
            ),
          ),
          // Divider(
          //   endIndent: 0,
          //   indent: 0,
          //   height: 1,
          //   color: Colors.black
          //       .withOpacity(0.1),
          // ),
        ],
      );
    });
  }
}
