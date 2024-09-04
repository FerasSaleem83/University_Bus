// ignore_for_file: use_build_context_synchronously

import 'package:bus_uni2/widget/float_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:bus_uni2/widget/app_bar.dart';
import 'package:bus_uni2/widget/gradient.dart';

class UpdateComplaint extends StatefulWidget {
  const UpdateComplaint({super.key});

  @override
  State<UpdateComplaint> createState() => _UpdateComplaintState();
}

class _UpdateComplaintState extends State<UpdateComplaint> {
  bool isUploading = false;
  String? selectedComplaint;
  String? complaint;
  List<String> _complaint = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _arabicComplaintController =
      TextEditingController();
  final TextEditingController _englishComplaintController =
      TextEditingController();

  void viewComplaint() async {
    QuerySnapshot complaintSnapshot =
        await FirebaseFirestore.instance.collection('selectComplaint').get();

    setState(() {
      if (Localizations.localeOf(context).languageCode == 'en') {
        _complaint = complaintSnapshot.docs
            .map((doc) => doc['ComplaintEnglish'] as String?)
            .where((place) => place != null && place.isNotEmpty)
            .cast<String>()
            .toList();
      } else {
        _complaint = complaintSnapshot.docs
            .map((doc) => doc['ComplaintArabic'] as String?)
            .where((place) => place != null && place.isNotEmpty)
            .cast<String>()
            .toList();
      }
      _complaint.sort();
    });

    if (_complaint.isEmpty) {
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

  Future<void> fetchPlaceDetails(String selectedPlace) async {
    QuerySnapshot placeSnapshot = await FirebaseFirestore.instance
        .collection('selectComplaint')
        .where(
            Localizations.localeOf(context).languageCode == 'en'
                ? 'ComplaintEnglish'
                : 'ComplaintArabic',
            isEqualTo: selectedPlace)
        .get();

    if (placeSnapshot.docs.isNotEmpty) {
      var placeData = placeSnapshot.docs.first.data() as Map<String, dynamic>;

      setState(() {
        _arabicComplaintController.text = placeData['ComplaintArabic'] ?? '';
        _englishComplaintController.text = placeData['ComplaintEnglish'] ?? '';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    viewComplaint();
  }

  updatePlace() async {
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
            .where('ComplaintEnglish', isEqualTo: selectedComplaint)
            .get();
        for (var doc in busSnapshot.docs) {
          await doc.reference.set({
            'ComplaintArabic': _arabicComplaintController.text.trim(),
            'ComplaintEnglish': _englishComplaintController.text.trim(),
          }, SetOptions(merge: true));
        }
      } else {
        QuerySnapshot busSnapshot = await FirebaseFirestore.instance
            .collection('selectComplaint')
            .where('ComplaintArabic', isEqualTo: selectedComplaint)
            .get();
        for (var doc in busSnapshot.docs) {
          await doc.reference.set({
            'ComplaintArabic': _arabicComplaintController.text.trim(),
            'ComplaintEnglish': _englishComplaintController.text.trim(),
          }, SetOptions(merge: true));
        }
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('sucessfully'.tr()),
            content: Text('message_update_complaint'.tr()),
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
        title: 'update_complaint'.tr(),
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
                      height: 450.h,
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
                                value: selectedComplaint,
                                items: _complaint.map((String value) {
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
                                    selectedComplaint = newValue;
                                  });
                                  if (newValue != null) {
                                    fetchPlaceDetails(newValue);
                                  }
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
                              TextFormField(
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  labelText: 'Complaint_arabic'.tr(),
                                  labelStyle: TextStyle(
                                    fontSize: 25.sp,
                                    color: Colors.black,
                                  ),
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                    ),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                    ),
                                  ),
                                  border: const OutlineInputBorder(),
                                ),
                                controller: _arabicComplaintController,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().length < 3) {
                                    return 'arabicComplaint_message'.tr();
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10.h),
                              TextFormField(
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  labelText: 'Complaint_english'.tr(),
                                  labelStyle: TextStyle(
                                    fontSize: 25.sp,
                                    color: Colors.black,
                                  ),
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                    ),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                    ),
                                  ),
                                  border: const OutlineInputBorder(),
                                ),
                                controller: _englishComplaintController,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().length < 3) {
                                    return 'englishComplaint_message'.tr();
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 50.h),
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
                        onPressed: updatePlace,
                        child: Text(
                          'update'.tr(),
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
