import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:url_launcher/url_launcher.dart';

showWhiteOverlayPopup(context, IconData? icon, String? svgPath, String? image,
    {required String title,
    required String message,
    required bool isUsernameRes}) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        elevation: 0,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (svgPath != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: SvgPicture.asset(svgPath),
              ),
            if (icon != null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Icon(icon, color: Colors.black, size: 50),
              ),
            image != null
                ? Image.asset(image, height: 50, width: 50)
                : Container(),
            Text(title,
                style: TextStyle(
                    color: Colors.black, fontSize: 20, fontFamily: fontFamily)),
            const SizedBox(height: 10),
            const Divider(
              color: Color(0xffEAEAEA),
              thickness: 1,
              height: 1,
              endIndent: 0,
              indent: 0,
            ),
            const SizedBox(
              height: 5,
            ),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black, fontSize: 16, fontFamily: fontFamily)),
            const SizedBox(height: 10),
            if (isUsernameRes)
              ElevatedButton(
                onPressed: () async {
                  final Uri emailLaunchUri = Uri(
                    scheme: 'mailto',
                    path: 'support@voisbe.com',
                    queryParameters: {
                      'subject': 'Contact VOISBE',
                      'body': 'Hi VOISBE, I need help with my account.',
                    },
                  );
                  if (await launchUrl(emailLaunchUri)) {
                  } else {
                    throw 'Could not launch $emailLaunchUri';
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: blackColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: Text('Contact VOISBE',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: fontFamily)),
              ),
            const SizedBox(height: 10),
          ],
        ),
      );
    },
  );
}
