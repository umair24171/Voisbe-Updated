// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/resources/colors.dart';
// import 'package:social_notes/resources/show_snack.dart';
import 'package:social_notes/screens/auth_screens/controller/auth_controller.dart';
import 'package:social_notes/screens/auth_screens/providers/auth_provider.dart';
import 'package:social_notes/screens/auth_screens/view/forgot_password.dart';
import 'package:social_notes/screens/auth_screens/view/widgets/custom_form_field.dart';

class AuthScreen extends StatelessWidget {
  AuthScreen({super.key});
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    // First of all the auth screen which has login and signup

    // The auth provider is basically here to manage the state of the screen so if the user has selected login tab or signup tab it has beeen managed through provider which named UserProvider

    var authProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        // the body starts from here
        child: Stack(
          children: [
            // the background of the screen which is gradient
            Container(
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xffee856d), Color(0xffed6a5a)])),
            ),

            // the content of the screen
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child:
                        // Image.asset(
                        //   'assets/icons/logo 1.png',
                        // height: 52,
                        // width: 27,
                        //   color: whiteColor,
                        // )
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: SvgPicture.asset(
                              'assets/icons/SVG.svg',
                              height: 39,
                              width: 27,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              'VOISBE',
                              style: TextStyle(
                                fontFamily: fontFamily2,
                                color: whiteColor,
                                // fontStyle: FontStyle.italic,
                                fontSize: 45,
                              ),
                            ),
                          )
                        ]),
                  ),

                  // the tabs which are signup and login managed through provider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          authProvider.setIslogin(false);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: authProvider.isLogin
                                ? primaryColor
                                : whiteColor,
                            border: Border.all(width: 2, color: whiteColor),
                          ),
                          child: Text(
                            'Create Account',
                            style: TextStyle(
                                // fontSize: 16,
                                color: authProvider.isLogin
                                    ? whiteColor
                                    : primaryColor,
                                fontFamily: fontFamily),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          authProvider.setIslogin(true);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 8),
                          decoration: BoxDecoration(
                            color: authProvider.isLogin
                                ? whiteColor
                                : primaryColor,
                            border: Border.all(width: 2, color: whiteColor),
                          ),
                          child: Text(
                            'Log In',
                            style: TextStyle(
                                color: authProvider.isLogin
                                    ? primaryColor
                                    : whiteColor,
                                fontFamily: fontFamily),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // which tab should show based on user selection

                  Padding(
                    padding: EdgeInsets.symmetric(
                            vertical: 5, horizontal: size.width * 0.12)
                        .copyWith(top: 30),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        authProvider.isLogin
                            ? 'Welcome Back'
                            : 'Create Account',
                        style: TextStyle(
                            fontFamily: fontFamily,
                            fontSize: 25,
                            color: whiteColor,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),

                  // the text will show based on the tab selection

                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: 0, horizontal: size.width * 0.12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        authProvider.isLogin
                            ? 'Fill out the information below in order to access your account.'
                            : 'Let\'s get started by filling out the form below.',
                        style: TextStyle(
                          fontFamily: fontFamily,
                          fontSize: 12,
                          color: whiteColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                  // the signup and login fields starts from here and managed by the user selection through user provider
                  // The following conditions would met then the fields would show up
                  //  these fields are showing the custom widget means the template or design of the field is defined in the custom widget

                  if (!authProvider.isLogin)
                    CustomFormField(
                      label: 'Name',
                      controller: nameController,
                      isPassword: false,
                    ),
                  CustomFormField(
                    label: 'Email',
                    controller: emailController,
                    isPassword: false,
                    isEmail: true,
                  ),
                  CustomFormField(
                      label: 'Password',
                      controller: passController,
                      isPassword: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Password is required';
                        } else if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      }),
                  if (!authProvider.isLogin)
                    CustomFormField(
                      label: 'Confirm Password',
                      controller: confirmController,
                      isPassword: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Password is required';
                        } else if (value != passController.text) {
                          return 'Password does not match';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(
                    height: 5,
                  ),

                  // Button to login or signup the user
                  Consumer<UserProvider>(builder: (context, userPro, _) {
                    return ElevatedButton(
                        style: ButtonStyle(
                            fixedSize:
                                const WidgetStatePropertyAll(Size(175, 45)),
                            backgroundColor:
                                WidgetStatePropertyAll(blackColor)),
                        onPressed: () {
                          // if following conditions would met the user would be login or register and then the related functions would run

                          if (!authProvider.isLogin) {
                            if (nameController.text.isNotEmpty &&
                                passController.text == confirmController.text &&
                                emailController.text.isNotEmpty &&
                                passController.text.isNotEmpty &&
                                confirmController.text.isNotEmpty) {
                              if (!emailController.text.contains('@') &&
                                  !emailController.text.contains('.')) {
                                // showSnackBar(context, 'Invalid email address');
                              } else {
                                AuthController().userSignup(
                                    email: emailController.text,
                                    password: passController.text,
                                    context: context,
                                    username: nameController.text);
                              }
                              // UserModel user=UserModel(uid: , username: username, email: email, photoUrl: photoUrl, following: following, pushToken: pushToken, followers: followers)
                            }
                          } else {
                            if (emailController.text.isNotEmpty &&
                                passController.text.isNotEmpty) {
                              if (!emailController.text.contains('@') &&
                                  !emailController.text.contains('.')) {
                                // showSnackBar(context, 'Invalid email address');
                              }
                              AuthController().userLogin(
                                  email: emailController.text,
                                  password: passController.text,
                                  context: context);
                            }
                          }
                        },
                        child:
                            // while the user is being register or login the meantime shows the loading
                            userPro.userLoading
                                ? SpinKitThreeBounce(
                                    color: whiteColor,
                                    size: 13,
                                  )
                                : Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 25, vertical: 13),
                                    child: Text(
                                      authProvider.isLogin
                                          ? 'Log In'
                                          : 'Get Started',
                                      style: TextStyle(
                                          fontFamily: fontFamily,
                                          color: whiteColor),
                                    ),
                                  ));
                  }),

                  // the text to show according to the tab
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        authProvider.isLogin
                            ? 'Or log in with '
                            : 'Or sign up with',
                        style: TextStyle(
                            fontFamily: fontFamily,
                            color: whiteColor,
                            fontSize: 12),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      //  this is the button if the user wants to login with the google
                      ElevatedButton.icon(
                        style: ButtonStyle(
                            fixedSize:
                                const MaterialStatePropertyAll(Size(170, 20)),
                            backgroundColor:
                                MaterialStatePropertyAll(whiteColor)),
                        onPressed: () async {
                          await AuthController().signInWithGoogle(context);
                        },
                        label: Text(
                          'Continue with Google',
                          style: TextStyle(
                              fontFamily: fontFamily,
                              color: blackColor,
                              fontSize: 11),
                        ),
                        icon: Image.asset(
                          'assets/images/google.png',
                          height: 13,
                          width: 13,
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ButtonStyle(
                            fixedSize:
                                const WidgetStatePropertyAll(Size(170, 20)),
                            backgroundColor: WidgetStatePropertyAll(
                              whiteColor,
                            )),
                        onPressed: () async {
                          await AuthController().signInWithApple(context);
                        },
                        label: Text(
                          'Continue with Apple',
                          style: TextStyle(
                              fontFamily: fontFamily,
                              color: blackColor,
                              fontSize: 11),
                        ),
                        icon: Image.asset(
                          'assets/images/apple-logo.png',
                          height: 13,
                          width: 13,
                        ),
                      )
                    ],
                  ),
                  if (authProvider.isLogin)
                    const SizedBox(
                      height: 10,
                    ),

                  // if the user is in the login tab and forgets the password then this is button click would do password reset
                  if (authProvider.isLogin)
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(blackColor)),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: whiteColor,
                                  elevation: 0,
                                  content: ForgotPasswordScreen(),
                                );
                              });
                        },
                        child: Text(
                          'Forgot your password?',
                          style: TextStyle(
                              fontFamily: fontFamily, color: whiteColor),
                        )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
