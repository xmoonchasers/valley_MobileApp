// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// Future addUser(name, idNumber, password, role) async {
//   final docUser = FirebaseFirestore.instance
//       .collection('Users')
//       .doc(FirebaseAuth.instance.currentUser!.uid);

//   final json = {
//     'name': name,
//     'idNumber': idNumber,
//     'password': password,
//     'role': role,
//     'avail': '',
//     'isActive': true,
//     'imageUrl': ''
//   };

//   await docUser.set(json);
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Future addUser(name, idNumber, password, role, ) async {
//   final docUser = FirebaseFirestore.instance
//       .collection('Users')
//       .doc(FirebaseAuth.instance.currentUser!.uid);

//   final json = {
//     'name': name,
//     'idNumber': idNumber,
//     'password': password,
//     'role': role,
//     'avail': '',
//     'isActive': true,
//     'imageUrl': ''
//   };

//   await docUser.set(json);
// }

Future addUser(name, email, password, role, idnumber, course, year) async {
  final docUser = FirebaseFirestore.instance
      .collection('Users')
      .doc(FirebaseAuth.instance.currentUser!.uid);

  final json = {
    'name': name,
    'idNumber': email,
    'card': idnumber,
    'password': password,
    'role': role,
    'avail': '',
    'isActive': true,
    'imageUrl': '',
    'section': "",
    'email': email,
    'course': course,
    'year': year
  };

  await docUser.set(json);
}
