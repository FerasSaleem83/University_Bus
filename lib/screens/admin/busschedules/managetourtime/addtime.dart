import 'package:bus_uni2/widget/app_bar.dart';
import 'package:bus_uni2/widget/gradient.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddTime extends StatefulWidget {
  final String placeName;
  const AddTime({super.key, required this.placeName});

  @override
  State<AddTime> createState() => _AddTimeState();
}

class _AddTimeState extends State<AddTime> {
  final List<String> _selectedTimes = [];
  DateTime? _selectedTime;
  bool _isUploading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _addSchedules() async {
    final valid = _formKey.currentState!.validate();
    if (!valid) {
      return;
    }
    try {
      setState(() {
        _isUploading = true;
      });

      // التأكد من عدم وجود null في النصوص
      DocumentReference busReference = FirebaseFirestore.instance
          .collection('busesSchedules')
          .doc(widget.placeName); // استخدم النص الإنجليزي كمفتاح فريد

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
        'times': updatedTimes,
      }, SetOptions(merge: true));

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('sucss'.tr()),
            content: const Text('done done'),
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
      appBar: StyleAppBar(title: 'اضافة وقت جديد'),
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
                      flex: 6,
                      child: FormBuilderDateTimePicker(
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                        validator: (value) {
                          if (value == null) {
                            return 'license_start_date_message'.tr();
                          }
                          return null;
                        },
                        name: 'license_start_date'.tr(),
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
                          labelText: 'license_start_date'.tr(),
                          hintText: 'license_start_date'.tr(),
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
                        'اضافة موعد'.tr(),
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
