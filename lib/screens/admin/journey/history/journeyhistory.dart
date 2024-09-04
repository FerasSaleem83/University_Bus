import 'package:bus_uni2/screens/admin/journey/history/viewhistory.dart';
import 'package:bus_uni2/screens/splash/splash_wait.dart';
import 'package:bus_uni2/widget/app_bar.dart';
import 'package:bus_uni2/widget/error_operation.dart';
import 'package:bus_uni2/widget/float_button.dart';
import 'package:bus_uni2/widget/gradient.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class JourneyHistory extends StatefulWidget {
  const JourneyHistory({super.key});

  @override
  State<JourneyHistory> createState() => _JourneyHistoryState();
}

class _JourneyHistoryState extends State<JourneyHistory> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int? busNumber;
  int? busnewNumber;
  bool isUploading = false;
  late Stream<List<DocumentSnapshot>> journeyStream;
  late Future<DocumentSnapshot<Map<String, dynamic>>> usernameFuture;
  late Future<void> busNumberFuture;

  @override
  void initState() {
    super.initState();
    _uploadData();
  }

  _uploadData() {
    setState(() {
      isUploading = true;
    });
    journeyStream = FirebaseFirestore.instance
        .collection('buses')
        .snapshots()
        .map((snapshot) => snapshot.docs);

    setState(() {
      isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _firestore.collectionGroup('journeyHistory').snapshots(),
        builder: (context, snapshot) {
          return Scaffold(
            appBar: StyleAppBar(
              title: 'journey_history'.tr(),
            ),
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: StyleGradient(),
              ),
              child: StreamBuilder<List<DocumentSnapshot>>(
                stream: journeyStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SplashScreenWait();
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else if (isUploading) {
                    return const SplashScreenWait();
                  } else if (snapshot.hasData || !isUploading) {
                    List<DocumentSnapshot> buss = snapshot.data!;
                    buss.sort(
                      (a, b) => a['busNumber'].compareTo(
                        b['busNumber'],
                      ),
                    ); // ترتيب السائقين حسب رقم الباص
                    return Padding(
                      padding: EdgeInsets.all(15.w),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1, // عدد الأعمدة
                          mainAxisSpacing: 5, // المسافة العمودية بين الصفوف
                          childAspectRatio: 5,
                        ),
                        itemCount: (buss.length / 5).ceil(), // عدد الصفوف
                        itemBuilder: (context, index) {
                          return Row(
                            children: buss
                                .sublist(
                              index * 5,
                              (index * 5) + 5 > buss.length
                                  ? buss.length
                                  : (index * 5) + 5,
                            )
                                .map(
                              (bus) {
                                int busNumber = bus['busNumber'].toInt();
                                return Expanded(
                                  child: Column(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ViewHistory(
                                                        busNumber:
                                                            '$busNumber')),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: const Color.fromARGB(
                                              255, 255, 255, 255),
                                          backgroundColor: const Color.fromARGB(
                                              255, 0, 14, 67),
                                          padding: EdgeInsets.all(8.w),
                                          fixedSize: Size.fromHeight(
                                              75.h), // تحديد ارتفاع الزر
                                          shape: const CircleBorder(),
                                        ),
                                        child: Text(
                                          '$busNumber',
                                          style: TextStyle(
                                            fontSize: 25.sp,
                                          ),
                                        ),
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
                        errorMessage: 'no_data_available'.tr());
                  }
                },
              ),
            ),
            floatingActionButton: const MyFloatingActionButton(),
          );
        });
  }
}
