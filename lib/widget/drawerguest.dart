// ignore_for_file: use_build_context_synchronously, prefer_typing_uninitialized_variables

import 'package:bus_uni2/screens/login/login.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:bus_uni2/screens/settingspage.dart';

class GuestDrawer extends StatefulWidget {
  const GuestDrawer({Key? key}) : super(key: key);

  @override
  State<GuestDrawer> createState() => _GuestDrawerState();
}

class _GuestDrawerState extends State<GuestDrawer> {
  String imagepersonal =
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcShB7IwN9gr4q2Tn-1CRfbgANRN-8SWlYMMy9iq467T1A&s';

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color.fromARGB(255, 193, 202, 203),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 0, 14, 67),
              ),
              accountName: Text('guest_label'.tr()),
              accountEmail: Text('email_label'.tr()),
              currentAccountPicture: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenImage(
                        imageUrl: imagepersonal,
                      ),
                    ),
                  );
                },
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    imagepersonal,
                  ),
                  radius: 100.r,
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withAlpha(180),
                ),
              ),
            ),
            ListTile(
              title: TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingPage(isGuest: true),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.settings,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                label: Text(
                  'setting'.tr(),
                  style: const TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 25.h),
            ListTile(
              title: TextButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginAndSignup(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.login,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                label: Text(
                  'login_button'.tr(),
                  style: const TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Image.network(
          imageUrl,
          width: 500.w,
          height: 500.h,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
