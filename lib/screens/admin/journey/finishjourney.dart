// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'package:bus_uni2/widget/float_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:bus_uni2/widget/app_bar.dart';
import 'package:bus_uni2/widget/gradient.dart';

class FinishJourney extends StatefulWidget {
  const FinishJourney({super.key});

  @override
  State<FinishJourney> createState() => _FinishJourneyState();
}

class _FinishJourneyState extends State<FinishJourney> {
  List<int> busPlace = [];

  int? busNumber;
  bool isUploading = false;
  late Stream<List<DocumentSnapshot>> ratingsStream;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  _uploadData() {
    setState(
      () {
        isUploading = true;
      },
    );
    ratingsStream = FirebaseFirestore.instance
        .collection('buses')
        .snapshots()
        .map((snapshot) => snapshot.docs);
    setState(
      () {
        isUploading = false;
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _uploadData();
    viewBusNumbers(); // استدعاء دالة لجلب أرقام الباصات عند بدء التطبيق
  }

  finishJouney() async {
    final valid = _formKey.currentState!.validate();
    if (!valid) {
      return;
    }
    try {
      setState(() {
        isUploading = true;
      });

      DocumentReference busReference =
          FirebaseFirestore.instance.collection('journey').doc('$busNumber');
      await busReference.delete();

      DocumentReference busReference3 =
          FirebaseFirestore.instance.collection('buses').doc('$busNumber');
      await busReference3.set({
        'busPlaceArabic': '',
        'busPlaceEnglish': '',
      }, SetOptions(merge: true));

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('sucessfully'.tr()),
            content: Text('message_finish_journey'.tr()),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).pop();
                },
                child: Text('done_button'.tr()),
              ),
            ],
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        isUploading = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('error'.tr()),
            content: Text(e.message ?? 'Authentication failed'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  setState(() {
                    isUploading = false;
                  });
                  Navigator.of(context).pop();
                },
                child: Text('done_button'.tr()),
              ),
            ],
          );
        },
      );
    }
  }

  void viewBusNumbers() async {
    QuerySnapshot placeSnapshot =
        await FirebaseFirestore.instance.collection('journey').get();

    setState(() {
      busPlace =
          placeSnapshot.docs.map((doc) => doc['busNumber'] as int).toList();
    });
    busPlace.sort();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StyleAppBar(
        title: 'finish_journey'.tr(),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: StyleGradient(),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(25.w),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/iu-logo-jordan.png',
                    width: 200.w,
                    height: 200.h,
                  ),
                  SizedBox(height: 20.h),
                  Padding(
                    padding: EdgeInsets.all(25.w),
                    child: SizedBox(
                      width: 800.w,
                      height: 300.h,
                      child: Padding(
                        padding: EdgeInsets.all(25.w),
                        child: Form(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('bus_number'.tr()),
                              DropdownButtonFormField<int>(
                                validator: (value) {
                                  if (value == null) {
                                    return 'busNumber_message'.tr();
                                  }
                                  return null;
                                },
                                value: busNumber,
                                items: busPlace.map((int busNumber) {
                                  return DropdownMenuItem<int>(
                                    alignment: AlignmentDirectional.center,
                                    value: busNumber,
                                    child: Text(
                                      '$busNumber',
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    busNumber = newValue;
                                  });
                                },
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                  labelStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25.sp,
                                  ),
                                  hintText: 'select_bus_number'.tr(),
                                  fillColor: Colors.grey[100],
                                  filled: true,
                                  alignLabelWithHint: true,
                                  floatingLabelAlignment:
                                      FloatingLabelAlignment.center,
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 1.0.w,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 5.0.w,
                                    horizontal: 20.h,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blue,
                                      width: 2.5.w,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0.r),
                                  ),
                                ),
                              ),
                              SizedBox(height: 35.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (isUploading)
                    const CircularProgressIndicator(
                      color: Color.fromARGB(255, 0, 14, 67),
                    ),
                  if (!isUploading)
                    SizedBox(
                      width: 200.w,
                      height: 50.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 0, 14, 67),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(15.r),
                            ),
                          ),
                        ),
                        onPressed: finishJouney,
                        child: Text(
                          'finish_journey'.tr(),
                          style: TextStyle(
                            fontSize: 20.sp,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: const MyFloatingActionButton(),
    );
  }
}
