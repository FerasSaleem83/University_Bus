import 'package:bus_uni2/screens/admin/journey/place/addplace.dart';
import 'package:bus_uni2/screens/admin/journey/place/deletepalce.dart';
import 'package:bus_uni2/screens/admin/journey/place/updateplace.dart';
import 'package:bus_uni2/widget/app_bar.dart';
import 'package:bus_uni2/widget/float_button.dart';
import 'package:bus_uni2/widget/gradient.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Places extends StatefulWidget {
  const Places({super.key});

  @override
  State<Places> createState() => _PlacesState();
}

class _PlacesState extends State<Places> {
  String? selectedBusPlace;
  String? busPlace;
  List<String> _busPlace = [];

  void viewBusPlace() async {
    QuerySnapshot placeSnapshot =
        await FirebaseFirestore.instance.collection('itinerary').get();

    setState(() {
      if (Localizations.localeOf(context).languageCode == 'en') {
        _busPlace = placeSnapshot.docs
            .map((doc) => doc['PlaceEnglish'] as String?)
            .where((place) => place != null && place.isNotEmpty)
            .cast<String>()
            .toList();
      } else {
        _busPlace = placeSnapshot.docs
            .map((doc) => doc['PlaceArabic'] as String?)
            .where((place) => place != null && place.isNotEmpty)
            .cast<String>()
            .toList();
      }
      _busPlace.sort();
    });
  }

  @override
  void initState() {
    super.initState();
    viewBusPlace();
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
                Text('itinerary'.tr()),
                DropdownButtonFormField<String>(
                  value: selectedBusPlace,
                  items: _busPlace.map((String value) {
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
                      selectedBusPlace = newValue;
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
                    hintText: 'itinerary'.tr(),
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
                SizedBox(height: 30.h),
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
                              builder: (context) => const AddPlace(),
                            ),
                          );
                        },
                        label: Text('add_place'.tr()),
                        style: ElevatedButton.styleFrom(
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'DecoType_Thuluth',
                          ),
                          backgroundColor: const Color.fromARGB(255, 0, 14, 67),
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
                    SizedBox(width: 45.w),
                    SizedBox(
                      width: 175.w,
                      height: 100.h,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UpdatePlace(),
                            ),
                          );
                        },
                        label: Text('update_place'.tr()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 0, 14, 67),
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
                    SizedBox(width: 45.w),
                    SizedBox(
                      width: 175.w,
                      height: 100.h,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DeletePlace(),
                            ),
                          );
                        },
                        label: Text('delete_place'.tr()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 0, 14, 67),
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
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: const MyFloatingActionButton(),
    );
  }
}
