import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/navigation.dart';
import 'package:social_notes/screens/add_note_screen/model/note_model.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/home_screen/controller/report_services.dart';
import 'package:social_notes/screens/home_screen/model/report_post_model.dart';
import 'package:social_notes/screens/user_profile/view/widgets/confirm_report.dart';
import 'package:uuid/uuid.dart';

class ReportModalSheet extends StatelessWidget {
  const ReportModalSheet({super.key, required this.note});
  final NoteModel note;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var provider = Provider.of<UserProvider>(context, listen: false).user;
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
                String reportId = const Uuid().v4();
                ReportPostModel report = ReportPostModel(
                    reportId: reportId,
                    postId: note.noteId,
                    postOwner: note.userUid,
                    reportMessage: 'It’s spam',
                    reportedBy: provider!.uid);
                ReportServices().reportPost(report);
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
                navPop(context);
                String reportId = const Uuid().v4();
                ReportPostModel report = ReportPostModel(
                    reportId: reportId,
                    postId: note.noteId,
                    postOwner: note.userUid,
                    reportMessage: 'Sexual activity',
                    reportedBy: provider!.uid);
                ReportServices().reportPost(report);
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
                navPop(context);
                String reportId = const Uuid().v4();
                ReportPostModel report = ReportPostModel(
                    reportId: reportId,
                    postId: note.noteId,
                    postOwner: note.userUid,
                    reportMessage: 'Hate speech',
                    reportedBy: provider!.uid);
                ReportServices().reportPost(report);
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
                navPop(context);
                String reportId = const Uuid().v4();
                ReportPostModel report = ReportPostModel(
                    reportId: reportId,
                    postId: note.noteId,
                    postOwner: note.userUid,
                    reportMessage: 'Violence or dangerous organizations',
                    reportedBy: provider!.uid);
                ReportServices().reportPost(report);
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
                navPop(context);
                String reportId = const Uuid().v4();
                ReportPostModel report = ReportPostModel(
                    reportId: reportId,
                    postId: note.noteId,
                    postOwner: note.userUid,
                    reportMessage: 'Bullying or harassment',
                    reportedBy: provider!.uid);
                ReportServices().reportPost(report);
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
                navPop(context);
                String reportId = const Uuid().v4();
                ReportPostModel report = ReportPostModel(
                    reportId: reportId,
                    postId: note.noteId,
                    postOwner: note.userUid,
                    reportMessage: 'False information',
                    reportedBy: provider!.uid);
                ReportServices().reportPost(report);
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
                navPop(context);
                String reportId = const Uuid().v4();
                ReportPostModel report = ReportPostModel(
                    reportId: reportId,
                    postId: note.noteId,
                    postOwner: note.userUid,
                    reportMessage: 'Scam or fraud',
                    reportedBy: provider!.uid);
                ReportServices().reportPost(report);
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
                navPop(context);
                String reportId = const Uuid().v4();
                ReportPostModel report = ReportPostModel(
                    reportId: reportId,
                    postId: note.noteId,
                    postOwner: note.userUid,
                    reportMessage: 'Suicide or self-injury',
                    reportedBy: provider!.uid);
                ReportServices().reportPost(report);
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
                navPop(context);
                String reportId = const Uuid().v4();
                ReportPostModel report = ReportPostModel(
                    reportId: reportId,
                    postId: note.noteId,
                    postOwner: note.userUid,
                    reportMessage: 'Sale of illegal or regulated good',
                    reportedBy: provider!.uid);
                ReportServices().reportPost(report);
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
                navPop(context);
                String reportId = const Uuid().v4();
                ReportPostModel report = ReportPostModel(
                    reportId: reportId,
                    postId: note.noteId,
                    postOwner: note.userUid,
                    reportMessage: 'Eating disorders',
                    reportedBy: provider!.uid);
                ReportServices().reportPost(report);
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
                navPop(context);
                String reportId = const Uuid().v4();
                ReportPostModel report = ReportPostModel(
                    reportId: reportId,
                    postId: note.noteId,
                    postOwner: note.userUid,
                    reportMessage: 'Report as unlawful',
                    reportedBy: provider!.uid);
                ReportServices().reportPost(report);
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
                navPop(context);
                String reportId = const Uuid().v4();
                ReportPostModel report = ReportPostModel(
                    reportId: reportId,
                    postId: note.noteId,
                    postOwner: note.userUid,
                    reportMessage: 'Drugs',
                    reportedBy: provider!.uid);
                ReportServices().reportPost(report);
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
                navPop(context);
                String reportId = const Uuid().v4();
                ReportPostModel report = ReportPostModel(
                    reportId: reportId,
                    postId: note.noteId,
                    postOwner: note.userUid,
                    reportMessage: 'Something else',
                    reportedBy: provider!.uid);
                ReportServices().reportPost(report);
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
