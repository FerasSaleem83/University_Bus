// ignore_for_file: use_build_context_synchronously

import 'package:bus_uni2/widget/float_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:bus_uni2/widget/app_bar.dart';
import 'package:bus_uni2/widget/gradient.dart';

class DeletePlace extends StatefulWidget {
  const DeletePlace({super.key});

  @override
  State<DeletePlace> createState() => _DeletePlaceState();
}

class _DeletePlaceState extends State<DeletePlace> {
  bool isUploading = false;
  String? selectedBusPlace;
  String? busPlace;
  List<String> _busPlace = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void viewBusPlace() async {
    QuerySnapshot placeSnapshot =
        await FirebaseFirestore.instance.collection('itinerary').get();

    setState(() {
      if (Localizations.localeOf(context).languageCode == 'en') {
        _busPlace = placeSnapshot.docs
            .map((doc) => doc['PlaceEnglish'] as String?)
            .where((place) => place != null && place.isNotEmpty)
            .cast<String>()
            .toList();
      } else {
        _busPlace = placeSnapshot.docs
            .map((doc) => doc['PlaceArabic'] as String?)
            .where((place) => place != null && place.isNotEmpty)
            .cast<String>()
            .toList();
      }
      _busPlace.sort();
    });

    if (_busPlace.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('error'.tr()),
            content: Text('no_place_available'.tr()),
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
    viewBusPlace();
  }

  deletePlace() async {
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
            .collection('itinerary')
            .where('PlaceEnglish', isEqualTo: selectedBusPlace)
            .get();
        for (var doc in busSnapshot.docs) {
          await doc.reference.delete();
        }
      } else {
        QuerySnapshot busSnapshot = await FirebaseFirestore.instance
            .collection('itinerary')
            .where('PlaceArabic', isEqualTo: selectedBusPlace)
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
            content: Text('message_delete_place'.tr()),
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
        title: 'delete_place'.tr(),
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
                              Text('itinerary'.tr()),
                              DropdownButtonFormField<String>(
                                validator: (value) {
                                  if (value == null) {
                                    return 'itinerary_message'.tr();
                                  }
                                  return null;
                                },
                                value: selectedBusPlace,
                                items: _busPlace.map((String value) {
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
                                    selectedBusPlace = newValue;
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
                                  hintText: 'itinerary'.tr(),
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
                        onPressed: deletePlace,
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
