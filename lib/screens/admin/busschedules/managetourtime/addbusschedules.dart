// ignore_for_file: use_build_context_synchronously

import 'package:bus_uni2/screens/admin/journey/place/addplace.dart';
import 'package:bus_uni2/widget/app_bar.dart';
import 'package:bus_uni2/widget/gradient.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddBusSchedule extends StatefulWidget {
  const AddBusSchedule({super.key});

  @override
  State<AddBusSchedule> createState() => _AddBusScheduleState();
}

class _AddBusScheduleState extends State<AddBusSchedule> {
  final List<String> _selectedTimes = [];
  DateTime? _selectedTime;
  bool _isUploading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<String> _busPlaceEnglish = [];
  List<String> _busPlaceArabic = [];
  String? selectedBusPlace;

  @override
  void initState() {
    super.initState();
    viewBusPlace();
  }

  void viewBusPlace() async {
    QuerySnapshot placeSnapshot =
        await FirebaseFirestore.instance.collection('itinerary').get();

    setState(() {
      if (Localizations.localeOf(context).languageCode == 'en') {
        _busPlaceEnglish = placeSnapshot.docs
            .map((doc) => doc['PlaceEnglish'] as String?)
            .where((place) => place != null && place.isNotEmpty)
            .cast<String>()
            .toList();
        _busPlaceArabic = placeSnapshot.docs
            .map((doc) => doc['PlaceArabic'] as String?)
            .where((place) => place != null && place.isNotEmpty)
            .cast<String>()
            .toList();
      } else {
        _busPlaceArabic = placeSnapshot.docs
            .map((doc) => doc['PlaceArabic'] as String?)
            .where((place) => place != null && place.isNotEmpty)
            .cast<String>()
            .toList();
        _busPlaceEnglish = placeSnapshot.docs
            .map((doc) => doc['PlaceEnglish'] as String?)
            .where((place) => place != null && place.isNotEmpty)
            .cast<String>()
            .toList();
      }
      _busPlaceEnglish.sort();
      _busPlaceArabic.sort();
    });

    if (_busPlaceEnglish.isEmpty || _busPlaceArabic.isEmpty) {
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

  Future<String?> getPlaceEnglishTranslation(String selectplace) async {
    if (Localizations.localeOf(context).languageCode == 'en') {
      QuerySnapshot placeSnapshot = await FirebaseFirestore.instance
          .collection('itinerary')
          .where('PlaceEnglish', isEqualTo: selectplace)
          .get();

      if (placeSnapshot.docs.isNotEmpty) {
        return placeSnapshot.docs.first['PlaceArabic'] as String?;
      }
      return null;
    } else {
      QuerySnapshot placeSnapshot = await FirebaseFirestore.instance
          .collection('itinerary')
          .where('PlaceArabic', isEqualTo: selectplace)
          .get();

      if (placeSnapshot.docs.isNotEmpty) {
        return placeSnapshot.docs.first['PlaceEnglish'] as String?;
      }
      return null;
    }
  }

  // void _addSchedules() async {
  //   final valid = _formKey.currentState!.validate();
  //   if (!valid) {
  //     return;
  //   }
  //   try {
  //     setState(() {
  //       _isUploading = true;
  //     });

  //     // جلب النصوص باللغة الإنجليزية والعربية بغض النظر عن لغة الواجهة
  //     String? placeEnglish;
  //     String? placeArabic;

  //     if (Localizations.localeOf(context).languageCode == 'en') {
  //       placeEnglish = selectedBusPlace;
  //       placeArabic = await getPlaceEnglishTranslation(selectedBusPlace!);
  //     } else {
  //       placeArabic = selectedBusPlace;
  //       placeEnglish = await getPlaceEnglishTranslation(selectedBusPlace!);
  //     }

  //     // التأكد من عدم وجود null في النصوص
  //     if (placeEnglish != null && placeArabic != null) {
  //       DocumentReference busReference = FirebaseFirestore.instance
  //           .collection('busesSchedules')
  //           .doc(placeEnglish); // استخدم النص الإنجليزي كمفتاح فريد

  //       await busReference.set({
  //         'busPlaceEnglish': placeEnglish,
  //         'busPlaceArabic': placeArabic,
  //         'times': _selectedTimes,
  //       }, SetOptions(merge: true));

  //       showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return AlertDialog(
  //             title: Text('sucss'.tr()),
  //             content: const Text('done done'),
  //             actions: <Widget>[
  //               TextButton(
  //                 onPressed: () {
  //                   setState(() {
  //                     _isUploading = false;
  //                   });
  //                   Navigator.of(context).pop();
  //                 },
  //                 child: Text('done_button'.tr()),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     } else {
  //       setState(() {
  //         _isUploading = false;
  //       });
  //       showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return AlertDialog(
  //             title: Text('error'.tr()),
  //             content: const Text('Could not retrieve place translations.'),
  //             actions: <Widget>[
  //               TextButton(
  //                 onPressed: () {
  //                   setState(() {
  //                     _isUploading = false;
  //                   });
  //                   Navigator.of(context).pop();
  //                 },
  //                 child: Text('done_button'.tr()),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _isUploading = false;
  //     });
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text('error'.tr()),
  //           content: Text(e.toString()),
  //           actions: <Widget>[
  //             TextButton(
  //               onPressed: () {
  //                 setState(() {
  //                   _isUploading = false;
  //                 });
  //                 Navigator.of(context).pop();
  //               },
  //               child: Text('done_button'.tr()),
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   }
  // }

  void _addSchedules() async {
    final valid = _formKey.currentState!.validate();
    if (!valid) {
      return;
    }
    try {
      setState(() {
        _isUploading = true;
      });

      // جلب النصوص باللغة الإنجليزية والعربية بغض النظر عن لغة الواجهة
      String? placeEnglish;
      String? placeArabic;

      if (Localizations.localeOf(context).languageCode == 'en') {
        placeEnglish = selectedBusPlace;
        placeArabic = await getPlaceEnglishTranslation(selectedBusPlace!);
      } else {
        placeArabic = selectedBusPlace;
        placeEnglish = await getPlaceEnglishTranslation(selectedBusPlace!);
      }

      // التأكد من عدم وجود null في النصوص
      if (placeEnglish != null && placeArabic != null) {
        DocumentReference busReference = FirebaseFirestore.instance
            .collection('busesSchedules')
            .doc(placeEnglish); // استخدم النص الإنجليزي كمفتاح فريد

        // جلب القيم القديمة من المستند
        DocumentSnapshot snapshot = await busReference.get();
        List<String> existingTimes = [];

        if (snapshot.exists && snapshot.data() != null) {
          existingTimes = List<String>.from(snapshot['times'] ?? []);
        }

        // دمج القيم القديمة مع القيم الجديدة
        List<String> updatedTimes = [...existingTimes, ..._selectedTimes];

        // التأكد من عدم وجود تكرار في القيم بعد الدمج
        updatedTimes = updatedTimes.toSet().toList();

        // حفظ القيم المدمجة في المستند
        await busReference.set({
          'busPlaceEnglish': placeEnglish,
          'busPlaceArabic': placeArabic,
          'times': updatedTimes,
        }, SetOptions(merge: true));

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('sucessfully'.tr()),
              content: Text('message_add_place'.tr()),
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
      } else {
        setState(() {
          _isUploading = false;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('error'.tr()),
              content: Text('error'.tr()),
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
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('error'.tr()),
            content: Text(e.toString()),
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
    return Scaffold(
      appBar: StyleAppBar(title: 'add_new_journey'.tr()),
      body: Container(
        decoration: BoxDecoration(
          gradient: StyleGradient(),
        ),
        child: Padding(
          padding: EdgeInsets.all(25.w.h),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        validator: (value) {
                          if (value == null) {
                            return 'itinerary_message'.tr();
                          }
                          return null;
                        },
                        value: selectedBusPlace,
                        items:
                            Localizations.localeOf(context).languageCode == 'en'
                                ? _busPlaceEnglish.map((String value) {
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
                                  }).toList()
                                : _busPlaceArabic.map((String value) {
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
                          floatingLabelAlignment: FloatingLabelAlignment.center,
                          floatingLabelBehavior: FloatingLabelBehavior.always,
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
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddPlace(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 0, 14, 67),
                        ),
                        child: Text(
                          'add_place'.tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25.sp,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 50.h),
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: FormBuilderDateTimePicker(
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                        validator: (value) {
                          if (value == null) {
                            return 'license_start_time_message'.tr();
                          }
                          return null;
                        },
                        name: 'license_start_time'.tr(),
                        inputType: InputType.time,
                        locale: const Locale('en', 'US'),
                        onChanged: (value) {
                          setState(() {
                            _selectedTime = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25.sp,
                            color: Colors.black,
                          ),
                          labelText: 'license_start_time'.tr(),
                          hintText: 'license_start_time'.tr(),
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25.sp,
                            color: Colors.black,
                          ),
                          alignLabelWithHint: true,
                          floatingLabelAlignment: FloatingLabelAlignment.center,
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          enabledBorder: UnderlineInputBorder(
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
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (_selectedTime != null) {
                          String formattedTime =
                              DateFormat('hh:mm a').format(_selectedTime!);
                          setState(() {
                            _selectedTimes.add(formattedTime);
                            _selectedTimes.sort((a, b) {
                              DateTime timeA = DateFormat('hh:mm a').parse(a);
                              DateTime timeB = DateFormat('hh:mm a').parse(b);
                              return timeA.compareTo(timeB);
                            });
                          });
                        }
                      },
                      icon: const Icon(
                        Icons.add_circle,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30.h),
                Wrap(
                  spacing: 8.0.w,
                  children: _selectedTimes.map((time) {
                    return Chip(
                      label: Text(
                        time,
                        style: const TextStyle(color: Colors.white),
                      ),
                      deleteIcon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                      onDeleted: () {
                        setState(() {
                          _selectedTimes.remove(time);
                        });
                      },
                      backgroundColor: Colors.blue,
                    );
                  }).toList(),
                ),
                SizedBox(height: 30.h),
                if (_isUploading)
                  const CircularProgressIndicator(
                    color: Color.fromARGB(255, 0, 14, 67),
                  ),
                if (!_isUploading)
                  SizedBox(
                    width: 250.w,
                    child: ElevatedButton(
                      onPressed: _addSchedules,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 0, 14, 67),
                      ),
                      child: Text(
                        'add_timer'.tr(),
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
    );
  }
}
