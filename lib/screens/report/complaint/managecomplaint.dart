import 'package:bus_uni2/screens/report/complaint/addcomplaint.dart';
import 'package:bus_uni2/screens/report/complaint/deletecomplaint.dart';
import 'package:bus_uni2/screens/report/complaint/updatecomplaint.dart';
import 'package:bus_uni2/widget/app_bar.dart';
import 'package:bus_uni2/widget/float_button.dart';
import 'package:bus_uni2/widget/gradient.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ManageComplaint extends StatefulWidget {
  const ManageComplaint({super.key});

  @override
  State<ManageComplaint> createState() => _ManageComplaintState();
}

class _ManageComplaintState extends State<ManageComplaint> {
  bool isUploading = false;
  String? selectedBusComplaint;
  String? busComplaint;
  List<String> _busComplaint = [];

  @override
  void initState() {
    super.initState();
    viewBusComplaint();
  }

  void viewBusComplaint() async {
    QuerySnapshot complaintSnapshot =
        await FirebaseFirestore.instance.collection('selectComplaint').get();

    setState(() {
      if (Localizations.localeOf(context).languageCode == 'en') {
        _busComplaint = complaintSnapshot.docs
            .map((doc) => doc['ComplaintEnglish'] as String?)
            .where((complaint) => complaint != null && complaint.isNotEmpty)
            .cast<String>()
            .toList();
      } else {
        _busComplaint = complaintSnapshot.docs
            .map((doc) => doc['ComplaintArabic'] as String?)
            .where((complaint) => complaint != null && complaint.isNotEmpty)
            .cast<String>()
            .toList();
      }
      _busComplaint.sort();
    });
  }

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
                    Text('complaints'.tr()),
                    DropdownButtonFormField<String>(
                      value: selectedBusComplaint,
                      items: _busComplaint.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value.toString(),
                            style: TextStyle(
                              fontSize: 25.sp,
                              color: Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedBusComplaint = newValue;
                        });
                      },
                      style: TextStyle(
                        fontSize: 25.sp,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25.sp,
                        ),
                        hintText: 'complaints'.tr(),
                        fillColor: Colors.grey[100],
                        filled: true,
                        alignLabelWithHint: true,
                        floatingLabelAlignment: FloatingLabelAlignment.center,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 1.0.w,
                          ),
                          borderRadius: BorderRadius.circular(10.0.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 5.0.w,
                          horizontal: 20.h,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 2.5.w,
                          ),
                          borderRadius: BorderRadius.circular(10.0.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 75.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 175.w,
                          height: 100.h,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddComplaint(),
                                ),
                              );
                            },
                            label: Text('add_complaint'.tr()),
                            style: ElevatedButton.styleFrom(
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 20.sp,
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
                              Icons.add,
                              size: 25.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 30.w),
                        SizedBox(
                          width: 175.w,
                          height: 100.h,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const UpdateComplaint(),
                                ),
                              );
                            },
                            label: Text('update_complaint'.tr()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 0, 14, 67),
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'DecoType_Thuluth',
                              ),
                              padding: EdgeInsets.all(15.w.h),
                              foregroundColor: Colors.white,
                              shape: const BeveledRectangleBorder(),
                            ),
                            icon: Icon(
                              Icons.edit,
                              size: 25.w,
                            ),
                          ),
                        ),
                        SizedBox(width: 30.w),
                        SizedBox(
                          width: 175.w,
                          height: 100.h,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DeleteComplaint(),
                                ),
                              );
                            },
                            label: Text('delete_complaint'.tr()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 0, 14, 67),
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'DecoType_Thuluth',
                              ),
                              padding: EdgeInsets.all(15.w.h),
                              foregroundColor: Colors.white,
                              shape: const BeveledRectangleBorder(),
                            ),
                            icon: Icon(
                              Icons.delete,
                              size: 25.w,
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
