// ignore_for_file: use_build_context_synchronously

import 'package:bus_uni2/widget/float_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:bus_uni2/widget/app_bar.dart';
import 'package:bus_uni2/widget/gradient.dart';

class UpdatePlace extends StatefulWidget {
  const UpdatePlace({super.key});

  @override
  State<UpdatePlace> createState() => _UpdatePlaceState();
}

class _UpdatePlaceState extends State<UpdatePlace> {
  bool isUploading = false;
  String? selectedBusPlace;
  String? busPlace;
  List<String> _busPlace = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _arabicPlaceController = TextEditingController();
  final TextEditingController _englishPlaceController = TextEditingController();

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

  Future<void> fetchPlaceDetails(String selectedPlace) async {
    QuerySnapshot placeSnapshot = await FirebaseFirestore.instance
        .collection('itinerary')
        .where(
            Localizations.localeOf(context).languageCode == 'en'
                ? 'PlaceEnglish'
                : 'PlaceArabic',
            isEqualTo: selectedPlace)
        .get();

    if (placeSnapshot.docs.isNotEmpty) {
      var placeData = placeSnapshot.docs.first.data() as Map<String, dynamic>;

      setState(() {
        _arabicPlaceController.text = placeData['PlaceArabic'] ?? '';
        _englishPlaceController.text = placeData['PlaceEnglish'] ?? '';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    viewBusPlace();
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
            .collection('itinerary')
            .where('PlaceEnglish', isEqualTo: selectedBusPlace)
            .get();
        for (var doc in busSnapshot.docs) {
          await doc.reference.set({
            'PlaceArabic': _arabicPlaceController.text.trim(),
            'PlaceEnglish': _englishPlaceController.text.trim(),
          }, SetOptions(merge: true));
        }
      } else {
        QuerySnapshot busSnapshot = await FirebaseFirestore.instance
            .collection('itinerary')
            .where('PlaceArabic', isEqualTo: selectedBusPlace)
            .get();
        for (var doc in busSnapshot.docs) {
          await doc.reference.set({
            'PlaceArabic': _arabicPlaceController.text.trim(),
            'PlaceEnglish': _englishPlaceController.text.trim(),
          }, SetOptions(merge: true));
        }
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('sucessfully'.tr()),
            content: Text('message_update_place'.tr()),
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
        title: 'update_place'.tr(),
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
                              TextFormField(
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  labelText: 'place_arabic'.tr(),
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
                                controller: _arabicPlaceController,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().length < 3) {
                                    return 'arabicPlace_message'.tr();
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10.h),
                              TextFormField(
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  labelText: 'place_english'.tr(),
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
                                controller: _englishPlaceController,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().length < 3) {
                                    return 'englishPlace_message'.tr();
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
