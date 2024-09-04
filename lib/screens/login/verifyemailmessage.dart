import 'package:bus_uni2/screens/login/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyEmailMessage extends StatefulWidget {
  const VerifyEmailMessage({super.key});

  @override
  State<VerifyEmailMessage> createState() => _VerifyEmailMessageState();
}

class _VerifyEmailMessageState extends State<VerifyEmailMessage> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 197, 215, 230),
      scrollable: true,
      title: const Text('تم'),
      content: const Text(
          'تم تسجيل الحساب بنجاح. يرجى التحقق من بريدك الإلكتروني لإكمال التسجيل.'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginAndSignup(),
              ),
            );
          },
          child: const Text('حسنًا'),
        ),
      ],
    );
  }
}
