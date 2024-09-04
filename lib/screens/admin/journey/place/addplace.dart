// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:bus_uni2/widget/app_bar.dart';
import 'package:bus_uni2/widget/float_button.dart';
import 'package:bus_uni2/widget/gradient.dart';

class AddPlace extends StatefulWidget {
  const AddPlace({super.key});

  @override
  State<AddPlace> createState() => _AddPlaceState();
}

class _AddPlaceState extends State<AddPlace> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _arabicPlaceController = TextEditingController();
  final TextEditingController _englishPlaceController = TextEditingController();

  bool _isUploading = false;

  void _addPlace() async {
    final valid = _formKey.currentState!.validate();
    if (!valid) {
      return;
    }

    try {
      setState(() {
        _isUploading = true;
      });

      await FirebaseFirestore.instance.collection('itinerary').doc().set({
        'PlaceArabic': _arabicPlaceController.text.trim(),
        'PlaceEnglish': _englishPlaceController.text.trim(),
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('sucessfully'.tr()),
            content: Text('message_add_place'.tr()),
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
      setState(() {
        _isUploading = false;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isUploading = false;
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
                    _isUploading = false;
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
    return StreamBuilder<Object>(
      stream: null,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: StyleAppBar(title: 'add_place'.tr()),
          body: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: StyleGradient(),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(25.w),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/iu-logo-jordan.png',
                              width: 200.w,
                              height: 200.h,
                            ),
                            SizedBox(height: 120.h),
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
                                if (value == null || value.trim().length < 3) {
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
                                if (value == null || value.trim().length < 3) {
                                  return 'englishPlace_message'.tr();
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 50.h),
                            if (_isUploading)
                              const CircularProgressIndicator(
                                color: Color.fromARGB(255, 0, 14, 67),
                              ),
                            if (!_isUploading)
                              SizedBox(
                                width: 250.w,
                                child: ElevatedButton(
                                  onPressed: _addPlace,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 0, 14, 67),
                                  ),
                                  child: Text(
                                    'add_place'.tr(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 25.sp,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: const MyFloatingActionButton(),
        );
      },
    );
  }
}
