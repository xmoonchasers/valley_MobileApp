import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future addChatroom(members, membersId, name) async {
  final docUser = FirebaseFirestore.instance.collection('Chats').doc();

  final json = {
    'membersId': membersId,
    'messages': [],
    'members': members,
    'creator': FirebaseAuth.instance.currentUser!.uid,
    'dateTime': DateTime.now(),
    'name': name
  };

  await docUser.set(json);
}
