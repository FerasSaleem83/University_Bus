// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:bus_uni2/screens/login/authscreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:bus_uni2/widget/gradient.dart';

// شاشة الانتظار
class SplashScreenWaitAuth extends StatefulWidget {
  const SplashScreenWaitAuth({super.key});

  @override
  _SplashScreenWaitAuthState createState() => _SplashScreenWaitAuthState();
}

class _SplashScreenWaitAuthState extends State<SplashScreenWaitAuth> {
  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(seconds: 5),
      () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const Auth(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: StyleGradient(),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logoBus.png',
              width: 350.w,
              height: 350.h,
            ),
            SizedBox(height: 20.h),
            Center(
              child: Column(
                children: [
                  Text(
                    'loading'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      letterSpacing: 1,
                      fontSize: 35.sp,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w900,
                      color: const Color.fromARGB(255, 15, 7, 89),
                      decorationThickness: 3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
