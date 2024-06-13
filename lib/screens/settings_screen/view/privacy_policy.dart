import 'package:flutter/material.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/navigation.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: whiteColor,
        appBar: AppBar(
          surfaceTintColor: whiteColor,
          backgroundColor: whiteColor,
          leading: IconButton(
            onPressed: () {
              navPop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: blackColor,
              size: 30,
            ),
          ),
          centerTitle: true,
          title: Text(
            'Privacy Policy',
            style: TextStyle(
                color: blackColor,
                fontSize: 18,
                fontFamily: khulaBold,
                fontWeight: FontWeight.w600),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    'VOISBE respects your privacy and is committed to protecting it through our compliance with this policy.This page informs visitors regarding our policies with the collection, use, and disclosure of Personal Information if anyone decides to use our Service. By using our Service, you agree to the collection and use of information in relation to this policy',
                    style: TextStyle(
                        fontFamily: khulaRegular,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                  ).copyWith(top: 10),
                  child: Text(
                    'Information Collection and Use',
                    style: TextStyle(
                        color: blackColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: khulaRegular),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    'We may require you to provide us with certain personally identifiable information for a better experience while using our Service. This information will be retained by us and used as described in this privacy policy. The app utilizes third-party services that may collect information used to identify you. Links to the privacy policies of third-party service providers used by the app are provided below.\n• Google Play Services\n• Google Analytics for Firebase\n• Firebase Crashlytics\n• Facebook',
                    style: TextStyle(
                        fontFamily: khulaRegular,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                  ).copyWith(top: 10),
                  child: Text(
                    'Log Data',
                    style: TextStyle(
                        color: blackColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: khulaRegular),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    '''Whenever you use our Service, in a case of an error in the app, we collect data and information (through third-party products) on your phone called Log Data. This Log Data may include information such as your device's Internet Protocol (“IP”) address, device name, operating system version, app configuration, usage statistics, and other diagnostic data.''',
                    style: TextStyle(
                        fontFamily: khulaRegular,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                  ).copyWith(top: 10),
                  child: Text(
                    'Information You Provide to Us',
                    style: TextStyle(
                        color: blackColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: khulaRegular),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    '''We collect information you provide when you download, install, register with, or use the App. This may include personal information such as name, email address, username, password, and any information provided when filling out forms or contacting us.''',
                    style: TextStyle(
                        fontFamily: khulaRegular,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                  ).copyWith(top: 10),
                  child: Text(
                    'Automatic Information Collection and Tracking',
                    style: TextStyle(
                        color: blackColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: khulaRegular),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    '''The App may use technology to automatically collect usage details and device information when you access and use the App.''',
                    style: TextStyle(
                        fontFamily: khulaRegular,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                  ).copyWith(top: 10),
                  child: Text(
                    'Service Providers',
                    style: TextStyle(
                        color: blackColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: khulaRegular),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    '''We may employ third-party companies and individuals to facilitate our Service, provide the Service on our behalf, perform Service-related services, or assist us in analyzing how our Service is used. These third parties have access to your Personal Information and are obligated not to disclose or use it for any other purpose.''',
                    style: TextStyle(
                        fontFamily: khulaRegular,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                  ).copyWith(top: 10),
                  child: Text(
                    'Access to Microphone and Photos',
                    style: TextStyle(
                        color: blackColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: khulaRegular),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    '''VOISBE requires access to your device's microphone and photos for specific features:
             • Microphone Access: VOISBE uses your device's  microphone to enable you to 
             record voice messages within the app.
             • Photo Access: Additionally, VOISBE requests access to your device's photos to 
             allow you to upload a profile picture.
            
             We assure you that access to your microphone and photos is solely used for the intended purposes described above and is not shared with any third parties without your explicit consent.
            ''',
                    style: TextStyle(
                        fontFamily: khulaRegular,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                  ).copyWith(top: 10),
                  child: Text(
                    'Data Security',
                    style: TextStyle(
                        color: blackColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: khulaRegular),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    '''We have implemented measures designed to secure your personal information from accidental loss and unauthorized access, use, alteration, and disclosure.''',
                    style: TextStyle(
                        fontFamily: khulaRegular,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                  ).copyWith(top: 10),
                  child: Text(
                    'Cookies',
                    style: TextStyle(
                        color: blackColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: khulaRegular),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    '''This Service does not use cookies explicitly. However, third-party code and libraries may use cookies to collect information and improve their services. You have the option to accept or refuse these cookies and know when a cookie is being sent to your device.''',
                    style: TextStyle(
                        fontFamily: khulaRegular,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                  ).copyWith(top: 10),
                  child: Text(
                    'Children’s Privacy',
                    style: TextStyle(
                        color: blackColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: khulaRegular),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    '''Our Service does not address anyone under the age of 13. We do not knowingly collect personally identifiable information from children under 13 years of age. If we discover that a child under 13 has provided us with personal information, we will immediately delete it from our servers.''',
                    style: TextStyle(
                        fontFamily: khulaRegular,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                  ).copyWith(top: 10),
                  child: Text(
                    'Contact Information',
                    style: TextStyle(
                        color: blackColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: khulaRegular),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    '''If you have any questions or comments about this privacy policy or our privacy practices, please contact us at hello@voisbe.com.''',
                    style: TextStyle(
                        fontFamily: khulaRegular,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                  ).copyWith(top: 10),
                  child: Text(
                    'Changes to Our Privacy Policy',
                    style: TextStyle(
                        color: blackColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: khulaRegular),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    '''We may update our privacy policy from time to time. If we make material changes to how we treat our users' personal information, we will notify you through a notice on the App home screen.
            This policy is effective as of 2024-02-01
            ''',
                    style: TextStyle(
                        fontFamily: khulaRegular,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
