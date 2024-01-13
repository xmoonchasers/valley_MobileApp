import 'dart:convert';
import 'dart:io';

import 'package:cell_calendar/cell_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:valley_students_and_teachers/utils/media_query.dart';
import 'package:valley_students_and_teachers/utils/routes.dart';
import 'package:valley_students_and_teachers/widgets/add_event_dialog.dart';
import 'package:valley_students_and_teachers/widgets/event_dialog.dart';
import 'package:valley_students_and_teachers/widgets/schedule_dialog.dart';
import 'package:valley_students_and_teachers/widgets/text_widget.dart';
import 'package:valley_students_and_teachers/widgets/textfield_widget.dart';
import 'package:valley_students_and_teachers/widgets/toast_widget.dart';
import 'package:http/http.dart' as http;

class TeachersHomeScreen extends StatefulWidget {
  const TeachersHomeScreen({super.key});

  @override
  State<TeachersHomeScreen> createState() => _TeachersHomeScreenState();
}

class _TeachersHomeScreenState extends State<TeachersHomeScreen> {
  @override
  void initState() {
    super.initState();
    getEvents();
  }

  List<CalendarEvent> events = [];
  bool hasLoaded = false;
  getEvents() async {
    await FirebaseFirestore.instance
        .collection('Events')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        events.add(CalendarEvent(
            eventName: doc['name'],
            eventDate: doc['date'].toDate(),
            eventTextStyle: const TextStyle(fontFamily: 'Bold')));
      }
      setState(() {
        hasLoaded = true;
      });
    });
  }

  bool isSchedule = false;
  bool isAvailability = false;
  bool isworkLoad = false;
  bool isConsultation = true;

  final Stream<DocumentSnapshot> userData = FirebaseFirestore.instance
      .collection('Users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .snapshots();
  String myName = '';

  String myId = '';

  String myRole = '';

  final emailController = TextEditingController();
  final nameController = TextEditingController();

  DocumentReference userReference = FirebaseFirestore.instance
      .collection('Users')
      .doc(FirebaseAuth.instance.currentUser!.uid);

// Example function to update user data
  Future<void> updateUser(var img) async {
    try {
      // Use the update method to update specific fields in the document
      await userReference.update({
        'imageUrl': img
        // Add other fields as needed
      });

      print('User data updated successfully');
    } catch (e) {
      print('Error updating user data: $e');
    }
  }

  PlatformFile? pickedFile;

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });

    if (pickedFile != null) {
      _uploadImg();
    }
  }

  var imgUrl = '';
  Future<void> _uploadImg() async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/dt66q7ysr/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = 'gkp7yejf'
      ..files.add(await http.MultipartFile.fromPath('file', pickedFile!.path!));
    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonMap = jsonDecode(responseString);

      setState(() {
        final url = jsonMap['url'];
        imgUrl = url;
      });
      print(imgUrl);
      if (imgUrl != '') {
        updateUser(imgUrl);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isSchedule
          ? FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const AddEventDialog();
                  },
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            StreamBuilder<DocumentSnapshot>(
                stream: userData,
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox();
                  } else if (snapshot.hasError) {
                    return const SizedBox();
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const SizedBox();
                  }
                  dynamic data = snapshot.data;
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    myName = data['name'];

                    myRole = data['role'];
                    myId = data.id;
                    // membersId.add(data.id);
                  });
                  return Container(
                    height: double.infinity,
                    width: deviceSize.width,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(143, 0, 0, 0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.30,
                            ),
                            TextBold(
                              text: 'Welcome!',
                              fontSize: 32,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.14,
                            ),
                            InkWell(
                              onTap: () async {
                                await FirebaseAuth.instance.signOut();
                                if (!context.mounted) return;
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  Routes().landingscreen,
                                  (route) => false,
                                );
                              },
                              child: const Icon(
                                Icons.logout,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.05,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        InkWell(
                            onTap: () {
                              // updateUser();
                              selectFile();
                              // print(data['imageUrl']);
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              radius: 90,
                              child: Center(
                                child: Stack(
                                  children: [
                                    Container(
                                      child: data['imageUrl'].isNotEmpty
                                          ? CircleAvatar(
                                              radius: 90,
                                              backgroundImage: NetworkImage(
                                                  data['imageUrl']),
                                            )
                                          : pickedFile != null
                                              ? ClipOval(
                                                  child: Image.file(
                                                  File(pickedFile!.path!),
                                                  width:
                                                      200.0, // Adjust the width as needed
                                                  height:
                                                      200.0, // Adjust the height as needed
                                                  fit: BoxFit.cover,
                                                ))
                                              : Image.asset(
                                                  'assets/images/avatar.png',
                                                  height: 200,
                                                ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 20.0, bottom: 15),
                                      child: Align(
                                          alignment: Alignment.bottomRight,
                                          child: Icon(
                                            Icons.camera_alt,
                                            size: 50,
                                            color: Colors.grey.withOpacity(0.8),
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                        const SizedBox(
                          height: 20,
                        ),
                        TextBold(
                          text: data['name'],
                          fontSize: 24,
                          color: Colors.white,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextBold(
                          text: data['idNumber'],
                          fontSize: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              nameController.text = data['name'];
                              emailController.text = data['idNumber'];
                            });
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: TextBold(
                                      text: 'Edit Profile',
                                      fontSize: 12,
                                      color: Colors.black),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextFieldWidget(
                                        label: 'Name',
                                        controller: nameController,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      TextFieldWidget(
                                        label: 'Email',
                                        controller: emailController,
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: TextBold(
                                          text: 'Close',
                                          fontSize: 14,
                                          color: Colors.black),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        await FirebaseFirestore.instance
                                            .collection('Users')
                                            .doc(data.id)
                                            .update({
                                          'name': nameController.text,
                                          'idNumber': emailController.text,
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: TextBold(
                                          text: 'Save',
                                          fontSize: 14,
                                          color: Colors.black),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: TextBold(
                            text: 'Edit Profile',
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isAvailability = false;
                              isSchedule = false;
                              isConsultation = true;
                            });
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return consultation();
                                });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.email_outlined,
                                color:
                                    isConsultation ? Colors.white : Colors.grey,
                                size: 48,
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              TextBold(
                                text: 'Consultation',
                                fontSize: 24,
                                color:
                                    isConsultation ? Colors.white : Colors.grey,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 75, right: 75),
                          child: Divider(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isAvailability = false;
                              isSchedule = true;
                              isworkLoad = false;
                              isConsultation = false;
                            });
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return workload();
                                });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_month_outlined,
                                color: isSchedule ? Colors.white : Colors.grey,
                                size: 48,
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              TextBold(
                                text: 'Schedule',
                                fontSize: 24,
                                color: isSchedule ? Colors.white : Colors.grey,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 75, right: 75),
                          child: Divider(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isAvailability = true;
                              isSchedule = false;
                              isworkLoad = false;
                              isConsultation = false;
                            });
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return availability();
                                });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.schedule,
                                color:
                                    isAvailability ? Colors.white : Colors.grey,
                                size: 48,
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              TextBold(
                                text: 'Availability',
                                fontSize: 24,
                                color:
                                    isAvailability ? Colors.white : Colors.grey,
                              ),
                            ],
                          ),
                        ),
                        // const SizedBox(
                        //   height: 20,
                        // ),
                        // const Padding(
                        //   padding: EdgeInsets.only(left: 75, right: 75),
                        //   child: Divider(
                        //     color: Colors.white,
                        //   ),
                        // ),
                        // const SizedBox(
                        //   height: 20,
                        // ),
                        // GestureDetector(
                        //   onTap: () {
                        //     setState(() {
                        //       isAvailability = false;
                        //       isSchedule = false;
                        //       isworkLoad = true;
                        //     });
                        //   },
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.center,
                        //     children: [
                        //       Icon(
                        //         Icons.work,
                        //         color: isworkLoad ? Colors.white : Colors.grey,
                        //         size: 48,
                        //       ),
                        //       const SizedBox(
                        //         width: 20,
                        //       ),
                        //       TextBold(
                        //         text: 'Workload',
                        //         fontSize: 24,
                        //         color: isworkLoad ? Colors.white : Colors.grey,
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  );
                }),
            //isSchedule ? workload() : availability(),
          ],
        ),
      ),
    );
  }

  Widget consultation() {
    return AlertDialog(
      title: Container(
        width: deviceSize.width,
        color: Colors.transparent,
        height: deviceSize.height * .6,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Chats')
                    .where('membersId',
                        arrayContains: FirebaseAuth.instance.currentUser!.uid)
                    .where('creator',
                        isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    print(snapshot.error);
                    return const Center(child: Text('Error'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Center(
                          child: CircularProgressIndicator(
                        color: Colors.black,
                      )),
                    );
                  }

                  final data = snapshot.requireData;
                  return Align(
                      alignment: Alignment.topRight,
                      child: PopupMenuButton(
                        icon: Badge(
                          backgroundColor: Colors.red,
                          label: TextRegular(
                              text: data.docs.length.toString(),
                              fontSize: 14,
                              color: Colors.white),
                          child: const Icon(
                            Icons.notifications,
                            color: Colors.grey,
                            size: 32,
                          ),
                        ),
                        itemBuilder: (context) {
                          return [
                            for (int i = 0; i < data.docs.length; i++)
                              PopupMenuItem(
                                  onTap: () {
                                    chatroomDialog(data.docs[i].id);
                                    chatroomDialog(data.docs[i].id);
                                  },
                                  child: ListTile(
                                    leading: const Icon(
                                      Icons.notifications,
                                      color: Colors.black,
                                    ),
                                    title: TextBold(
                                        text: 'You have new message ',
                                        fontSize: 16,
                                        color: Colors.black),
                                    subtitle: TextRegular(
                                        text: DateFormat.yMMMd()
                                            .add_jm()
                                            .format(data.docs[i]['dateTime']
                                                .toDate()),
                                        fontSize: 12,
                                        color: Colors.black),
                                  ))
                          ];
                        },
                      ));
                }),
            const SizedBox(
              height: 10,
            ),
            Container(
              height: deviceSize.height * .52,
              width: deviceSize.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 25,
                  ),
                  TextBold(
                      text: 'MESSAGES ',
                      fontSize: 18,
                      color: const Color.fromARGB(255, 0, 0, 0)),
                  // Align(
                  //   alignment: Alignment.topRight,
                  //   child: TextButton.icon(
                  //     onPressed: () {
                  //        createGroupDialog();
                  //     },
                  //     icon: const Icon(
                  //       Icons.add,
                  //       color: Colors.black,
                  //     ),
                  //     label: TextBold(
                  //       text: 'Create group',
                  //       fontSize: 12,
                  //       color: Colors.black,
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(
                    height: 10,
                  ),
                  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Chats')
                          .where('membersId',
                              arrayContains:
                                  FirebaseAuth.instance.currentUser!.uid)
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
                            padding: EdgeInsets.only(top: 30),
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
                                String date = DateFormat.yMMMd()
                                    .add_jm()
                                    .format(
                                        data.docs[index]['dateTime'].toDate());
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      top: 5, bottom: 5, left: 0, right: 0),
                                  child: GestureDetector(
                                    onTap: () {
                                      chatroomDialog(data.docs[index].id);
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Icon(
                                          Icons.chat,
                                          size: 20,
                                        ),
                                        const SizedBox(
                                          width: 6,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                                width: deviceSize.width * .38,
                                                child: Text(
                                                  (data.docs[index].data()
                                                              as Map)
                                                          .containsKey('name')
                                                      ? data.docs[index]['name']
                                                      : "Consulation ${data.docs[index].id}",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                                )),
                                            Text(
                                              '${date.substring(0, 12)} \n${date.substring(12)}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.grey,
                                                  fontSize: 9,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          width: 15,
                                        ),

                                        // const SizedBox(
                                        //   width: 5,
                                        // ),
                                        IconButton(
                                          onPressed: () async {
                                            await FirebaseFirestore.instance
                                                .collection('Chats')
                                                .doc(data.docs[index].id)
                                                .delete();
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget schedule() {
    return AlertDialog(
      title: SizedBox(
        width: 800,
        height: deviceSize.height * .6,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Notif')
                    .where('userId',
                        arrayContains: FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    print(snapshot.error);
                    return const Center(child: Text('Error'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Center(
                          child: CircularProgressIndicator(
                        color: Colors.black,
                      )),
                    );
                  }

                  final data = snapshot.requireData;
                  return Align(
                      alignment: Alignment.topRight,
                      child: PopupMenuButton(
                        icon: Badge(
                          backgroundColor: Colors.red,
                          label: TextRegular(
                              text: data.docs.length.toString(),
                              fontSize: 14,
                              color: Colors.white),
                          child: const Icon(
                            Icons.notifications,
                            color: Colors.black,
                            size: 32,
                          ),
                        ),
                        itemBuilder: (context) {
                          return [
                            for (int i = 0; i < data.docs.length; i++)
                              PopupMenuItem(
                                  onTap: () {},
                                  child: ListTile(
                                    leading: const Icon(
                                      Icons.notifications,
                                      color: Colors.black,
                                    ),
                                    title: TextBold(
                                        text: data.docs[i]['type'],
                                        fontSize: 16,
                                        color: Colors.black),
                                    subtitle: TextRegular(
                                        text: DateFormat.yMMMd()
                                            .add_jm()
                                            .format(data.docs[i]['dateTime']
                                                .toDate()),
                                        fontSize: 12,
                                        color: Colors.black),
                                  ))
                          ];
                        },
                      ));
                }),
            StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Chats')
                    .where('membersId',
                        arrayContains: FirebaseAuth.instance.currentUser!.uid)
                    .where('creator',
                        isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    print(snapshot.error);
                    return const Center(child: Text('Error'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Center(
                          child: CircularProgressIndicator(
                        color: Color.fromARGB(255, 255, 250, 250),
                      )),
                    );
                  }
                  final data = snapshot.requireData;
                  return Align(
                      alignment: Alignment.topRight,
                      child: PopupMenuButton(
                        icon: Badge(
                          backgroundColor: Colors.red,
                          label: TextRegular(
                              text: data.docs.length.toString(),
                              fontSize: 14,
                              color: Colors.white),
                          child: const Icon(
                            Icons.notifications,
                            color: Colors.black,
                            size: 32,
                          ),
                        ),
                        itemBuilder: (context) {
                          return [
                            for (int i = 0; i < data.docs.length; i++)
                              PopupMenuItem(
                                  onTap: () {
                                    chatroomDialog(data.docs[i].id);
                                    chatroomDialog(data.docs[i].id);
                                  },
                                  child: ListTile(
                                    leading: const Icon(
                                      Icons.notifications,
                                      color: Colors.black,
                                    ),
                                    title: TextBold(
                                        text:
                                            'You have new message consultation',
                                        fontSize: 16,
                                        color: Colors.black),
                                    subtitle: TextRegular(
                                        text: DateFormat.yMMMd()
                                            .add_jm()
                                            .format(data.docs[i]['dateTime']
                                                .toDate()),
                                        fontSize: 12,
                                        color: Colors.black),
                                  ))
                          ];
                        },
                      ));
                }),
            const SizedBox(
              height: 20,
            ),
            TextBold(
              text: 'Schedule',
              fontSize: 32,
              color: Colors.black,
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: TextButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return const ScheduleDialog();
                            },
                          );
                        },
                        icon: const Icon(
                          Icons.add,
                          color: Colors.black,
                        ),
                        label: TextBold(
                          text: 'Add schedule',
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Schedules')
                            .where('userId',
                                isEqualTo:
                                    FirebaseAuth.instance.currentUser!.uid)
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
                                        left: 20,
                                        right: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        TextBold(
                                            text: data.docs[index]['name'],
                                            fontSize: 22,
                                            color: Colors.black),
                                        const SizedBox(
                                          width: 50,
                                        ),
                                        TextBold(
                                            text: data.docs[index]['section'],
                                            fontSize: 22,
                                            color: Colors.black),
                                        const SizedBox(
                                          width: 50,
                                        ),
                                        TextBold(
                                            text:
                                                '${data.docs[index]['day']} ${data.docs[index]['timeFrom']} - ${data.docs[index]['timeTo']}',
                                            fontSize: 22,
                                            color: Colors.black),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        })
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final availController = TextEditingController();
  Widget availability() {
    return AlertDialog(
      title: StreamBuilder<DocumentSnapshot>(
          stream: userData,
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(
                width: 800,
              );
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return const SizedBox(
                width: 800,
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                width: 800,
              );
            }
            dynamic data = snapshot.data;
            availController.text = data['avail'];
            return SizedBox(
              width: 800,
              height: deviceSize.height * .6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Chats')
                          .where('membersId',
                              arrayContains:
                                  FirebaseAuth.instance.currentUser!.uid)
                          .where('creator',
                              isNotEqualTo:
                                  FirebaseAuth.instance.currentUser!.uid)
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
                              color: Color.fromARGB(255, 255, 254, 254),
                            )),
                          );
                        }
                        final data = snapshot.requireData;
                        return Align(
                            alignment: Alignment.topRight,
                            child: PopupMenuButton(
                              icon: Badge(
                                backgroundColor: Colors.red,
                                label: TextRegular(
                                    text: data.docs.length.toString(),
                                    fontSize: 14,
                                    color: Colors.white),
                                child: const Icon(
                                  Icons.notifications,
                                  color: Colors.black,
                                  size: 32,
                                ),
                              ),
                              itemBuilder: (context) {
                                return [
                                  for (int i = 0; i < data.docs.length; i++)
                                    PopupMenuItem(
                                        onTap: () {
                                          chatroomDialog(data.docs[i].id);
                                          chatroomDialog(data.docs[i].id);
                                        },
                                        child: ListTile(
                                          leading: const Icon(
                                            Icons.notifications,
                                            color: Colors.black,
                                          ),
                                          title: TextBold(
                                              text:
                                                  'You have been added to a consultation',
                                              fontSize: 16,
                                              color: Colors.black),
                                          subtitle: TextRegular(
                                              text: DateFormat.yMMMd()
                                                  .add_jm()
                                                  .format(data.docs[i]
                                                          ['dateTime']
                                                      .toDate()),
                                              fontSize: 12,
                                              color: Colors.black),
                                        ))
                                ];
                              },
                            ));
                      }),
                  const SizedBox(
                    height: 20,
                  ),
                  TextBold(
                    text: 'Availability',
                    fontSize: 32,
                    color: Colors.black,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 50),
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
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextFieldWidget(
                                  label: '',
                                  controller: availController,
                                  height: 200,
                                  width: 400,
                                  maxLine: 5),
                            ],
                          ),
                          const Expanded(child: SizedBox()),
                          Padding(
                            padding:
                                const EdgeInsets.only(right: 20, bottom: 20),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: TextButton.icon(
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(data.id)
                                      .update({
                                    'avail': availController.text,
                                  });
                                  showToast('Saved Succesfully!');
                                },
                                icon: const Icon(
                                  Icons.save,
                                  color: Colors.black,
                                ),
                                label: TextBold(
                                  text: 'Save',
                                  fontSize: 24,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }

  final msgController = TextEditingController();
  chatroomDialog(String docId) {
    final Stream<DocumentSnapshot> chatrooms =
        FirebaseFirestore.instance.collection('Chats').doc(docId).snapshots();
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SizedBox(
            height: 500,
            width: 400,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PopupMenuButton(
                        icon: const Icon(
                          Icons.groups_2_outlined,
                          color: Colors.grey,
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: ListTile(
                              leading: const Icon(Icons.person),
                              title: TextRegular(
                                text: ' ',
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  StreamBuilder<DocumentSnapshot>(
                      stream: chatrooms,
                      builder:
                          (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return const Expanded(child: SizedBox());
                        } else if (snapshot.hasError) {
                          return const Expanded(child: SizedBox());
                        } else if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox();
                        }
                        dynamic data = snapshot.data;
                        List msgs = data['messages'];
                        return Expanded(
                          child: SizedBox(
                            child: ListView.separated(
                              itemCount: msgs.length,
                              separatorBuilder: (context, index) {
                                return const Divider();
                              },
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "${msgs[index]['name']}: ",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                        ),
                                        Text(
                                          msgs[index]['msg'],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 12),
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    )
                                  ],
                                );
                              },
                            ),
                          ),
                        );
                      }),
                  const Divider(),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: TextFormField(
                      controller: msgController,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('Chats')
                                .doc(docId)
                                .update({
                              'messages': FieldValue.arrayUnion([
                                {
                                  'name': myName,
                                  'userId':
                                      FirebaseAuth.instance.currentUser!.uid,
                                  'msg': msgController.text,
                                  'date': DateTime.now(),
                                }
                              ]),
                            });
                            msgController.clear();
                          },
                          icon: const Icon(
                            Icons.send,
                            color: Color.fromARGB(255, 80, 176, 255),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget workload() {
    return AlertDialog(
      title: SizedBox(
        width: deviceSize.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Notif')
                    .where('userId',
                        arrayContains: FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    print(snapshot.error);
                    return const Center(child: Text('Error'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Center(
                          child: CircularProgressIndicator(
                        color: Colors.black,
                      )),
                    );
                  }

                  final data = snapshot.requireData;
                  return Align(
                      alignment: Alignment.topRight,
                      child: PopupMenuButton(
                        icon: Badge(
                          backgroundColor: Colors.red,
                          label: TextRegular(
                              text: data.docs.length.toString(),
                              fontSize: 14,
                              color: Colors.white),
                          child: const Icon(
                            Icons.notifications,
                            color: Colors.grey,
                            size: 32,
                          ),
                        ),
                        itemBuilder: (context) {
                          return [
                            for (int i = 0; i < data.docs.length; i++)
                              PopupMenuItem(
                                  onTap: () {},
                                  child: ListTile(
                                    leading: const Icon(
                                      Icons.notifications,
                                      color: Colors.black,
                                    ),
                                    title: TextBold(
                                        text: data.docs[i]['type'],
                                        fontSize: 16,
                                        color: Colors.black),
                                    subtitle: TextRegular(
                                        text: DateFormat.yMMMd()
                                            .add_jm()
                                            .format(data.docs[i]['dateTime']
                                                .toDate()),
                                        fontSize: 12,
                                        color: Colors.black),
                                  ))
                          ];
                        },
                      ));
                }),
            SizedBox(
              width: deviceSize.width,
              height: 450,
              child: CellCalendar(
                events: events,
                onCellTapped: (date) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('Events')
                              .where('year', isEqualTo: date.year)
                              .where('month', isEqualTo: date.month)
                              .where('day', isEqualTo: date.day)
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              print('error');
                              return const Center(child: Text('Error'));
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 50),
                                child: Center(
                                    child: CircularProgressIndicator(
                                  color: Color.fromARGB(255, 255, 250, 250),
                                )),
                              );
                            }
                            final data = snapshot.requireData;
                            return EventDialog(
                              events: [
                                for (int i = 0; i < data.docs.length; i++)
                                  {
                                    'title': data.docs[i]['name'],
                                    'date': DateFormat.yMMMd()
                                        .add_jm()
                                        .format(data.docs[i]['date'].toDate()),
                                    'id': data.docs[i].id,
                                    'details': data.docs[i]['details'],
                                  },
                              ],
                            );
                          });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
