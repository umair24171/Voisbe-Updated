import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/navigation.dart';
import 'package:social_notes/screens/settings_screen/view/widgets/subscription_list_tile.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
            size: 25,
          ),
        ),
        centerTitle: true,
        title: Text(
          'Help',
          style: TextStyle(
              color: blackColor,
              fontSize: 18,
              fontFamily: khulaBold,
              fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: ListTile(
              // contentPadding: EdgeInsets.all(0),
              leading: SvgPicture.asset(
                'assets/icons/Question.svg',
                height: 30,
                width: 30,
              ),
              title: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Reach out to our support team',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: khulaRegular),
                ),
              ),
            ),
          ),
          CustomHelpField(
            size: size,
            hintText: 'Username*',
          ),
          CustomHelpField(
            size: size,
            hintText: 'Email Address*',
          ),
          CustomHelpField(
            size: size,
            hintText: 'Your Message*',
            isMessage: true,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blackColor,
                    elevation: 0,
                    // minimumSize: Size(size.width * 0.9, 50),
                  ),
                  child: Text(
                    'Send Message',
                    style:
                        TextStyle(fontFamily: khulaRegular, color: whiteColor),
                  )),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              'Thank you for your message. We will reply as soon as possible.',
              style: TextStyle(
                  color: const Color(0xff6C6C6C),
                  fontFamily: khulaRegular,
                  fontSize: 12,
                  fontWeight: FontWeight.w400),
            ),
          )
        ],
      ),
    );
  }
}

class CustomHelpField extends StatelessWidget {
  CustomHelpField(
      {super.key,
      required this.size,
      required this.hintText,
      this.isMessage = false});

  final Size size;
  final String hintText;
  bool isMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        maxLines: isMessage ? 20 : null,
        decoration: InputDecoration(
          constraints: BoxConstraints(
              maxWidth: size.width * 0.9,
              maxHeight: isMessage ? size.height * 0.4 : size.height * 0.08),
          hintText: hintText,
          hintStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: blackColor,
              fontFamily: khulaRegular),
          fillColor: whiteColor,
          contentPadding: const EdgeInsets.all(0)
              .copyWith(left: 14, top: isMessage ? 8 : 2, bottom: 2),
          filled: true,
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xffC8C8C8), width: 1),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xffC8C8C8), width: 1),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xffC8C8C8), width: 1),
          ),
        ),
      ),
    );
  }
}
