import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

Future<bool?> showToast(msg) {
  return Fluttertoast.showToast(
    backgroundColor: const Color.fromARGB(255, 0, 90, 163),
    toastLength: Toast.LENGTH_LONG,
    msg: msg,
  );
}
