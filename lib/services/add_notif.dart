import 'package:cloud_firestore/cloud_firestore.dart';

Future addNotif(name, type, userId) async {
  final docUser = FirebaseFirestore.instance.collection('Notif').doc();

  final json = {
    'name': name,
    'type': type,
    'userId': userId,
    'dateTime': DateTime.now(),
  };

  await docUser.set(json);
}
