// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bus_uni2/screens/admin/busschedules/managetourtime/addbusschedules.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:bus_uni2/screens/splash/splash_wait.dart';
import 'package:bus_uni2/screens/admin/busschedules/tourtime.dart';
import 'package:bus_uni2/widget/app_bar.dart';
import 'package:bus_uni2/widget/error_operation.dart';
import 'package:bus_uni2/widget/float_button.dart';
import 'package:bus_uni2/widget/gradient.dart';

class ViewBusSchedules extends StatefulWidget {
  final String type;
  const ViewBusSchedules({
    Key? key,
    required this.type,
  }) : super(key: key);

  @override
  State<ViewBusSchedules> createState() => _ViewBusSchedulesState();
}

class _ViewBusSchedulesState extends State<ViewBusSchedules> {
  late Stream<List<DocumentSnapshot>> driversStream;
  var _isUploading = false;

  _uploadData() {
    setState(
      () {
        _isUploading = true;
      },
    );
    driversStream = FirebaseFirestore.instance
        .collection('busesSchedules')
        .snapshots()
        .map((snapshot) => snapshot.docs);

    setState(
      () {
        _isUploading = false;
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _uploadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.type == 'admin'
          ? StyleAppBar(
              title: 'مكان الجولات',
              actionBar: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddBusSchedule(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add)),
            )
          : StyleAppBar(
              title: 'مكان الجولات',
            ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: StyleGradient(),
        ),
        child: StreamBuilder<List<DocumentSnapshot>>(
          stream: driversStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreenWait();
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (_isUploading) {
              return const CircularProgressIndicator(
                color: Colors.blue,
              );
            } else if (snapshot.hasData || !_isUploading) {
              List<DocumentSnapshot> places = snapshot.data!;
              return Padding(
                padding: EdgeInsets.all(50.w.h),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1, // عدد الأعمدة
                    mainAxisSpacing: 1, // المسافة العمودية بين الصفوف
                    childAspectRatio: 3,
                  ),
                  itemCount: (places.length / 1).ceil(), // عدد الصفوف
                  itemBuilder: (context, index) {
                    return Row(
                      children: places
                          .sublist(
                        index * 1,
                        (index * 1) + 1 > places.length
                            ? places.length
                            : (index * 1) + 1,
                      )
                          .map(
                        (driver) {
                          String placeNameEnglish = driver['busPlaceEnglish'];
                          String placeNameArabic = driver['busPlaceArabic'];

                          return Expanded(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => TourTime(
                                                selectedPlace: placeNameEnglish,
                                                placeNameArabic:
                                                    placeNameArabic,
                                                type: widget.type,
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: const Color.fromARGB(
                                              255, 255, 255, 255),
                                          backgroundColor: const Color.fromARGB(
                                              255, 0, 14, 67),
                                          padding: EdgeInsets.all(20.w.h),
                                          fixedSize: Size.fromHeight(150.h.w),
                                        ),
                                        child: Text(
                                          Localizations.localeOf(context)
                                                      .languageCode ==
                                                  'en'
                                              ? placeNameEnglish
                                              : placeNameArabic,
                                          style: TextStyle(fontSize: 35.sp),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ).toList(),
                    );
                  },
                ),
              );
            } else {
              return ErrorOperator(
                errorMessage: 'no_data_available'.tr(),
              );
            }
          },
        ),
      ),
      floatingActionButton: const MyFloatingActionButton(),
    );
  }
}
