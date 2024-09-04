// ignore_for_file: unnecessary_null_comparison

import 'package:bus_uni2/screens/admin/busschedules/managetourtime/addtime.dart';
import 'package:bus_uni2/widget/app_bar.dart';
import 'package:bus_uni2/widget/float_button.dart';
import 'package:bus_uni2/widget/gradient.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TourTime extends StatefulWidget {
  final String selectedPlace;
  final String placeNameArabic;
  final String type;
  const TourTime({
    super.key,
    required this.selectedPlace,
    required this.placeNameArabic,
    required this.type,
  });

  @override
  State<TourTime> createState() => _TourTimeState();
}

class _TourTimeState extends State<TourTime> {
  bool _isUploading = false;
  Stream<List<String>> _getBusSchedules(String place) {
    return FirebaseFirestore.instance
        .collection('busesSchedules')
        .where('busPlaceEnglish', isEqualTo: place)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            List<dynamic> times = doc['times'] as List<dynamic>;
            return times.map((time) => time.toString()).toList();
          })
          .expand((i) => i)
          .toList();
    });
  }

  void deleteTourTime() async {
    setState(() {
      _isUploading = true;
    });

    await FirebaseFirestore.instance
        .collection('busesSchedules')
        .doc(widget.selectedPlace)
        .delete();
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
    setState(() {
      _isUploading = false;
    });
  }

  void deletetime(int indexTime) async {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('busesSchedules')
        .doc(widget.selectedPlace)
        .get();

    if (docSnapshot.exists) {
      List<dynamic> times = docSnapshot['times'] as List<dynamic>;
      times.remove(times[indexTime]);

      // Update the document with the new list of times
      await FirebaseFirestore.instance
          .collection('busesSchedules')
          .doc(widget.selectedPlace)
          .update({'times': times});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.type == 'admin'
          ? StyleAppBar(
              title: Localizations.localeOf(context).languageCode == 'en'
                  ? widget.selectedPlace
                  : widget.placeNameArabic,
              actionBar: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddTime(placeName: widget.selectedPlace),
                      ),
                    );
                  },
                  icon: const Icon(Icons.more_time_outlined)),
            )
          : StyleAppBar(
              title: Localizations.localeOf(context).languageCode == 'en'
                  ? widget.selectedPlace
                  : widget.placeNameArabic,
            ),
      body: Container(
        decoration: BoxDecoration(
          gradient: StyleGradient(),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(45.w.h),
            child: StreamBuilder<List<String>>(
              stream: _getBusSchedules(widget.selectedPlace),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('error_occurred'.tr()));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('no_schedules'.tr()));
                } else {
                  List<String> busTimes = snapshot.data!;
                  busTimes.sort((a, b) {
                    DateTime timeA = DateFormat('hh:mm a').parse(a);
                    DateTime timeB = DateFormat('hh:mm a').parse(b);
                    return timeA.compareTo(timeB);
                  });
                  return ListView.builder(
                    itemCount: busTimes.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(25.w.h),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                deletetime(index);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 0, 14, 67),
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 50.sp,
                                  fontWeight: FontWeight.w900,
                                ),
                                padding: EdgeInsets.all(15.w.h),
                                foregroundColor: Colors.white,
                                shape: const BeveledRectangleBorder(),
                              ),
                              label: Text(
                                busTimes[index],
                                style: TextStyle(fontSize: 20.sp),
                              ),
                              icon: widget.type == 'admin'
                                  ? const Icon(Icons.close)
                                  : null,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ),
      ),
      floatingActionButton: widget.type == 'admin'
          ? _isUploading == false
              ? CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 0, 14, 67),
                  child: Expanded(
                    child: IconButton(
                      onPressed: deleteTourTime,
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                    ),
                  ),
                )
              : const CircularProgressIndicator(
                  color: Color.fromARGB(255, 0, 14, 67),
                )
          : const MyFloatingActionButton(),
    );
  }
}
