import 'package:bus_uni2/screens/admin/journey/finishjourney.dart';
import 'package:bus_uni2/screens/admin/journey/history/journeyhistory.dart';
import 'package:bus_uni2/screens/admin/journey/place/places.dart';
import 'package:bus_uni2/screens/admin/journey/setjourney.dart';
import 'package:bus_uni2/widget/app_bar.dart';
import 'package:bus_uni2/widget/float_button.dart';
import 'package:bus_uni2/widget/gradient.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ManageJourney extends StatefulWidget {
  const ManageJourney({super.key});

  @override
  State<ManageJourney> createState() => _ManageJourneyState();
}

class _ManageJourneyState extends State<ManageJourney> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StyleAppBar(title: ''),
      body: Container(
        decoration: BoxDecoration(
          gradient: StyleGradient(),
        ),
        child: Padding(
          padding: EdgeInsets.all(15.w.h),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/iu-logo-jordan.png',
                  width: 200.w,
                  height: 200.h,
                ),
                SizedBox(height: 75.h),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 200.w,
                          height: 200.h,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SetJourney(),
                                ),
                              );
                            },
                            label: Text('set_journey'.tr()),
                            style: ElevatedButton.styleFrom(
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 30.sp,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'DecoType_Thuluth',
                              ),
                              backgroundColor:
                                  const Color.fromARGB(255, 0, 14, 67),
                              shape: const BeveledRectangleBorder(),
                              padding: EdgeInsets.all(15.w),
                              foregroundColor: Colors.white,
                            ),
                            icon: Icon(
                              Icons.settings,
                              size: 40.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 20.w),
                        SizedBox(
                          width: 200.w,
                          height: 200.h,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FinishJourney(),
                                ),
                              );
                            },
                            label: Text('finish_journey'.tr()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 0, 14, 67),
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 30.sp,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'DecoType_Thuluth',
                              ),
                              padding: EdgeInsets.all(15.w.h),
                              foregroundColor: Colors.white,
                              shape: const BeveledRectangleBorder(),
                            ),
                            icon: Icon(
                              Icons.logout,
                              size: 40.w,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 200.w,
                          height: 200.h,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Places(),
                                ),
                              );
                            },
                            label: Text('places'.tr()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 0, 14, 67),
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 30.sp,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'DecoType_Thuluth',
                              ),
                              padding: EdgeInsets.all(15.w.h),
                              foregroundColor: Colors.white,
                              shape: const BeveledRectangleBorder(),
                            ),
                            icon: Icon(
                              Icons.place,
                              size: 40.w,
                            ),
                          ),
                        ),
                        SizedBox(width: 20.w),
                        SizedBox(
                          width: 200.w,
                          height: 200.h,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const JourneyHistory()),
                              );
                            },
                            label: Text('journey_history'.tr()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 0, 14, 67),
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 30.sp,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'DecoType_Thuluth',
                              ),
                              padding: EdgeInsets.all(15.w.h),
                              foregroundColor: Colors.white,
                              shape: const BeveledRectangleBorder(),
                            ),
                            icon: Icon(
                              Icons.history,
                              size: 40.w,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: const MyFloatingActionButton(),
    );
  }
}
