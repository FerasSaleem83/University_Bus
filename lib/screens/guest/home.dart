import 'package:bus_uni2/screens/admin/busschedules/viewbussechdule.dart';
import 'package:bus_uni2/screens/guest/buslocation.dart';
import 'package:bus_uni2/screens/login/login.dart';
import 'package:bus_uni2/widget/app_bar.dart';
import 'package:bus_uni2/widget/drawerguest.dart';
import 'package:bus_uni2/widget/float_button.dart';
import 'package:bus_uni2/widget/gradient.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeGuest extends StatefulWidget {
  const HomeGuest({super.key});

  @override
  State<HomeGuest> createState() => _HomeGuestState();
}

class _HomeGuestState extends State<HomeGuest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StyleAppBar(title: 'صفحة الضيف'),
      drawer: const GuestDrawer(),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: StyleGradient(),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(15.w.h),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/iu-logo-jordan.png',
                    width: 225.w,
                    height: 225.h,
                  ),
                  SizedBox(height: 25.h),
                  Text(
                    'Welcome To Israa University',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 0, 14, 67),
                      fontSize: 40.sp,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'DecoType_Thuluth',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 200.h),
                  SizedBox(
                    width: 450.w,
                    height: 65.h,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BusLocation(),
                          ),
                        );
                      },
                      label: Text('مواقع الباصات'.tr()),
                      style: ElevatedButton.styleFrom(
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 30.sp,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'DecoType_Thuluth',
                        ),
                        backgroundColor: const Color.fromARGB(255, 0, 14, 67),
                        shape: const BeveledRectangleBorder(),
                        padding: EdgeInsets.all(15.w),
                        foregroundColor: Colors.white,
                      ),
                      icon: Icon(
                        Icons.bus_alert,
                        size: 30.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: 450.w,
                    height: 65.h,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ViewBusSchedules(type: ''),
                          ),
                        );
                      },
                      label: Text('مواعيد انطلاق الباصات'.tr()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 0, 14, 67),
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
                        Icons.access_time_rounded,
                        size: 30.w,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: 450.w,
                    height: 65.h,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginAndSignup(),
                          ),
                        );
                      },
                      label: Text('تسجبل الدخول'.tr()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 0, 14, 67),
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
                        Icons.login,
                        size: 30.w,
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
