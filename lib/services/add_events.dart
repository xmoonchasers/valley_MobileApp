import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future addEvents(name, details, date, day, month, year, section) async {
  final docUser = FirebaseFirestore.instance.collection('Events').doc();

  final json = {
    'name': name,
    'details': details,
    'date': date,
    'day': day,
    'month': month,
    'year': year,
    'section': section,
    'userId': FirebaseAuth.instance.currentUser!.uid
  };

  await docUser.set(json);
}
