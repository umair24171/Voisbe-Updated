import 'package:flutter/material.dart';
import 'package:social_notes/resources/colors.dart';

class ConfirmReport extends StatelessWidget {
  const ConfirmReport({super.key});

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
          padding: const EdgeInsets.only(top: 30, left: 15, right: 15),
          child: Text(
            'Thank you for bringing this to our attention. We will look into this as soon as possible and resolve any issues with this user. ',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: khulaRegular,
                color: const Color(0xff000000),
                fontSize: 18,
                fontWeight: FontWeight.w400),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
