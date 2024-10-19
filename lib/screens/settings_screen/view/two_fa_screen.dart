import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/navigation.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';

class TwoFaScreen extends StatefulWidget {
  const TwoFaScreen({super.key});

  @override
  State<TwoFaScreen> createState() => _TwoFaScreenState();
}

class _TwoFaScreenState extends State<TwoFaScreen> {
  bool isTwoFa = false;
  @override
  Widget build(BuildContext context) {
    var userPro = Provider.of<UserProvider>(context, listen: false).user;
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0,
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
          'Two-Factor Authentication',
          style: TextStyle(
              color: blackColor,
              fontSize: 18,
              fontFamily: khulaBold,
              fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Enable Two-Factor Authentication',
                style: TextStyle(
                    color: blackColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),

              //  getting the value of the 2fa from the users data from firebase and updating it

              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(userPro!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      UserModel user =
                          UserModel.fromMap(snapshot.data!.data()!);
                      return Switch(
                        thumbColor: MaterialStatePropertyAll(whiteColor),
                        value: user.isTwoFa,
                        onChanged: (value) async {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .update({'isTwoFa': value});
                        },
                        activeTrackColor: blackColor,
                        activeColor: const Color(0xffFFA451),
                      );
                    } else {
                      return Text('');
                    }
                  })
            ],
          )
        ],
      ),
    );
  }
}
