import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:valley_students_and_teachers/widgets/text_widget.dart';
import 'package:valley_students_and_teachers/widgets/toast_widget.dart';

import '../../utils/routes.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/textfield_widget.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final passController = TextEditingController();
  bool isLoading = true;

  checkSession() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (user.emailVerified) {
        var res = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();
        Map? data = res.data();
        if (data!['role'] == 'Student') {
          if (!context.mounted) return;
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes().studenthomescreen,
            (route) => false,
          );
        } else {
          if (!context.mounted) return;
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes().teacherhomescreen,
            (route) => false,
          );
        }
      } else {}
    } else {}
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 3), () {
      checkSession();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 0, 0, 0),
          image: DecorationImage(
            opacity: 0.9,
            image: AssetImage(
              'assets/images/back.jpg',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: isLoading == true
              ? const CircularProgressIndicator(
                  color: Colors.white,
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        Center(
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 500,
                          ),
                        ),
                        Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 200,
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              ButtonWidget(
                                fontColor: const Color.fromARGB(255, 0, 0, 0),
                                radius: 90,
                                color: const Color.fromARGB(255, 255, 255, 255),
                                label: 'STUDENT',
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, Routes().studentsloginscreen);
                                },
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              ButtonWidget(
                                fontColor: const Color.fromARGB(255, 0, 0, 0),
                                radius: 90,
                                color: const Color.fromARGB(255, 255, 255, 255),
                                label: 'FACULTY',
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, Routes().teachersloginscreen);
                                },
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              ButtonWidget(
                                fontColor: const Color.fromARGB(255, 0, 0, 0),
                                radius: 90,
                                color: const Color.fromARGB(255, 255, 255, 255),
                                label: 'ADMIN',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: TextRegular(
                                          color: Colors.black,
                                          text: 'Enter Admin Password',
                                          fontSize: 18,
                                        ),
                                        content: SizedBox(
                                          height: 100,
                                          child: TextFieldWidget(
                                              label: 'Password',
                                              isObscure: true,
                                              controller: passController),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              if (passController.text ==
                                                  'admin-password') {
                                                Navigator.pop(context);
                                                Navigator.pushNamed(context,
                                                    Routes().adminhome);
                                              } else {
                                                Navigator.pop(context);
                                                showToast(
                                                    'Invalid admin password!');
                                              }
                                              // Navigator.of(context).pushReplacement(
                                              //     MaterialPageRoute(
                                              //         builder: (context) =>
                                              //             const AdminHomeScreen()));
                                            },
                                            child: TextRegular(
                                              text: 'Continue',
                                              fontSize: 18,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  // Navigator.pushNamed(
                                  //     context, Routes().teachersloginscreen);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
