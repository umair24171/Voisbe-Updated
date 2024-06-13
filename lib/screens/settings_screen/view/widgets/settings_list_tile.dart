import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social_notes/resources/colors.dart';

class CustomListTile extends StatelessWidget {
  const CustomListTile({
    super.key,
    required this.icon,
    required this.title,
  });

  final String icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SvgPicture.asset(
        icon,
        height: 30,
        width: 30,
      ),
      title: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Text(title,
            style: TextStyle(
                color: blackColor,
                fontSize: 16,
                fontFamily: khulaRegular,
                fontWeight: FontWeight.w600)),
      ),
      trailing: SvgPicture.asset(
        'assets/icons/Expand_down.svg',
        height: 40,
        width: 30,
      ),
    );
  }
}
