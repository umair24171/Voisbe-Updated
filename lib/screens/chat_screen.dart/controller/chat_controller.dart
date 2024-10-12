import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:social_notes/screens/add_note_screen/provider/note_provider.dart';
import 'package:social_notes/screens/chat_screen.dart/model/chat_model.dart';

class ChatController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //  sending message function

  sendMessage(
      ChatModel chat,
      String chatId,
      String usersId,
      String receiverName,
      String receiverImage,
      String senderToken,
      String receiverToken,
      List<double> waveforms,
      context) async {
    try {
      Provider.of<NoteProvider>(context, listen: false).setIsLoading(true);

      // sending message to the sub collection

      await _firestore
          .collection('chats')
          .doc(usersId)
          .collection('messages')
          .doc(chatId)
          .set(chat.toMap());

      //  sending to the main collection to show the recent chat user

      await _firestore.collection('chats').doc(usersId).set({
        'chatID': chatId,
        'senderToken': senderToken,
        'receiverToken': receiverToken,
        'senderId': chat.senderId,
        'receiverId': chat.receiverId,
        'message': chat.message,
        'time': chat.time,
        'senderImage': chat.avatarUrl,
        'receiverImage': receiverImage,
        'senderName': chat.name,
        'deletedChat': [],
        'receiverName': receiverName,
        'seen': false,
        'usersId': usersId,
        'waveforms': waveforms
      });
      Provider.of<NoteProvider>(context, listen: false).setIsLoading(false);
    } catch (e) {
      Provider.of<NoteProvider>(context, listen: false).setIsLoading(false);
      log(e.toString());
    }
  }
}
