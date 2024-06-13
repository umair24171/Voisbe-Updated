import 'package:flutter/material.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/navigation.dart';
import 'package:social_notes/screens/user_profile/view/widgets/confirm_report.dart';

class ReportUser extends StatelessWidget {
  const ReportUser({super.key});

  @override
  Widget build(BuildContext context) {
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
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return const ConfirmReport();
              },
            );
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
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return const ConfirmReport();
              },
            );
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
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return const ConfirmReport();
              },
            );
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
  }
}
