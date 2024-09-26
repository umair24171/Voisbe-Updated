import 'dart:developer';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
// import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/main.dart';
// import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/navigation.dart';
import 'package:social_notes/resources/white_overlay_popup.dart';
// import 'package:social_notes/resources/show_snack.dart';
import 'package:social_notes/screens/add_note_screen/controllers/add_note_controller.dart';
import 'package:social_notes/screens/auth_screens/controller/notifications_methods.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/custom_bottom_bar.dart';
import 'package:social_notes/screens/home_screen/provider/display_notes_provider.dart';
import 'package:social_notes/screens/profile_screen/controller/update_profile_controller.dart';
import 'package:social_notes/screens/profile_screen/provider.dart/update_profile_provider.dart';
import 'package:social_notes/screens/profile_screen/widgets/bank_details_popup.dart';
// import 'package:social_notes/screens/home_screen/view/home_screen.dart';
import 'package:social_notes/screens/profile_screen/widgets/custom_list_tile.dart';
import 'package:social_notes/screens/profile_screen/widgets/usernames_list.dart';
import 'package:social_notes/screens/stripe_controller.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key, this.isMainPro = false});
  static const routeName = '/profile';
  bool isMainPro;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  //  suggestions varibale to mention someone in bio

  List<String> _suggestions = [];
  String name = '';
  String username = '';
  String bio = '';
  String link = '';
  String contact = '';
  String pass = '';
  String price = '';
  String soundPack = 'Upload your sound pack';
  bool subscription = false;
  DateTime? dateOfBirth;

  //  function to get the user date of birth

  showDatPicker(UserModel user) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      barrierColor: Colors.transparent,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            // textButtonTheme: TextButtonThemeData(
            //   style: TextButton.styleFrom(
            //     backgroundColor: primaryColor, // Button text color
            //   ),
            // ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null &&
        (DateTime.now().difference(picked ?? user!.dateOfBirth).inDays / 365)
                .floor() <
            12) {
      showWhiteOverlayPopup(context, null, 'assets/icons/Info (1).svg', null,
          title: 'Enter valid date of birth',
          message: 'You must be at least 12+ years old to use VOISBE.',
          isUsernameRes: false);
    }

    if (picked != null && picked != dateOfBirth) {
      setState(() {
        dateOfBirth = picked;
      });
    }
  }

  //  list of reserverd names

  // List<String> reservedNames = [

  // ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      //  function to get all the names of the users that exist in the database before the screen loads

      Provider.of<UpdateProfileProvider>(context, listen: false)
          .getAllUserNames();
    });
  }

  //  dialog to show to enter bank details when the user toggles on the subscritpion

  void showCustomDialog(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: BankDetails(
                      changeSub: () async {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .update({'isSubscriptionEnable': true});
                      },
                      user: user,
                      stripeFunction: () {},
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  //  controller to get the data which user enter in the bio field

  final TextEditingController _bioController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  //  varibles to show error if the certain conditions met

  String? userNameError;
  String? linkError;
  String? contactError;
  String? priceError;
  String? passError;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    //getting the user data when the screen builds

    Provider.of<UserProvider>(context, listen: false).getUserData();

    //  listening the user provider when there is anychange in the data occurs

    var userProvider = Provider.of<UserProvider>(
      context,
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        surfaceTintColor: whiteColor,
        backgroundColor: whiteColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.isMainPro)
              InkWell(
                onTap: () {
                  navPop(context);
                },
                child: const Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                ),
              ),
            if (!widget.isMainPro) const SizedBox(),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Edit Profile',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: fontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
            const SizedBox()
          ],
        ),
        centerTitle: true,
      ),
      body:

          //  while the data is loading show the loader

          userProvider.user == null
              ? SpinKitThreeBounce(
                  color: whiteColor,
                  size: 20,
                )

              //  body starts

              : SizedBox(
                  height: size.height,
                  child: Stack(
                    children: [
                      if (userProvider.user!.photoUrl.isNotEmpty ||
                          userProvider.userImage != null)

                        //  background of the screen if the profile pic is selected or empty
                        Container(
                          height: size.height,
                          decoration: BoxDecoration(
                            image: userProvider.userImage == null
                                ? DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                      userProvider.user!.photoUrl.isNotEmpty
                                          ? userProvider.user!.photoUrl
                                          : 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8cHJvZmlsZXxlbnwwfHwwfHx8MA%3D%3D',
                                    ),
                                  )
                                : DecorationImage(
                                    image: FileImage(userProvider.userImage!),
                                    fit: BoxFit.cover),
                          ),
                        ),
                      if (userProvider.user!.photoUrl.isEmpty &&
                          userProvider.userImage == null)

                        //  default background of the screen if the profile pic is empty

                        Container(
                          height: MediaQuery.of(context).size.height,
                          decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                  stops: [
                                    0.25,
                                    0.75,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xffee856d),
                                    Color(0xffed6a5a)
                                  ])),
                        ),

                      // above the image show the blur filter

                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Container(
                          height: size.height,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Color(0xffED695A)],
                            ),
                          ),
                        ),
                      ),

                      //  content of the body

                      CustomScrollView(slivers: [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (userProvider.user!.photoUrl.isNotEmpty ||
                                  userProvider.userImage != null)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Stack(
                                      children: [
                                        //  showing the image if user already added or changing it and managing through provider

                                        Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: whiteColor, width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(50)),
                                          child: userProvider.userImage == null
                                              ? CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                      userProvider
                                                              .user!
                                                              .photoUrl
                                                              .isNotEmpty
                                                          ? userProvider
                                                              .user!.photoUrl
                                                          : 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8cHJvZmlsZXxlbnwwfHwwfHx8MA%3D%3D'),
                                                  radius: 50,
                                                )
                                              : CircleAvatar(
                                                  backgroundImage: FileImage(
                                                      userProvider.userImage!),
                                                  radius: 50,
                                                ),
                                        ),

                                        //  calling the pick image function to change the profile pic

                                        Positioned(
                                          left: 70,
                                          bottom: 5,
                                          child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: primaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                              ),
                                              child: GestureDetector(
                                                onTap: () {
                                                  userProvider.pickUserImage();
                                                },
                                                child: const Icon(
                                                  Icons.edit_outlined,
                                                  color: Colors.white,
                                                  size: 15,
                                                ),
                                              )),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              if (userProvider.user!.photoUrl.isEmpty &&
                                  userProvider.userImage == null)
                                InkWell(
                                  splashColor: Colors.transparent,
                                  onTap: () {
                                    //  calling the pick image function to change the profile pic

                                    userProvider.pickUserImage();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15),
                                    child: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: whiteColor, width: 1),
                                            borderRadius:
                                                BorderRadius.circular(50)),
                                        child: CircleAvatar(
                                          backgroundColor: primaryColor,
                                          radius: 50,
                                          child: SvgPicture.asset(
                                            'assets/icons/Add profile picture.svg',
                                            // color: primar,
                                            height: 64,
                                            width: 64,
                                          ),
                                        )),
                                  ),
                                ),
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    //  custom list tile is the global widget or design of the field or you can say template

                                    //  first the name of user field if its exist in the database show that or user will add

                                    CustomListTile(
                                      textCapitalization:
                                          TextCapitalization.words,
                                      username: name.isEmpty
                                          ? userProvider.user!.username
                                          : name,
                                      name: 'Name',
                                      subtitile: name.isEmpty
                                          ? userProvider.user!.username
                                          : name,
                                      isLink: false,
                                      inputText: '',
                                      onChanged: (value) {
                                        setState(() {
                                          name = value;
                                        });
                                      },
                                    ),

                                    //  first the username of user field if its exist in the database show that or user will add

                                    Consumer<UpdateProfileProvider>(
                                        builder: (context, allUserPro, _) {
                                      // _bioController.text=
                                      return CustomListTile(
                                        isUserName: true,
                                        userNameError: userNameError,
                                        username: name.isEmpty
                                            ? userProvider.user!.username
                                            : name,
                                        name: 'Username',
                                        isBio: false,
                                        subtitile: username.isEmpty
                                            ? userProvider.user!.name
                                            : username,
                                        isLink: false,
                                        inputText: '',
                                        onChanged: (value) {
                                          // conditions to display errors if certain conditions met in entering username

                                          if (reservedNames.contains(value)) {
                                            if (value.isNotEmpty) {
                                              showWhiteOverlayPopup(
                                                  context,
                                                  null,
                                                  'assets/icons/Info (1).svg',
                                                  null,
                                                  title: 'Username reserved',
                                                  isUsernameRes: true,
                                                  message:
                                                      'The requested username has been reserved. If you are the rightful owner of the verified username on a different platform, kindly contact us via the email below.');
                                              setState(() {
                                                userNameError =
                                                    'Username reserved.';
                                              });
                                            } else {
                                              setState(() {
                                                userNameError =
                                                    'Username should not be empty.';
                                              });
                                            }
                                          } else if (allUserPro.userNames
                                              .contains(value)) {
                                            if (value.isNotEmpty) {
                                              showWhiteOverlayPopup(
                                                  context,
                                                  null,
                                                  'assets/icons/Info (1).svg',
                                                  null,
                                                  title: 'Username taken',
                                                  isUsernameRes: false,
                                                  message:
                                                      'The chosen username is unavailable. Please select a different username.');
                                              setState(() {
                                                userNameError =
                                                    'Username taken';
                                              });
                                            } else {
                                              setState(() {
                                                userNameError =
                                                    'Username should not be empty.';
                                              });
                                            }
                                          } else {
                                            setState(() {
                                              userNameError = null;
                                              username = value;
                                            });
                                          }
                                        },
                                      );
                                    }),

                                    // biod field with the mention user feature

                                    Consumer<UpdateProfileProvider>(
                                        builder: (context, profilePro, _) {
                                      if (_bioController.text.isEmpty) {
                                        _bioController.text =
                                            userProvider.user!.bio;
                                      }

                                      return Column(
                                        children: [
                                          CustomListTile(
                                            // validate: _validate,
                                            bioController: _bioController,
                                            username: name.isEmpty
                                                ? userProvider.user!.username
                                                : name,
                                            isLink: false,
                                            name: 'Biography',
                                            isBio: true,
                                            subtitile:
                                                _bioController.text.isNotEmpty
                                                    ? _bioController.text
                                                    : userProvider.user!.bio,
                                            inputText: '',
                                            onChanged: (value) {
                                              String text = value;
                                              if (text.contains('@')) {
                                                String query =
                                                    text.split('@').last;
                                                if (query.isNotEmpty) {
                                                  List<String> users =
                                                      profilePro.userNames;
                                                  setState(() {
                                                    _suggestions = users
                                                        .where((user) => user
                                                            .toLowerCase()
                                                            .contains(query
                                                                .toLowerCase()))
                                                        .toList();
                                                  });
                                                } else {
                                                  setState(() {
                                                    _suggestions = [];
                                                  });
                                                }
                                              } else {
                                                setState(() {
                                                  _suggestions = [];
                                                });
                                              }
                                            },
                                          ),
                                          ..._suggestions.map((user) =>
                                              ListTile(
                                                title: Text(
                                                  user,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: whiteColor,
                                                      fontFamily: fontFamily),
                                                ),
                                                onTap: () {
                                                  // Replace @mention with the selected user
                                                  String text =
                                                      _bioController.text;
                                                  String updatedText =
                                                      text.replaceAll(
                                                          RegExp(r'@\w*$'),
                                                          '@$user ');
                                                  _bioController.text =
                                                      updatedText;
                                                  _bioController.selection =
                                                      TextSelection.fromPosition(
                                                          TextPosition(
                                                              offset:
                                                                  updatedText
                                                                      .length));
                                                  setState(() {
                                                    _suggestions = [];
                                                  });
                                                },
                                              )),
                                        ],
                                      );
                                    }),

                                    //  user date of birth selection field

                                    Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 4,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                    left: 20,
                                                    top: dateOfBirth != null &&
                                                            (DateTime.now()
                                                                            .difference(dateOfBirth ??
                                                                                userProvider.user!.dateOfBirth)
                                                                            .inDays /
                                                                        365)
                                                                    .floor() <
                                                                12
                                                        ? 20
                                                        : 0,
                                                  ),
                                                  child: Text(
                                                    'Date of birth',
                                                    style: TextStyle(
                                                      // height: 1,
                                                      fontFamily: fontFamily,
                                                      color: whiteColor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 9,
                                                child: Stack(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          // vertical: ,
                                                          horizontal: 4),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          if (dateOfBirth !=
                                                                  null &&
                                                              (DateTime.now()
                                                                              .difference(dateOfBirth ?? userProvider.user!.dateOfBirth)
                                                                              .inDays /
                                                                          365)
                                                                      .floor() <
                                                                  12)
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      bottom:
                                                                          8),
                                                              child: Text(
                                                                'Must be over 12 years.',
                                                                style: TextStyle(
                                                                    height: 0,
                                                                    color:
                                                                        greenColor,
                                                                    fontSize:
                                                                        12,
                                                                    fontFamily:
                                                                        fontFamily),
                                                              ),
                                                            ),
                                                          Container(
                                                            height: 34,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.59,
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    right: 30,
                                                                    left: 13,
                                                                    bottom: 8,
                                                                    top: 8),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: blackColor,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                            ),
                                                            child: Text(
                                                              dateOfBirth ==
                                                                          null &&
                                                                      (DateTime.now().difference(userProvider.user!.dateOfBirth).inDays / 365)
                                                                              .floor() <
                                                                          12
                                                                  ? ''
                                                                  : DateFormat
                                                                          .yMMMd()
                                                                      .format(dateOfBirth ??
                                                                          userProvider
                                                                              .user!
                                                                              .dateOfBirth),
                                                              // textAlign:
                                                              //     TextAlign.center,
                                                              style: TextStyle(
                                                                  color:
                                                                      whiteColor,
                                                                  fontSize: 14,
                                                                  fontFamily:
                                                                      fontFamily),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Positioned(
                                                      left: size.width * 0.52,
                                                      bottom: 1,
                                                      child: Container(
                                                        // height: 20,
                                                        // width: 20,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(9),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: primaryColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(18),
                                                        ),
                                                        child: InkWell(
                                                          onTap: () {
                                                            //  show date picker popup

                                                            showDatPicker(
                                                                userProvider
                                                                    .user!);
                                                          },
                                                          child: const Icon(
                                                            Icons.edit_outlined,
                                                            color: Colors.white,
                                                            size: 15,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Divider(
                                          endIndent: 10,
                                          indent: 10,
                                          height: 1,
                                          color: Colors.white.withOpacity(0.2),
                                        )
                                      ],
                                    ),

                                    // field to enter link
                                    //  with the checks if certain conditions met then add the link

                                    CustomListTile(
                                      username: name.isEmpty
                                          ? userProvider.user!.username
                                          : name,
                                      name: 'Link',
                                      linkError: linkError,
                                      subtitile: link.isNotEmpty
                                          ? link
                                          : userProvider.user!.link,
                                      isLink: true,
                                      inputText: '',
                                      onChanged: (value) {
                                        if (value.isNotEmpty) {
                                          if ((!value.startsWith('www')) ||
                                              !value.contains('.')) {
                                            setState(() {
                                              linkError =
                                                  'Please add valid link.';
                                            });
                                          } else {
                                            setState(() {
                                              linkError = null;
                                              link = value;
                                            });
                                          }
                                        }
                                      },
                                    ),

                                    //  user contact field with the checks to enter the valid contact email

                                    CustomListTile(
                                      username: name.isEmpty
                                          ? userProvider.user!.username
                                          : name,
                                      name: 'Contact',
                                      contactError: contactError,
                                      subtitile: contact.isNotEmpty
                                          ? contact
                                          : userProvider.user!.contact,
                                      isLink: true,
                                      inputText: '',
                                      onChanged: (value) {
                                        if (value.isNotEmpty) {
                                          if (!value.contains('@') ||
                                              !value.contains('.')) {
                                            setState(() {
                                              contactError =
                                                  'Invalid email address.';
                                            });
                                          } else {
                                            setState(() {
                                              contactError = null;
                                              contact = value;
                                            });
                                          }
                                        }
                                      },
                                    ),

                                    //  user password update field

                                    CustomListTile(
                                      isPassword: true,
                                      username: '',
                                      name: 'Account Password',
                                      passError: passError,
                                      subtitile: pass.isNotEmpty
                                          ? pass
                                          : userProvider.user!.password,
                                      isLink: true,
                                      inputText: '',
                                      onChanged: (value) {
                                        if (value.isNotEmpty) {
                                          if (value.length < 8) {
                                            setState(() {
                                              passError =
                                                  'Password must be above 8 characters.';
                                            });
                                          } else {
                                            setState(() {
                                              passError = null;
                                              pass = value;
                                            });
                                          }
                                        }
                                      },
                                    ),

                                    //  verified users section

                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 25, vertical: 5),
                                        child: Text(
                                          'Verified Users Only',
                                          style: TextStyle(
                                              fontFamily: fontFamily,
                                              color: whiteColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 25),
                                          child: Text(
                                            'Subscription',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: fontFamily,
                                                color: userProvider.user!
                                                        .isSubscriptionEnable
                                                    ? whiteColor
                                                    : Colors.grey),
                                          ),
                                        ),
                                        Consumer<UserProvider>(
                                            builder: (context, sub, child) {
                                          return GestureDetector(
                                            onTap: () async {
                                              //  if the toggle is already ON then show the alert popup

                                              if (userProvider.user!
                                                      .isSubscriptionEnable ==
                                                  true) {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    content: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.error_outline,
                                                          color: blackColor,
                                                          size: 30,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          10)
                                                                  .copyWith(
                                                                      left: 5),
                                                          child: Text(
                                                            'Are you sure?',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    khulaRegular,
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                      bottom:
                                                                          10)
                                                                  .copyWith(
                                                                      left: 5),
                                                          child: Text(
                                                            'When you deactivate the subscription feature you will lose all your subscribers.',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    khulaRegular,
                                                                fontSize: 12,
                                                                color: const Color(
                                                                    0xff6C6C6C),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400),
                                                          ),
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            ElevatedButton(
                                                                style:
                                                                    ButtonStyle(
                                                                  backgroundColor:
                                                                      const WidgetStatePropertyAll(
                                                                          Colors
                                                                              .transparent),
                                                                  elevation:
                                                                      const WidgetStatePropertyAll(
                                                                          0),
                                                                  shape:
                                                                      WidgetStatePropertyAll(
                                                                    RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              18),
                                                                      side: BorderSide(
                                                                          color:
                                                                              blackColor,
                                                                          width:
                                                                              1),
                                                                    ),
                                                                  ),
                                                                ),
                                                                onPressed: () {
                                                                  navPop(
                                                                      context);
                                                                },
                                                                child: Text(
                                                                  'Cancel',
                                                                  style: TextStyle(
                                                                      color:
                                                                          blackColor,
                                                                      fontFamily:
                                                                          fontFamily,
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
                                                                )),

                                                            //  on confirm remove the user subscribers
                                                            // also turn off the toggle

                                                            ElevatedButton(
                                                                style: ButtonStyle(
                                                                    backgroundColor:
                                                                        WidgetStatePropertyAll(
                                                                            blackColor),
                                                                    elevation:
                                                                        const WidgetStatePropertyAll(
                                                                            0)),
                                                                onPressed:
                                                                    () async {
                                                                  navPop(
                                                                      context);
                                                                  await FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'users')
                                                                      .doc(userProvider
                                                                          .user!
                                                                          .uid)
                                                                      .update({
                                                                    'isSubscriptionEnable':
                                                                        false,
                                                                    'subscribedUsers':
                                                                        []
                                                                  });
                                                                },
                                                                child: Text(
                                                                  'Confirm',
                                                                  style: TextStyle(
                                                                      color:
                                                                          whiteColor,
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400),
                                                                ))
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                );

                                                //  else show the popup to enter bank details if the user is verified
                                              } else if (userProvider
                                                      .user!.isVerified &&
                                                  !userProvider.user!
                                                      .isSubscriptionEnable) {
                                                showCustomDialog(
                                                    navigatorKey
                                                        .currentState!.context,
                                                    userProvider.user!);
                                              } else if (!userProvider
                                                  .user!.isVerified) {}
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: Container(
                                                // width: 100,
                                                padding:
                                                    const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 14,
                                                          vertical: 7),
                                                      decoration: BoxDecoration(
                                                          color: userProvider
                                                                  .user!
                                                                  .isSubscriptionEnable
                                                              ? primaryColor
                                                              : const Color(
                                                                  0xff6f6f6f),
                                                          borderRadius:
                                                              const BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          18),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          18))),
                                                      child: Text(
                                                        'ON',
                                                        style: TextStyle(
                                                            color: whiteColor),
                                                      ),
                                                    ),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                          color: userProvider
                                                                  .user!
                                                                  .isSubscriptionEnable
                                                              ? const Color(
                                                                  0xff6f6f6f)
                                                              : const Color(
                                                                  0xffcdcdcd),
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .only(
                                                                  topRight: Radius
                                                                      .circular(
                                                                          18),
                                                                  bottomRight:
                                                                      Radius.circular(
                                                                          18))),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 14,
                                                          vertical: 7),
                                                      child: Text(
                                                        'OFF',
                                                        style: TextStyle(
                                                            color: whiteColor),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        })
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 25, vertical: 5),
                                      child: Text(
                                        'If enabled users will be able to subscribe to you for a monthly payment (starting from USD 4.00) and receive the subscriber special for the time of being subscribed.',
                                        style: TextStyle(
                                            color: userProvider
                                                    .user!.isSubscriptionEnable
                                                ? whiteColor
                                                : Colors.grey,
                                            fontFamily: fontFamily,
                                            fontSize: 12),
                                      ),
                                    ),
                                    Divider(
                                      endIndent: 25,
                                      indent: 25,
                                      height: 1,
                                      color: Colors.white.withOpacity(0.2),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Row(
                                        children: [
                                          //  setting the price if the user is verified and subscription toggle is turned on

                                          Expanded(
                                            flex: 4,
                                            child: Padding(
                                              // ignore: prefer_const_constructors
                                              padding: EdgeInsets.only(
                                                left: 23,
                                              ),
                                              child: Text(
                                                'Price per month',
                                                style: TextStyle(
                                                  // height: 1,
                                                  fontFamily: fontFamily,
                                                  color: userProvider.user!
                                                          .isSubscriptionEnable
                                                      ? whiteColor
                                                      : Colors.grey,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 9,
                                            child: Stack(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      // vertical: ,
                                                      horizontal: 4),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        height: 34,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.59,
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                right: 30,
                                                                left: 13,
                                                                bottom: 8,
                                                                top: 8),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: userProvider
                                                                  .user!
                                                                  .isSubscriptionEnable
                                                              ? blackColor
                                                              : const Color(
                                                                  0xff6f6f6f),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                        ),
                                                        child: Consumer<
                                                                UpdateProfileProvider>(
                                                            builder: (context,
                                                                updatePro, _) {
                                                          //  selected price

                                                          return Text(
                                                            updatePro.price
                                                                    .isNotEmpty
                                                                ? updatePro
                                                                    .price
                                                                : userProvider.user!.price ==
                                                                            0.00 &&
                                                                        userProvider
                                                                            .user!
                                                                            .isSubscriptionEnable &&
                                                                        updatePro
                                                                            .price
                                                                            .isEmpty
                                                                    ? '4.00'
                                                                    : userProvider
                                                                        .user!
                                                                        .price
                                                                        .toStringAsFixed(
                                                                            2),
                                                            // textAlign:
                                                            //     TextAlign.center,
                                                            style: TextStyle(
                                                                color:
                                                                    whiteColor,
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    fontFamily),
                                                          );
                                                        }),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Positioned(
                                                  left: size.width * 0.52,
                                                  bottom: 1,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(9),
                                                    decoration: BoxDecoration(
                                                      color: userProvider.user!
                                                              .isSubscriptionEnable
                                                          ? primaryColor
                                                          : const Color(
                                                              0xffcdcdcd),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              18),
                                                    ),
                                                    child: InkWell(
                                                      onTap: () {
                                                        if (userProvider.user!
                                                                .isVerified &&
                                                            userProvider.user!
                                                                .isSubscriptionEnable) {
                                                          //  dialog to select the price

                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (context) =>
                                                                    AlertDialog(
                                                              backgroundColor:
                                                                  whiteColor,
                                                              elevation: 0,
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                      .all(0),
                                                              content:
                                                                  Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(8),
                                                                decoration: BoxDecoration(
                                                                    color:
                                                                        whiteColor,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            15)),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              8),
                                                                      child:
                                                                          InkWell(
                                                                        onTap:
                                                                            () {
                                                                          Provider.of<UpdateProfileProvider>(context, listen: false)
                                                                              .setPrice('4.00');
                                                                          navPop(
                                                                              context);
                                                                        },
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              8.0),
                                                                          child:
                                                                              Text(
                                                                            '\$4.00',
                                                                            style:
                                                                                TextStyle(fontSize: 15, fontFamily: fontFamily),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      width: double
                                                                          .infinity,
                                                                      height: 1,
                                                                      color: Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.5),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              8),
                                                                      child:
                                                                          InkWell(
                                                                        onTap:
                                                                            () {
                                                                          Provider.of<UpdateProfileProvider>(context, listen: false)
                                                                              .setPrice('10.00');
                                                                          navPop(
                                                                              context);
                                                                        },
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              8.0),
                                                                          child:
                                                                              Text(
                                                                            '\$10.00',
                                                                            style:
                                                                                TextStyle(fontSize: 15, fontFamily: fontFamily),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      width: double
                                                                          .infinity,
                                                                      height: 1,
                                                                      color: Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.5),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              8),
                                                                      child:
                                                                          InkWell(
                                                                        onTap:
                                                                            () {
                                                                          Provider.of<UpdateProfileProvider>(context, listen: false)
                                                                              .setPrice('20.00');
                                                                          navPop(
                                                                              context);
                                                                        },
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              8.0),
                                                                          child:
                                                                              Text(
                                                                            '\$20.00',
                                                                            style:
                                                                                TextStyle(fontSize: 15, fontFamily: fontFamily),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      width: double
                                                                          .infinity,
                                                                      height: 1,
                                                                      color: Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.5),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              8),
                                                                      child:
                                                                          InkWell(
                                                                        onTap:
                                                                            () {
                                                                          Provider.of<UpdateProfileProvider>(context, listen: false)
                                                                              .setPrice('50.00');
                                                                          navPop(
                                                                              context);
                                                                        },
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              8.0),
                                                                          child:
                                                                              Text(
                                                                            '\$50.00',
                                                                            style:
                                                                                TextStyle(fontSize: 15, fontFamily: fontFamily),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      width: double
                                                                          .infinity,
                                                                      height: 1,
                                                                      color: Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.5),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              8),
                                                                      child:
                                                                          InkWell(
                                                                        onTap:
                                                                            () {
                                                                          Provider.of<UpdateProfileProvider>(context, listen: false)
                                                                              .setPrice('100.00');
                                                                          navPop(
                                                                              context);
                                                                        },
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              8.0),
                                                                          child:
                                                                              Text(
                                                                            '\$100.00',
                                                                            style:
                                                                                TextStyle(fontSize: 15, fontFamily: fontFamily),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        } else {
                                                          showWhiteOverlayPopup(
                                                              context,
                                                              null,
                                                              'assets/icons/Info (1).svg',
                                                              null,
                                                              title: 'Error',
                                                              message:
                                                                  'You need to be verified to add the price',
                                                              isUsernameRes:
                                                                  false);
                                                        }
                                                      },
                                                      child: const Icon(
                                                        Icons.edit_outlined,
                                                        color: Colors.white,
                                                        size: 15,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Divider(
                                      endIndent: 10,
                                      indent: 10,
                                      height: 1,
                                      color: Colors.white.withOpacity(0.2),
                                    ),

                                    Consumer<UpdateProfileProvider>(
                                        builder: (context, updatePro, _) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 10, right: 20, top: 5),
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: ElevatedButton.icon(
                                              style: ButtonStyle(
                                                  fixedSize:
                                                      const WidgetStatePropertyAll(
                                                          Size(145, 40)),
                                                  backgroundColor:
                                                      WidgetStatePropertyAll(
                                                          whiteColor)),
                                              onPressed: () async {
                                                //  function to update the the user data after getting all the data based on different checks

                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  if (userProvider
                                                      .user!.isVerified) {
                                                    if (userNameError == null &&
                                                        linkError == null &&
                                                        passError == null &&
                                                        contactError == null &&
                                                        (DateTime.now()
                                                                        .difference(dateOfBirth ??
                                                                            userProvider.user!.dateOfBirth)
                                                                        .inDays /
                                                                    365)
                                                                .floor() >=
                                                            12) {
                                                      userProvider
                                                          .setUserLoading(true);

                                                      String? image;
                                                      if (userProvider
                                                              .userImage !=
                                                          null) {
                                                        //  uploading the user image to storage

                                                        image = await AddNoteController()
                                                            .uploadFile(
                                                                'profile',
                                                                userProvider
                                                                    .userImage!,
                                                                context);
                                                      }

                                                      //  pushing the user to home screen

                                                      navPush(
                                                          BottomBar.routeName,
                                                          context);

                                                      //  in the background we are updating the date in the firestore database

                                                      UpdateProfileController()
                                                          .updateProfile(
                                                              pass.isEmpty
                                                                  ? userProvider
                                                                      .user!
                                                                      .password
                                                                  : pass,
                                                              name.isEmpty
                                                                  ? userProvider
                                                                      .user!
                                                                      .username
                                                                  : name,
                                                              username.isEmpty
                                                                  ? userProvider
                                                                      .user!
                                                                      .name
                                                                  : username,
                                                              _bioController
                                                                      .text
                                                                      .isNotEmpty
                                                                  ? _bioController
                                                                      .text
                                                                  : userProvider
                                                                      .user!
                                                                      .bio,
                                                              link.isEmpty
                                                                  ? userProvider
                                                                      .user!
                                                                      .link
                                                                  : link,
                                                              contact.isEmpty
                                                                  ? userProvider
                                                                      .user!
                                                                      .contact
                                                                  : contact,
                                                              userProvider.user!
                                                                  .isSubscriptionEnable,
                                                              updatePro.price
                                                                      .isNotEmpty
                                                                  ? double.parse(
                                                                      updatePro
                                                                          .price)
                                                                  : userProvider.user!.price == 0.0 &&
                                                                          userProvider
                                                                              .user!
                                                                              .isSubscriptionEnable &&
                                                                          updatePro
                                                                              .price
                                                                              .isEmpty
                                                                      ? 4.0
                                                                      : userProvider
                                                                          .user!
                                                                          .price,
                                                              updatePro
                                                                  .fileUrls,
                                                              image ??
                                                                  userProvider
                                                                      .user!
                                                                      .photoUrl,
                                                              dateOfBirth ??
                                                                  userProvider
                                                                      .user!
                                                                      .dateOfBirth,
                                                              context,
                                                              userProvider.user!.uid)
                                                          .then((value) async {
                                                        if (updatePro
                                                            .price.isNotEmpty) {
                                                          //  notifying the subscribed users about changed price

                                                          for (var userId
                                                              in userProvider
                                                                  .user!
                                                                  .subscribedUsers) {
                                                            NotificationMethods
                                                                .sendPushNotification(
                                                                    userId,
                                                                    '',
                                                                    '${userProvider.user!.name} has changed the subscription price which is \$${updatePro.price}',
                                                                    userProvider
                                                                        .user!
                                                                        .name,
                                                                    'subscription',
                                                                    '');
                                                          }
                                                        }
                                                        userProvider
                                                            .setUserLoading(
                                                                false);
                                                        userProvider
                                                            .removeImage();
                                                      });
                                                    }
                                                  } else {
                                                    //  else would run when user is not verified

                                                    if (userNameError == null &&
                                                        linkError == null &&
                                                        passError == null &&
                                                        contactError == null &&
                                                        (DateTime.now()
                                                                        .difference(dateOfBirth ??
                                                                            userProvider.user!.dateOfBirth)
                                                                        .inDays /
                                                                    365)
                                                                .floor() >=
                                                            12) {
                                                      userProvider
                                                          .setUserLoading(true);

                                                      String? image;
                                                      if (userProvider
                                                              .userImage !=
                                                          null) {
                                                        //  uploading the user image

                                                        image = await AddNoteController()
                                                            .uploadFile(
                                                                'profile',
                                                                userProvider
                                                                    .userImage!,
                                                                context);
                                                      }

                                                      // pushing to home screen

                                                      navPush(
                                                          BottomBar.routeName,
                                                          context);

                                                      //  in the background we are updating the date in the firestore database

                                                      UpdateProfileController()
                                                          .updateProfile(
                                                              pass.isEmpty
                                                                  ? userProvider
                                                                      .user!
                                                                      .password
                                                                  : pass,
                                                              name.isEmpty
                                                                  ? userProvider
                                                                      .user!
                                                                      .username
                                                                  : name,
                                                              username.isEmpty
                                                                  ? userProvider
                                                                      .user!
                                                                      .name
                                                                  : username,
                                                              _bioController
                                                                      .text
                                                                      .isNotEmpty
                                                                  ? _bioController
                                                                      .text
                                                                  : userProvider
                                                                      .user!
                                                                      .bio,
                                                              link.isEmpty
                                                                  ? userProvider
                                                                      .user!
                                                                      .link
                                                                  : link,
                                                              contact.isEmpty
                                                                  ? userProvider
                                                                      .user!
                                                                      .contact
                                                                  : contact,
                                                              userProvider.user!
                                                                  .isSubscriptionEnable,
                                                              updatePro.price
                                                                      .isNotEmpty
                                                                  ? double.parse(
                                                                      updatePro
                                                                          .price)
                                                                  : userProvider
                                                                      .user!
                                                                      .price,
                                                              updatePro
                                                                  .fileUrls,
                                                              image ??
                                                                  userProvider
                                                                      .user!
                                                                      .photoUrl,
                                                              dateOfBirth ??
                                                                  userProvider
                                                                      .user!
                                                                      .dateOfBirth,
                                                              context,
                                                              userProvider
                                                                  .user!.uid)
                                                          .then((value) {
                                                        userProvider
                                                            .setUserLoading(
                                                                false);
                                                        userProvider
                                                            .removeImage();
                                                      });
                                                    }
                                                  }
                                                } else {
                                                  setState(() {
                                                    _formKey.currentState!
                                                        .validate();
                                                  });
                                                }
                                              },
                                              icon: Icon(
                                                Icons.check,
                                                color: blackColor,
                                                size: 25,
                                              ),
                                              label: userProvider.userLoading
                                                  ? SpinKitThreeBounce(
                                                      color: blackColor,
                                                      size: 13,
                                                    )
                                                  : Text(
                                                      'Save profile',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: blackColor,
                                                          fontFamily:
                                                              fontFamily),
                                                    )),
                                        ),
                                      );
                                    })
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
    );
  }
}

class FieldForDate extends StatefulWidget {
  const FieldForDate(
      {super.key,
      required this.dateOfBirth,
      required this.showDatePicker,
      required this.onChanged});
  final String dateOfBirth;
  final VoidCallback showDatePicker;
  final ValueChanged<String> onChanged;

  @override
  State<FieldForDate> createState() => _FieldForDateState();
}

class _FieldForDateState extends State<FieldForDate> {
  late TextEditingController controller;
  @override
  void initState() {
    controller = TextEditingController(text: widget.dateOfBirth);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return TextFormField(
      controller: controller,
      // initialValue:
      // DateFormat.yMMMd()
      //     .format(dateOfBirth ?? userProvider.user!.dateOfBirth),

      readOnly: true,
      onChanged: (value) {
        widget.onChanged(value);
      },
      textAlignVertical: TextAlignVertical.top,
      style: TextStyle(color: whiteColor, fontSize: 14, fontFamily: fontFamily),
      decoration: InputDecoration(
        fillColor: blackColor,
        filled: true,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(19),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(19),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(19),
            borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.only(
          bottom: 0,
          top: 0,
          left: 14,
          right: 0,
        ),
        isDense: true,
        suffixIconConstraints:
            const BoxConstraints(minHeight: 18, minWidth: 18),
        suffix: Container(
          // height: 20,
          // width: 20,
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: InkWell(
            onTap: () {
              widget.showDatePicker();
            },
            child: const Icon(
              Icons.edit,
              color: Colors.white,
              size: 15,
            ),
          ),
        ),
        constraints: BoxConstraints(
          minHeight: 34,
          maxHeight: 34,
          // widget.validate &&
          //         widget.validator != null
          //     ? 54
          //     : 34,
          maxWidth: size.width * 0.8,
          minWidth: size.width * 0.8,
        ),
      ),
    );
  }
}
