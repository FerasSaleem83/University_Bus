// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable
// ignore_for_file: use_build_context_synchronously

import 'package:bus_uni2/screens/login/login.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:bus_uni2/screens/login/authscreen.dart';
import 'package:bus_uni2/widget/app_bar.dart';
import 'package:bus_uni2/widget/gradient.dart';

class SettingPage extends StatefulWidget {
  bool isGuest;
  SettingPage({
    Key? key,
    required this.isGuest,
  }) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StyleAppBar(
        title: 'setting'.tr(),
        actionBar: IconButton(
          onPressed: () async {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Auth(),
              ),
            );
          },
          icon: const Icon(
            Icons.arrow_forward,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: StyleGradient(),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/iu-logo-jordan.png',
                  width: 200.w,
                  height: 200.h,
                ),
                SizedBox(height: 100.h),
                SizedBox(
                  width: 300.w,
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Form(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 300.w,
                            child: Container(
                              color: const Color.fromARGB(255, 0, 14, 67),
                              child: TextButton.icon(
                                onPressed: () async {
                                  await EasyLocalization.of(context)?.setLocale(
                                    EasyLocalization.of(context)?.locale ==
                                            const Locale('en', 'US')
                                        ? const Locale('ar', 'SA')
                                        : const Locale('en', 'US'),
                                  );
                                },
                                icon: const Icon(
                                  Icons.translate,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                                label: Text(
                                  'change_language'.tr(),
                                  style: TextStyle(
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25.sp,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 75.h),
                          if (widget.isGuest == false)
                            SizedBox(
                              width: 300.w,
                              child: Container(
                                  color: const Color.fromARGB(255, 0, 14, 67),
                                  child: TextButton.icon(
                                    onPressed: () async {
                                      // تسجيل الخروج من Firebase Auth
                                      await FirebaseAuth.instance.signOut();

                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const Auth(),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.logout,
                                      color: Color.fromARGB(255, 255, 255, 255),
                                    ),
                                    label: Text(
                                      'sign_out'.tr(),
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                            255, 255, 255, 255),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25.sp,
                                      ),
                                    ),
                                  )),
                            ),
                          if (widget.isGuest == true)
                            SizedBox(
                              width: 300.w,
                              child: Container(
                                  color: const Color.fromARGB(255, 0, 14, 67),
                                  child: TextButton.icon(
                                    onPressed: () async {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginAndSignup(),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.logout,
                                      color: Color.fromARGB(255, 255, 255, 255),
                                    ),
                                    label: Text(
                                      'login_button'.tr(),
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                            255, 255, 255, 255),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25.sp,
                                      ),
                                    ),
                                  )),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 150.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 150.w,
                      child: MaterialButton(
                        onPressed: () async {
                          await EasyLauncher.url(
                            url: "https://web.facebook.com/alisrauni",
                            mode: Mode.platformDefault,
                          );
                        },
                        child: Image.asset(
                          'assets/images/facebook.png',
                          width: 175.w,
                          height: 175.h,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 150.w,
                      child: MaterialButton(
                        onPressed: () async {
                          await EasyLauncher.sendToWhatsApp(
                              phone: "+962779488888", message: "hello".tr());
                        },
                        child: Image.asset(
                          'assets/images/whatsapp.png',
                          width: 175.w,
                          height: 175.h,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 150.w,
                      child: MaterialButton(
                        onPressed: () async {
                          await EasyLauncher.url(
                            url: "https://www.instagram.com/alisrauni",
                            mode: Mode.platformDefault,
                          );
                        },
                        child: Image.asset(
                          'assets/images/instagram.png',
                          width: 175.w,
                          height: 175.h,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 150.w,
                      child: MaterialButton(
                        onPressed: () async {
                          await EasyLauncher.url(
                            url: "https://iu.edu.jo",
                            mode: Mode.platformDefault,
                          );
                        },
                        child: Image.asset(
                          'assets/images/linkIu.png',
                          width: 175.w,
                          height: 175.h,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
