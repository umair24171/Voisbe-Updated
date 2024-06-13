import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:flutter/widgets.dart';
import 'package:social_notes/resources/colors.dart';
import 'package:social_notes/screens/auth_screens/model/user_model.dart';
import 'package:social_notes/screens/chat_screen.dart/model/chat_model.dart';
import 'package:social_notes/screens/chat_screen.dart/provider/chat_provider.dart';
import 'package:social_notes/screens/chat_screen.dart/view/widgets/chat_player.dart';
import 'package:social_notes/screens/user_profile/other_user_profile.dart';
import 'package:voice_message_package/voice_message_package.dart';

class CustomMessageNote extends StatelessWidget {
  const CustomMessageNote(
      {super.key,
      required this.isMe,
      required this.isShare,
      required this.conversationId,
      required this.chatModel});
  final bool isMe;
  final bool isShare;
  final ChatModel chatModel;
  final String conversationId;

  @override
  Widget build(BuildContext context) {
    !isMe
        ? Provider.of<ChatProvider>(
            context,
          ).updateMessageRead(conversationId, chatModel.chatId)
        : '';
    var size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.only(left: isShare && isMe ? size.width * 0.16 : 0),
      alignment: isShare
          ? Alignment.centerRight
          : isMe
              ? Alignment.centerRight
              : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        child: Stack(
          children: [
            Container(
                padding: const EdgeInsets.only(
                  top: 17,
                ),
                margin: const EdgeInsets.only(
                  top: 12,
                ),
                child: ChatPlayer(
                    isShare: isShare,
                    isOtherMsg: isMe ? false : true,
                    noteUrl: chatModel.message,
                    height: 40,
                    width: 180,
                    size: 35,
                    mainWidth: size.width * 0.83,
                    waveColor: isShare
                        ? whiteColor
                        : isMe
                            ? primaryColor
                            : whiteColor,
                    backgroundColor: isShare
                        ? Colors.grey.withOpacity(0.7)
                        : isMe
                            ? whiteColor
                            : primaryColor,
                    mainHeight: 95)
                // VoiceMessageView(
                //   // notActiveSliderColor: red,
                //   // circlesColor: isMe ? primaryColor : whiteColor,
                //   counterTextStyle:
                //       TextStyle(color: isMe ? primaryColor : whiteColor),
                //   // circlesTextStyle: TextStyle(
                //   //     color: isMe
                //   //         ? whiteColor
                //   //         : isShare
                //   //             ? Colors.grey
                //   //             : primaryColor),
                //   activeSliderColor: isShare
                //       ? whiteColor
                //       : isMe
                //           ? primaryColor
                //           : whiteColor,
                //   // notActiveSliderColor: whiteColor,
                //   innerPadding: 16,
                //   cornerRadius: 50,
                // backgroundColor: isShare
                //     ? Colors.grey.withOpacity(0.7)
                //     : isMe
                //         ? whiteColor
                //         : primaryColor,
                //   controller: VoiceController(
                //     audioSrc: chatModel.message,
                //     maxDuration: const Duration(seconds: 500),
                //     isFile: false,
                //     onComplete: () {},
                //     onPause: () {},
                //     onPlaying: () {},
                //     onError: (err) {},
                //   ),
                // ),
                ),
            isMe && isShare
                ? Positioned(
                    left: MediaQuery.of(context).size.width * 0.71,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isShare
                              ? Colors.grey.withOpacity(0.7)
                              : whiteColor,
                          width: 2,
                        ),
                      ),
                      child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(chatModel.senderId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              UserModel user = UserModel.fromMap(
                                  snapshot.data?.data() ?? {});
                              return CircleAvatar(
                                radius: 17,
                                backgroundImage: NetworkImage(user.photoUrl),
                              );
                            } else {
                              return const Text('');
                            }
                          }),
                    ),
                  )
                : !isMe || isShare
                    ? Positioned(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isShare
                                  ? Colors.grey.withOpacity(0.7)
                                  : whiteColor,
                              width: 2,
                            ),
                          ),
                          child: StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(chatModel.senderId)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  UserModel user = UserModel.fromMap(
                                      snapshot.data?.data() ?? {});
                                  return CircleAvatar(
                                    radius: 17,
                                    backgroundImage:
                                        NetworkImage(user.photoUrl),
                                  );
                                } else {
                                  return const Text('');
                                }
                              }),
                        ),
                      )
                    : Positioned(
                        left: MediaQuery.of(context).size.width * 0.71,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: primaryColor,
                              width: 2,
                            ),
                          ),
                          child: StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(chatModel.senderId)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  UserModel user = UserModel.fromMap(
                                      snapshot.data?.data() ?? {});
                                  return CircleAvatar(
                                    radius: 17,
                                    backgroundImage:
                                        NetworkImage(user.photoUrl),
                                  );
                                } else {
                                  return const Text('');
                                }
                              }),
                        ),
                      ),
            if (isShare)
              Padding(
                padding: EdgeInsets.only(
                    left: isMe && isShare ? 0 : size.width * 0.13,
                    right: isMe && isShare ? size.width * 0.15 : 0,
                    bottom: 10),
                child: Row(
                  mainAxisAlignment: isMe && isShare
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    Text(
                      'Sent ',
                      style:
                          TextStyle(fontFamily: fontFamily, color: whiteColor),
                    ),
                    StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .where('name', isEqualTo: chatModel.postOwner)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            UserModel postOwner = UserModel.fromMap(
                                snapshot.data!.docs.first.data());
                            return InkWell(
                              splashColor: Colors.transparent,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        OtherUserProfile(userId: postOwner.uid),
                                  ),
                                );
                              },
                              child: Text(
                                '@${postOwner.name}',
                                style: TextStyle(
                                    fontFamily: fontFamily, color: blackColor),
                              ),
                            );
                          } else {
                            return const SizedBox();
                          }
                        }),
                    Text(
                      '\'s post',
                      style:
                          TextStyle(fontFamily: fontFamily, color: whiteColor),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
