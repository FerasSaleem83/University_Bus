// ignore_for_file: use_build_context_synchronously

import 'package:bus_uni2/widget/float_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:bus_uni2/widget/app_bar.dart';
import 'package:bus_uni2/widget/gradient.dart';

class DeleteComplaint extends StatefulWidget {
  const DeleteComplaint({super.key});

  @override
  State<DeleteComplaint> createState() => _DeleteComplaintState();
}

class _DeleteComplaintState extends State<DeleteComplaint> {
  bool isUploading = false;
  String? selectedBusComplaint;
  String? busComplaint;
  List<String> _busComplaint = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void viewBusComplaint() async {
    QuerySnapshot complaintSnapshot =
        await FirebaseFirestore.instance.collection('selectComplaint').get();

    setState(() {
      if (Localizations.localeOf(context).languageCode == 'en') {
        _busComplaint = complaintSnapshot.docs
            .map((doc) => doc['ComplaintEnglish'] as String?)
            .where((complaint) => complaint != null && complaint.isNotEmpty)
            .cast<String>()
            .toList();
      } else {
        _busComplaint = complaintSnapshot.docs
            .map((doc) => doc['ComplaintArabic'] as String?)
            .where((complaint) => complaint != null && complaint.isNotEmpty)
            .cast<String>()
            .toList();
      }
      _busComplaint.sort();
    });

    if (_busComplaint.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('error'.tr()),
            content: Text('no_complaint_available'.tr()),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).pop(); // Close the current page
                },
                child: Text('done_button'.tr()),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    viewBusComplaint();
  }

  deleteComplaint() async {
    final valid = _formKey.currentState!.validate();
    if (!valid) {
      return;
    }
    try {
      setState(() {
        isUploading = true;
      });
      if (Localizations.localeOf(context).languageCode == 'en') {
        QuerySnapshot busSnapshot = await FirebaseFirestore.instance
            .collection('selectComplaint')
            .where('ComplaintEnglish', isEqualTo: selectedBusComplaint)
            .get();
        for (var doc in busSnapshot.docs) {
          await doc.reference.delete();
        }
      } else {
        QuerySnapshot busSnapshot = await FirebaseFirestore.instance
            .collection('selectComplaint')
            .where('ComplaintArabic', isEqualTo: selectedBusComplaint)
            .get();
        for (var doc in busSnapshot.docs) {
          await doc.reference.delete();
        }
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('sucessfully'.tr()),
            content: Text('message_delete_Complaint'.tr()),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StyleAppBar(
        title: 'delete_complaint'.tr(),
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
                              Text('complaints'.tr()),
                              DropdownButtonFormField<String>(
                                validator: (value) {
                                  if (value == null) {
                                    return 'complaints_message'.tr();
                                  }
                                  return null;
                                },
                                value: selectedBusComplaint,
                                items: _busComplaint.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value.toString(),
                                      style: TextStyle(
                                        fontSize: 25.sp,
                                        color: Colors.black,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedBusComplaint = newValue;
                                  });
                                },
                                style: TextStyle(
                                  fontSize: 25.sp,
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                  labelStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25.sp,
                                  ),
                                  hintText: 'complaints'.tr(),
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
                                    borderRadius: BorderRadius.circular(10.0.r),
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
                              SizedBox(height: 10.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h),
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
                        onPressed: deleteComplaint,
                        child: Text(
                          'delete'.tr(),
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
