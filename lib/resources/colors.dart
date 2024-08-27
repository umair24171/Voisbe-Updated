import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

Color primaryColor = const Color(0xffed6a5a);
LinearGradient gradientColor = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xffee856d),
      Color(0xffed6a5a),
    ]);
Color greenColor = const Color(0xff50a87e);
Color blueColor = const Color(0xff6cbfd9);
Color purpleLightColor = const Color(0xffa562cb);
Color whiteColor = Colors.white;
Color blackColor = Colors.black;
String fontFamily = 'Hell';
String fontFamily2 = 'Steel';
String fontFamilyMedium = 'Hell-medium';
String fontFamilyBold = 'Hell-bold';
String khulaRegular = 'Khula-Regular';
String khulaBold = 'Khula-Bold';
Color color1 = const Color(0xff503e3b);
Color color2 = const Color(0xffcd3826);
Color color3 = const Color(0xffcf4736);
Color color4 = const Color(0xffe6b619);
Color color5 = const Color(0xff8ab756);
Color color6 = const Color(0xffeb6447);
Color color7 = const Color(0xff3694de);
Color color8 = const Color(0xffe69319);
Color color9 = const Color(0xff7c69de);
Color color10 = const Color(0xff885341);
Color color11 = const Color(0xff9235a2);
Color color12 = const Color(0xff56a559);
Color color13 = const Color(0xffd53269);
Color color14 = const Color(0xff6a46ab);
Color color15 = const Color(0xffe154a1);
Color color16 = const Color(0xff15acbf);
Color color17 = const Color(0xff45897a);
Color color18 = const Color(0xff472861);
Color color19 = const Color(0xff37728c);
Color color20 = const Color(0xff6cb57f);
String verifiedPath = 'assets/icons/verified (1).svg';

Widget verifiedIcon() {
  return Padding(
    padding: const EdgeInsets.only(left: 4),
    child: SvgPicture.asset(
      verifiedPath,
      fit: BoxFit.cover,
      // color: Colors.blue,
      height: 16,
      width: 16,
    ),
  );
}
