import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:valley_students_and_teachers/services/add_announcements.dart';
import 'package:valley_students_and_teachers/utils/media_query.dart';

import '../../services/add_user.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/text_widget.dart';
import '../../widgets/textfield_widget.dart';
import '../../widgets/toast_widget.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});
  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final passController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 0, 0, 0),
          image: DecorationImage(
            opacity: 200,
            image: AssetImage(
              'assets/images/back.jpg',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
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
                          height: 250,
                        ),
                        // ButtonWidget(
                        //   fontColor: Colors.black,
                        //   radius: 100,
                        //   height: 60,
                        //   color: Colors.white,
                        //   label: 'Register',
                        //   onPressed: () {
                        //     registerDialog();
                        //     // Navigator.pushNamed(context, Routes().adminstudent);
                        //   },
                        // ),
                        const SizedBox(
                          height: 20,
                        ),
                        ButtonWidget(
                          fontColor: Colors.black,
                          radius: 100,
                          height: 60,
                          color: Colors.white,
                          label: 'Laboratory Reservation',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return reservation();
                              },
                            );
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ButtonWidget(
                          fontColor: Colors.black,
                          radius: 100,
                          height: 60,
                          color: Colors.white,
                          label: 'Special Announcement',
                          onPressed: () {
                            announcementDialog();
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

  announcementDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: StatefulBuilder(builder: (context, setState) {
            return SizedBox(
              height: 500,
              width: 500,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Announcements')
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            print(snapshot.error);
                            return const Center(child: Text('Error'));
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 50),
                              child: Center(
                                  child: CircularProgressIndicator(
                                color: Colors.black,
                              )),
                            );
                          }

                          final data = snapshot.requireData;
                          return SizedBox(
                            height: 300,
                            width: double.infinity,
                            child: ListView.builder(
                              itemCount: data.docs.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: TextRegular(
                                      text:
                                          'Description: ${data.docs[index]['description']}',
                                      fontSize: 12,
                                      color: Colors.black),
                                  trailing: SizedBox(
                                    width: 150,
                                    child: Row(
                                      children: [
                                        IconButton(
                                          onPressed: () async {
                                            await FirebaseFirestore.instance
                                                .collection('Announcements')
                                                .doc(data.docs[index].id)
                                                .delete();
                                          },
                                          icon: const Icon(Icons.delete),
                                        ),
                                        data.docs[index]['toshow']
                                            ? IconButton(
                                                onPressed: () async {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection(
                                                          'Announcements')
                                                      .doc(data.docs[index].id)
                                                      .update(
                                                          {'toshow': false});

                                                  setState(() {});
                                                },
                                                icon:
                                                    const Icon(Icons.check_box),
                                              )
                                            : IconButton(
                                                onPressed: () async {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection(
                                                          'Announcements')
                                                      .doc(data.docs[index].id)
                                                      .update({'toshow': true});
                                                  setState(() {});
                                                },
                                                icon: const Icon(Icons
                                                    .check_box_outline_blank_outlined),
                                              )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20, top: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: TextRegular(
                            text: 'Close',
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(
                          width: 50,
                        ),
                        TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  content: announcements(),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: TextRegular(
                                        color: Colors.black,
                                        text: 'Close',
                                        fontSize: 12,
                                      ),
                                    )
                                  ],
                                );
                              },
                            );
                          },
                          child: TextRegular(
                            text: 'Add announcement',
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  final nameController = TextEditingController();

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final idnumberController = TextEditingController();

  final courseController = TextEditingController();

  final yearController = TextEditingController();

  registerDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
              backgroundColor: Colors.grey,
              child: SizedBox(
                // color: Colors.white.withOpacity(0.5),
                height: MediaQuery.of(context).size.height * 0.8,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFieldWidget(
                          label: 'Full Name', controller: nameController),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFieldWidget(
                          label: 'ID no', controller: idnumberController),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFieldWidget(
                          label: 'Course', controller: courseController),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFieldWidget(
                          label: 'Year', controller: yearController),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFieldWidget(
                          label: 'Email', controller: emailController),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFieldWidget(
                          isPassword: true,
                          isObscure: true,
                          label: 'Password',
                          controller: passwordController),
                      const SizedBox(
                        height: 30,
                      ),
                      ButtonWidget(
                          color: Colors.black,
                          label: 'Register',
                          onPressed: (() async {
                            final email = emailController.text;
                            final password = passwordController.text;
                            if (isValidEmail(email) &&
                                isValidPassword(password)) {
                              try {
                                await FirebaseAuth.instance
                                    .createUserWithEmailAndPassword(
                                        email: emailController.text,
                                        password: passwordController.text);
                                // addUser(
                                //     newNameController
                                //         .text,
                                //     newEmailController
                                //         .text,
                                //     newPassController
                                //         .text);

                                addUser(
                                    nameController.text,
                                    emailController.text,
                                    passwordController.text,
                                    'Student',
                                    idnumberController.text,
                                    courseController.text,
                                    yearController.text);
                                if (!context.mounted) return;

                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: TextRegular(
                                        text: 'Account created succesfully!',
                                        fontSize: 14,
                                        color: Colors.white),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: TextRegular(
                                        text: e.toString(),
                                        fontSize: 14,
                                        color: Colors.white),
                                  ),
                                );
                              }
                            } else {
                              showToast(
                                  'Invalid email and password combination!');
                            }
                          })),
                    ],
                  ),
                ),
              ));
        });
  }

  bool isValidEmail(String email) {
    // Validate email using a regular expression for CSPC email format.

    if (email.contains('@my.cspc.edu.ph')) {
      return true;
    } else {
      return false;
    }
  }

  bool isValidPassword(String password) {
    // Check if password has at least 8 characters and contains a combination of upper, lower, and a number.
    return password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[0-9]'));
  }

  Widget reservation() {
    return Dialog(
      child: SizedBox(
        width: deviceSize.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Reservations')
                            .where('status', isEqualTo: 'Pending')
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            print(snapshot.error);
                            return const Center(child: Text('Error'));
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 50),
                              child: Center(
                                  child: CircularProgressIndicator(
                                color: Colors.black,
                              )),
                            );
                          }

                          final data = snapshot.requireData;
                          return Expanded(
                            child: SizedBox(
                              child: ListView.builder(
                                itemCount: data.docs.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      top: 10,
                                      bottom: 10,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.calendar_month_outlined,
                                          size: 30,
                                        ),
                                        const SizedBox(
                                          width: 15,
                                        ),
                                        TextBold(
                                            text: data.docs[index]['name'],
                                            fontSize: 16,
                                            color: Colors.black),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        TextRegular(
                                            text:
                                                '${data.docs[index]['date']} \n${data.docs[index]['time']}',
                                            // data.docs[index]['date'] +
                                            //     ' ' +
                                            //     data.docs[index]['time'],
                                            fontSize: 14,
                                            color: Colors.black),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        IconButton(
                                          onPressed: () async {
                                            await FirebaseFirestore.instance
                                                .collection('Reservations')
                                                .doc(data.docs[index].id)
                                                .update({'status': 'Accepted'});
                                          },
                                          icon: const Icon(
                                            Icons.check,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        TextButton(
                                            onPressed: () async {
                                              await FirebaseFirestore.instance
                                                  .collection('Reservations')
                                                  .doc(data.docs[index].id)
                                                  .delete();
                                            },
                                            child: const Text('Decline'))
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget announcements() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          height: 20,
        ),
        TextFieldWidget(
            maxLine: 10,
            height: 200,
            label: 'Description of Announcement',
            controller: descController),
        const SizedBox(
          height: 20,
        ),
        ButtonWidget(
          color: Colors.blue,
          label: 'Save',
          onPressed: () {
            showToast('Announcement added succesfully!');
            addAnnouncement(descController.text);
            // addAnnouncement('', nameController.text, descController.text);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
