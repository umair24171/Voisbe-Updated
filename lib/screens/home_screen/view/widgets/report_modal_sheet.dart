import 'package:flutter/material.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/navigation.dart';
import 'package:social_notes/screens/home_screen/view/widgets/confirm_report_post.dart';
import 'package:social_notes/screens/user_profile/view/widgets/confirm_report.dart';

class ReportModalSheet extends StatelessWidget {
  const ReportModalSheet({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.95,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              'Report',
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
                'Why are you reporting this post?',
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
                'Your report is anonymous, except if you\'re reporting an intellectual property infringement. If someone is in immediate danger, call the local emergency services - don\'t wait.',
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
              height: 5,
            ),
            InkWell(
              onTap: () async {
                navPop(context);
                showModalBottomSheet(
                  backgroundColor: whiteColor,
                  elevation: 0,
                  context: context,
                  builder: (context) {
                    return const ConfirmReport();
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 15)
                    .copyWith(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'It’s spam',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: khulaRegular,
                          fontSize: 16,
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
              height: 5,
            ),
            Divider(
              endIndent: 0,
              indent: 0,
              height: 1,
              color: Colors.black.withOpacity(0.1),
            ),
            const SizedBox(
              height: 5,
            ),
            InkWell(
              onTap: () async {
                showModalBottomSheet(
                  backgroundColor: whiteColor,
                  elevation: 0,
                  // enableDrag: true,
                  // useSafeArea: true,
                  // isScrollControlled: true,
                  // constraints: BoxConstraints(),

                  context: context,
                  builder: (context) {
                    return const ConfirmReportPost();
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 15)
                    .copyWith(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sexual activity',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: khulaRegular,
                          fontSize: 16,
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
              height: 5,
            ),
            Divider(
              endIndent: 0,
              indent: 0,
              height: 1,
              color: Colors.black.withOpacity(0.1),
            ),
            const SizedBox(
              height: 5,
            ),
            InkWell(
              onTap: () async {
                showModalBottomSheet(
                  backgroundColor: whiteColor,
                  elevation: 0,
                  context: context,
                  builder: (context) {
                    return const ConfirmReport();
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 15)
                    .copyWith(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hate speech',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: khulaRegular,
                          fontSize: 16,
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
            Divider(
              endIndent: 0,
              indent: 0,
              height: 1,
              color: Colors.black.withOpacity(0.1),
            ),
            const SizedBox(
              height: 5,
            ),
            InkWell(
              onTap: () async {
                showModalBottomSheet(
                  backgroundColor: whiteColor,
                  elevation: 0,
                  context: context,
                  builder: (context) {
                    return const ConfirmReport();
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 15)
                    .copyWith(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Violence or dangerous organizations',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: khulaRegular,
                          fontSize: 16,
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
            Divider(
              endIndent: 0,
              indent: 0,
              height: 1,
              color: Colors.black.withOpacity(0.1),
            ),
            const SizedBox(
              height: 5,
            ),
            InkWell(
              onTap: () async {
                showModalBottomSheet(
                  backgroundColor: whiteColor,
                  elevation: 0,
                  context: context,
                  builder: (context) {
                    return const ConfirmReport();
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 15)
                    .copyWith(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bullying or harassment',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: khulaRegular,
                          fontSize: 16,
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
            Divider(
              endIndent: 0,
              indent: 0,
              height: 1,
              color: Colors.black.withOpacity(0.1),
            ),
            const SizedBox(
              height: 5,
            ),
            InkWell(
              onTap: () async {
                showModalBottomSheet(
                  backgroundColor: whiteColor,
                  elevation: 0,
                  context: context,
                  builder: (context) {
                    return const ConfirmReport();
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 15)
                    .copyWith(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'False information',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: khulaRegular,
                          fontSize: 16,
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
            Divider(
              endIndent: 0,
              indent: 0,
              height: 1,
              color: Colors.black.withOpacity(0.1),
            ),
            const SizedBox(
              height: 5,
            ),
            InkWell(
              onTap: () async {
                showModalBottomSheet(
                  backgroundColor: whiteColor,
                  elevation: 0,
                  context: context,
                  builder: (context) {
                    return const ConfirmReport();
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 15)
                    .copyWith(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Scam or fraud',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: khulaRegular,
                          fontSize: 16,
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
            Divider(
              endIndent: 0,
              indent: 0,
              height: 1,
              color: Colors.black.withOpacity(0.1),
            ),
            const SizedBox(
              height: 5,
            ),
            InkWell(
              onTap: () async {
                showModalBottomSheet(
                  backgroundColor: whiteColor,
                  elevation: 0,
                  context: context,
                  builder: (context) {
                    return const ConfirmReport();
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 15)
                    .copyWith(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Suicide or self-injury',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: khulaRegular,
                          fontSize: 16,
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
            Divider(
              endIndent: 0,
              indent: 0,
              height: 1,
              color: Colors.black.withOpacity(0.1),
            ),
            const SizedBox(
              height: 5,
            ),
            InkWell(
              onTap: () async {
                showModalBottomSheet(
                  backgroundColor: whiteColor,
                  elevation: 0,
                  context: context,
                  builder: (context) {
                    return const ConfirmReport();
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 15)
                    .copyWith(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sale of illegal or regulated good',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: khulaRegular,
                          fontSize: 16,
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
            Divider(
              endIndent: 0,
              indent: 0,
              height: 1,
              color: Colors.black.withOpacity(0.1),
            ),
            const SizedBox(
              height: 5,
            ),
            InkWell(
              onTap: () async {
                showModalBottomSheet(
                  backgroundColor: whiteColor,
                  elevation: 0,
                  context: context,
                  builder: (context) {
                    return const ConfirmReport();
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 15)
                    .copyWith(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Eating disorders',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: khulaRegular,
                          fontSize: 16,
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
            Divider(
              endIndent: 0,
              indent: 0,
              height: 1,
              color: Colors.black.withOpacity(0.1),
            ),
            const SizedBox(
              height: 5,
            ),
            InkWell(
              onTap: () async {
                showModalBottomSheet(
                  backgroundColor: whiteColor,
                  elevation: 0,
                  context: context,
                  builder: (context) {
                    return const ConfirmReport();
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 15)
                    .copyWith(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Report as unlawful',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: khulaRegular,
                          fontSize: 16,
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
            Divider(
              endIndent: 0,
              indent: 0,
              height: 1,
              color: Colors.black.withOpacity(0.1),
            ),
            const SizedBox(
              height: 5,
            ),
            InkWell(
              onTap: () async {
                showModalBottomSheet(
                  backgroundColor: whiteColor,
                  elevation: 0,
                  context: context,
                  builder: (context) {
                    return const ConfirmReport();
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 15)
                    .copyWith(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Drugs',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: khulaRegular,
                          fontSize: 16,
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
            Divider(
              endIndent: 0,
              indent: 0,
              height: 1,
              color: Colors.black.withOpacity(0.1),
            ),
            const SizedBox(
              height: 5,
            ),
            InkWell(
              onTap: () async {
                showModalBottomSheet(
                  elevation: 0,
                  backgroundColor: whiteColor,
                  context: context,
                  builder: (context) {
                    return const ConfirmReport();
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 15)
                    .copyWith(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Something else',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: khulaRegular,
                          fontSize: 16,
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
            //   color: Colors.black.withOpacity(0.1),
            // ),
            // const SizedBox(
            //   height: 20,
            // ),
            // Divider(
            //   endIndent: 0,
            //   indent: 0,
            //   height: 1,
            //   color: Colors.black
            //       .withOpacity(0.1),
            // ),
          ],
        ),
      ),
    );
  }
}
