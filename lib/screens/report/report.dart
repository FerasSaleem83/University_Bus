import 'package:bus_uni2/screens/report/complaint/managecomplaint.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:bus_uni2/screens/report/complaint/complaint.dart';
import 'package:bus_uni2/screens/report/rating/rate.dart';
import 'package:bus_uni2/widget/app_bar.dart';
import 'package:bus_uni2/widget/float_button.dart';
import 'package:bus_uni2/widget/gradient.dart';

class Report extends StatefulWidget {
  final String studentName;
  final String userType;

  const Report({super.key, required this.studentName, required this.userType});

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StyleAppBar(title: 'reports'.tr()),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: StyleGradient(),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/iu-logo-jordan.png',
                width: 200.w,
                height: 200.h,
              ),
              SizedBox(
                width: 600.w,
                height: 600.h,
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Form(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 400.w,
                          height: 60.h,
                          child: Container(
                            color: const Color.fromARGB(255, 0, 14, 67),
                            child: TextButton.icon(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Complaint(
                                        studentName: widget.studentName,
                                        userType: widget.userType,
                                      ),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  Icons.rate_review,
                                  color: const Color.fromARGB(255, 173, 2, 2),
                                  size: 30.w,
                                ),
                                label: Text(
                                  widget.userType == 'student'
                                      ? 'make_complaint'.tr()
                                      : 'complaints'.tr(),
                                  style: TextStyle(
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30.sp,
                                  ),
                                )),
                          ),
                        ),
                        SizedBox(height: 75.h),
                        SizedBox(
                          width: 400.w,
                          height: 60.h,
                          child: Container(
                            color: const Color.fromARGB(255, 0, 14, 67),
                            child: TextButton.icon(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Evaluation(
                                      studentName: widget.studentName,
                                      userType: widget.userType,
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.star,
                                color: const Color.fromARGB(255, 199, 196, 1),
                                size: 30.w,
                              ),
                              label: Text(
                                widget.userType == 'student'
                                    ? 'evaluation'.tr()
                                    : 'ratings'.tr(),
                                style: TextStyle(
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 75.h),
                        if (widget.userType != 'student')
                          SizedBox(
                            width: 400.w,
                            height: 60.h,
                            child: Container(
                              color: const Color.fromARGB(255, 0, 14, 67),
                              child: TextButton.icon(
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ManageComplaint(),
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.settings,
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255),
                                    size: 30.w,
                                  ),
                                  label: Text(
                                    'manage_complaint'.tr(),
                                    style: TextStyle(
                                      color: const Color.fromARGB(
                                          255, 255, 255, 255),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30.sp,
                                    ),
                                  )),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: const MyFloatingActionButton(),
    );
  }
}
