import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/settings_screen/controllers/settings_provider.dart';
import 'package:social_notes/screens/user_profile/other_user_profile.dart';

class SubsccriptionListTile extends StatelessWidget {
  const SubsccriptionListTile(
      {super.key,
      required this.image,
      required this.username,
      required this.userId,
      required this.currentUserId,
      required this.isVerified,
      required this.price,
      required this.subscritpionStatus});
  final String image;
  final String username;
  final String subscritpionStatus;
  final String userId;
  final String currentUserId;
  final bool isVerified;
  final double price;

  // getting the required data to show the subscription

  @override
  Widget build(BuildContext context) {
    return ListTile(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtherUserProfile(userId: userId),
              ));
        },

        //  getting the user image

        leading: CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(
            image,
          ),
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4),

              //  title or username of the user

              child: Text(
                username,
                style: TextStyle(
                    color: blackColor,
                    fontSize: 18,
                    fontFamily: khulaRegular,
                    fontWeight: FontWeight.w600),
              ),
            ),
            if (isVerified) verifiedIcon()
            // Image.network(
            //   'https://media.istockphoto.com/id/1396933001/vector/vector-blue-verified-badge.jpg?s=612x612&w=0&k=20&c=aBJ2JAzbOfQpv2OCSr0k8kYe0XHutOGBAJuVjvWvPrQ=',
            //   height: 20,
            //   width: 20,
            // )
          ],
        ),

        //  getting the subscription price of the user

        subtitle: Text(
          '${price.toStringAsFixed(2)} USD per month',
          style: TextStyle(
              color: Color(0xff909090),
              fontSize: 14,
              fontFamily: khulaRegular,
              fontWeight: FontWeight.w400),
        ),

        //  removing subscription button

        trailing: InkWell(
          onTap: () {
            Provider.of<SettingsProvider>(context, listen: false)
                .removeSubscription(userId, currentUserId, context);
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

            //  text to show the subscription status of the user

            child:
                Consumer<SettingsProvider>(builder: (context, settingPro, _) {
              return Text(subscritpionStatus,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: blackColor,
                      fontSize: 18,
                      fontFamily: khulaRegular,
                      fontWeight: FontWeight.w600));
            }),
          ),
        )
        //  ElevatedButton(
        //   style:
        //    ButtonStyle(
        //     minimumSize: const MaterialStatePropertyAll(Size(33, 33)),
        //     alignment: Alignment.center,
        //     elevation: const MaterialStatePropertyAll(0),
        //     backgroundColor: MaterialStatePropertyAll.all(whiteColor),
        //     side: const MaterialStatePropertyAll(
        //       BorderSide(color: Color(0xff868686), width: 1),
        //     ),
        //   ),
        //   onPressed: () {},
        //   child:
        // Text('Cancel',
        //       textAlign: TextAlign.center,
        //       style: TextStyle(
        //           color: blackColor,
        //           fontSize: 18,
        //           fontFamily: khulaRegular,
        //           fontWeight: FontWeight.w600)),
        // ),
        );
  }
}
