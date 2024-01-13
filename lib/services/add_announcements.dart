import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future addAnnouncement(
  description,
) async {
  final docUser = FirebaseFirestore.instance.collection('Announcements').doc();

  final json = {
    'description': description,
    'dateTime': DateTime.now(),
    'id': docUser.id,
    'toshow': false,
    'userId': FirebaseAuth.instance.currentUser!.uid,
  };

  await docUser.set(json);
}
