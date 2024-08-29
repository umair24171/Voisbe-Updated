import 'package:flutter/material.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/resources/navigation.dart';

class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions({super.key});

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
            'Terms & Conditions',
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
                    '''Welcome to the VOISBE mobile application ("App"), provided by Nois7 Ltd ("Company"). By accessing and using the App, you agree to comply with and be bound by the following Terms and Conditions ("Terms"). Please read these Terms carefully before using the App.''',
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
                    '1. Introduction: ',
                    style: TextStyle(
                        color: blackColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: khulaRegular),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    'The VOISBE App is designed to facilitate the sharing of voice messages and creative audio content among users. Users must create an account to access the features and functionalities offered by the App.',
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
                    '2. User Commitments: ',
                    style: TextStyle(
                        color: blackColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: khulaRegular),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    '''In order to maintain a safe, secure, and inclusive environment within the VOISBE community, we require users to make the following commitments:
            •Users must be at least 13 years old.
            • Users must not engage in any activities prohibited by applicable laws or engage in 
            any illegal or unauthorized purposes while using the App.
            • Users must not have had their VOISBE account previously disabled for violations of 
            law or our policies.
            • Users must not be convicted sex offenders.
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
                    '3. Prohibited Activities: ',
                    style: TextStyle(
                        color: blackColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: khulaRegular),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    '''To ensure the safety and integrity of the VOISBE community, users are prohibited from engaging in the following activities:
            •Impersonating others or providing inaccurate information.
            • Engaging in unlawful, misleading, or fraudulent activities.
            • Violating VOISBE's Terms and Community Guidelines, including the prohibition of 
            hate speech, harassment, and intellectual property infringement.
            • Interfering with or impairing the intended operation of the App.
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
                    '4. Data Privacy and Security: ',
                    style: TextStyle(
                        color: blackColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: khulaRegular),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    '''We prioritize the privacy and security of user data on VOISBE. All user data is encrypted and securely hosted on Firebase servers. For more information on how we collect, use, and protect your data, please refer to our Privacy Policy.''',
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
                    '5. Reserved Usernames Policy:',
                    style: TextStyle(
                        color: blackColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: khulaRegular),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    '''We value the integrity of our platform and aim to maintain a positive and respectful community experience for all users. As part of our commitment to this goal, we have implemented a Reserved Usernames Policy to prevent unauthorized use of usernames associated with well-known individuals, celebrities, public figures, and other protected entities.
            
            Reserved usernames are those that have been identified by our team as belonging to individuals or entities with significant public recognition. These may include, but are not limited to, names of celebrities, prominent public figures, trademarks, and other protected names.
            
            As a user of our platform, you agree not to register or use any username that has been reserved by our system. Attempting to register such usernames will result in an error during the registration process, indicating that the username is unavailable.
            Our Reserved Usernames Policy helps prevent impersonation, misuse, or misrepresentation of individuals or entities with significant public presence. By adhering to this policy, we aim to foster a safe and trustworthy environment for all users.
            Please note that our list of reserved usernames may be updated periodically to reflect changes in public figures or trademarks. We reserve the right to modify, expand, or update the list of reserved usernames at our discretion.
            
            By using our platform, you agree to abide by our Reserved Usernames Policy and understand that failure to comply may result in the rejection of username registrations or other appropriate actions as determined by our team.
            
            Thank you for helping us maintain the integrity of our community and respecting the rights of individuals and entities within it.
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
                    '6. Subscription Services: ',
                    style: TextStyle(
                        color: blackColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: khulaRegular),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    '''VOISBE offers subscription services for verified users, providing access to exclusive features and content within the App. Subscribers agree to a monthly fee, with content creators receiving a commission from each subscription.
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
                    '7. Customer Support and Reporting: ',
                    style: TextStyle(
                        color: blackColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: khulaRegular),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    '''For assistance or to report any issues related to the App, users can contact our dedicated support team at hello@voisbe.com or support@voisbe.com. Additionally, users can report inappropriate content directly from within the App.''',
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
                    '8. Rights and Limitations: ',
                    style: TextStyle(
                        color: blackColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: khulaRegular),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    '''Users must adhere to VOISBE's Terms and Community Guidelines, which include prohibitions against hate speech, harassment, and intellectual property infringement. Users must not engage in any activities that interfere with or impair the intended operation of the App.''',
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
                    '9. Disputes: ',
                    style: TextStyle(
                        color: blackColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: khulaRegular),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    '''Any disputes arising from the use of VOISBE shall be resolved through arbitration in accordance with the laws of Malta. Users agree to waive their right to participate in class action lawsuits against VOISBE.''',
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
                    '10. Termination: ',
                    style: TextStyle(
                        color: blackColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: khulaRegular),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    '''VOISBE reserves the right to terminate or suspend user accounts that violate our Terms and Community Guidelines. In the event of termination, users may lose access to their account and any associated content.''',
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
                    '11. Modifications to Terms:',
                    style: TextStyle(
                        color: blackColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: khulaRegular),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    '''We reserve the right to update or modify these Terms at any time without prior notice. Users will be notified of any changes to the Terms via email or through the App.
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
                    '12. Governing Law: ',
                    style: TextStyle(
                        color: blackColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: khulaRegular),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    '''These Terms and Conditions are governed by the laws of Malta, without regard to its conflict of law principles.
            
            By using the VOISBE App, you acknowledge that you have read, understood, and agreed to these Terms and Conditions, as well as our Privacy Policy.
            
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
                    'Updating These Terms',
                    style: TextStyle(
                        color: blackColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: khulaRegular),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    '''We may change our Service and policies, and we may need to make changes to these Terms so that they accurately reflect our Service and policies. Unless otherwise required by law, we will notify you (for example, through our Service) at least 30 days before we make changes to these Terms and give you an opportunity to review them before they go into effect. Then, if you continue to use the Service, you will be bound by the updated Terms. If you do not want to agree to these or any updated Terms, you can delete your account.
            
            Effective Date: 2024-02-01
            
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
