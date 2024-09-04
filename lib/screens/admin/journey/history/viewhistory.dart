// ignore_for_file: must_be_immutable

import 'package:bus_uni2/screens/splash/splash_wait.dart';
import 'package:bus_uni2/widget/app_bar.dart';
import 'package:bus_uni2/widget/float_button.dart';
import 'package:bus_uni2/widget/gradient.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ViewHistory extends StatefulWidget {
  String busNumber;
  ViewHistory({
    Key? key,
    required this.busNumber,
  }) : super(key: key);

  @override
  State<ViewHistory> createState() => _ViewHistoryState();
}

class _ViewHistoryState extends State<ViewHistory> {
  late Stream<List<DocumentSnapshot>> tripsStream;
  var _isUploading = false;
  Map<String, Map<String, int>> datePlaceCount = {};

  @override
  void initState() {
    super.initState();
    _uploadData();
  }

  _uploadData() {
    setState(() {
      _isUploading = true;
    });
    tripsStream = FirebaseFirestore.instance
        .collection('journeyHistory')
        .doc(widget.busNumber)
        .collection(widget.busNumber)
        .snapshots()
        .map((snapshot) {
      List<DocumentSnapshot> docs = snapshot.docs;
      _calculatePlaceFrequency(docs);
      return docs;
    });

    setState(() {
      _isUploading = false;
    });
  }

  void _calculatePlaceFrequency(List<DocumentSnapshot> docs) {
    datePlaceCount.clear();
    if (Localizations.localeOf(context).languageCode == 'ar') {
      for (var doc in docs) {
        String busPlaceArabic = doc['busPlaceArabic'];
        String date = doc['date'];

        if (!datePlaceCount.containsKey(date)) {
          datePlaceCount[date] = {};
        }

        if (datePlaceCount[date]!.containsKey(busPlaceArabic)) {
          datePlaceCount[date]![busPlaceArabic] =
              datePlaceCount[date]![busPlaceArabic]! + 1;
        } else {
          datePlaceCount[date]![busPlaceArabic] = 1;
        }
      }
    } else {
      for (var doc in docs) {
        String busPlaceEnglish = doc['busPlaceEnglish'];
        String date = doc['date'];

        if (!datePlaceCount.containsKey(date)) {
          datePlaceCount[date] = {};
        }

        if (datePlaceCount[date]!.containsKey(busPlaceEnglish)) {
          datePlaceCount[date]![busPlaceEnglish] =
              datePlaceCount[date]![busPlaceEnglish]! + 1;
        } else {
          datePlaceCount[date]![busPlaceEnglish] = 1;
        }
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StyleAppBar(
        title: '${'bus_number'.tr()} ${widget.busNumber}',
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: StyleGradient(),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<DocumentSnapshot>>(
                stream: tripsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SplashScreenWait();
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else if (_isUploading) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasData || !_isUploading) {
                    return Padding(
                      padding: EdgeInsets.fromLTRB(0.w, 25.h, 0.w, 25.h),
                      child: Text(
                        'journey_history'.tr(),
                        style: TextStyle(
                          fontSize: 35.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  } else {
                    return const Center(
                      child: Text('no_data_available'),
                    );
                  }
                },
              ),
            ),
            if (datePlaceCount.isNotEmpty)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(15.w),
                  child: ListView.builder(
                    itemCount: datePlaceCount.length,
                    itemBuilder: (context, index) {
                      String date = datePlaceCount.keys.elementAt(index);
                      Map<String, int> places = datePlaceCount[date]!;
                      return ExpansionTile(
                        title: Text(
                          date,
                          style: TextStyle(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: places.entries.map((entry) {
                          return ListTile(
                            title: Text(
                              '${entry.key}: ${entry.value}',
                              style: TextStyle(
                                fontSize: 25.sp,
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: const MyFloatingActionButton(),
    );
  }
}
