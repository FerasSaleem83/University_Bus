// ignore_for_file: unused_field, use_build_context_synchronously, deprecated_member_use

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:bus_uni2/screens/admin/bus/infobus.dart';
import 'package:bus_uni2/widget/app_bar.dart';
import 'package:bus_uni2/widget/float_button.dart';
import 'package:bus_uni2/widget/gradient.dart';

class ViewBus extends StatefulWidget {
  final String busId;
  final String busType;
  final int busNumber;
  final int numberstudents;
  final int numberchairs;
  final String busModel;
  final double latitude;
  final double longitude;
  final int coding;
  final int registrationNumber;
  final String licenseStartDate;
  final String licenseEndDate;

  const ViewBus({
    required this.busId,
    required this.busType,
    required this.busNumber,
    required this.numberstudents,
    required this.numberchairs,
    required this.busModel,
    required this.latitude,
    required this.longitude,
    required this.coding,
    required this.registrationNumber,
    required this.licenseStartDate,
    required this.licenseEndDate,
    Key? key,
  }) : super(key: key);

  @override
  State<ViewBus> createState() => _ViewBusState();
}

class _ViewBusState extends State<ViewBus> {
  final TextEditingController _busTypeController = TextEditingController();
  final TextEditingController _busNumberController = TextEditingController();
  final TextEditingController _numberstudentsController =
      TextEditingController();
  final TextEditingController _numberchairsController = TextEditingController();
  final TextEditingController _busModelController = TextEditingController();
  final TextEditingController _codingController = TextEditingController();
  final TextEditingController _registrationNumberController =
      TextEditingController();
  final TextEditingController _licenseStartDateController =
      TextEditingController();
  final TextEditingController _licenseEndDateController =
      TextEditingController();

  GoogleMapController? mapController;
  Set<Marker> markers = {};
  late BitmapDescriptor carIcon;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _loadCarIcon();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _fetchAndInitializeControllers();
    });
  }

  Future<void> _fetchAndInitializeControllers() async {
    DocumentSnapshot busSnapshot = await FirebaseFirestore.instance
        .collection('buses')
        .doc(widget.busId)
        .get();

    if (busSnapshot.exists) {
      var busData = busSnapshot.data() as Map<String, dynamic>;

      setState(() {
        _busTypeController.text = busData['busType'] ?? '';
        _busNumberController.text = busData['busNumber'].toString();
        _numberstudentsController.text = busData['numberstudents'].toString();
        _numberchairsController.text =
            (busData['numberchairs'] - busData['numberstudents']).toString();
        _busModelController.text = busData['busModel'] ?? '';
        _codingController.text = busData['coding'].toString();
        _registrationNumberController.text =
            busData['registrationNumber'].toString();
        _licenseStartDateController.text = busData['licenseStartDate'] ?? '';
        _licenseEndDateController.text = busData['licenseEndDate'] ?? '';
      });
    }
  }

  Future<void> _loadCarIcon() async {
    carIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(20.w, 20.h)),
        'assets/images/bus_icon.png');

    // إنشاء وإضافة العلامة المرئية إلى مجموعة العلامات markers
    final Marker marker = Marker(
      markerId: const MarkerId('carMarker'),
      position: LatLng(widget.latitude, widget.longitude),
      icon: carIcon,
    );
    setState(
      () {
        markers.add(marker);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StyleAppBar(
        title: '${'bus_number'.tr()}: ${widget.busNumber}',
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: StyleGradient(),
        ),
        child: Padding(
          padding: EdgeInsets.all(15.w),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 450.h,
                  width: 525.w,
                  child: kIsWeb
                      ? Container(
                          color: const Color.fromARGB(255, 0, 14, 67),
                          child: Center(
                            child: Text(
                              'error_show_map'.tr(),
                              style:
                                  TextStyle(fontSize: 23.sp, color: Colors.red),
                            ),
                          ),
                        )
                      : GoogleMap(
                          onMapCreated: (controller) {
                            setState(
                              () {
                                mapController = controller;
                              },
                            );
                          },
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                              widget.latitude,
                              widget.longitude,
                            ),
                            zoom: 17,
                          ),
                          markers: markers,
                        ),
                ),
                SizedBox(height: 15.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 275.w,
                      child: Text(
                        '${'number_students'.tr()}:',
                        style: TextStyle(
                            fontSize: 25.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 15.w),
                    SizedBox(
                      width: 175.w,
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                        cursorColor: Colors.black,
                        decoration: const InputDecoration(
                          fillColor: Color.fromARGB(255, 255, 255, 255),
                          filled: true,
                          alignLabelWithHint: true,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        controller: _numberstudentsController,
                        readOnly: true,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 275.w,
                      child: Text(
                        '${'number_chairs'.tr()}:',
                        style: TextStyle(
                            fontSize: 25.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 15.w),
                    SizedBox(
                      width: 175.w,
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                        cursorColor: Colors.black,
                        decoration: const InputDecoration(
                          fillColor: Color.fromARGB(255, 255, 255, 255),
                          filled: true,
                          alignLabelWithHint: true,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        controller: _numberchairsController,
                        readOnly: true,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 45.h),
                SizedBox(
                  width: 325.w,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BusInfo(
                            busType: widget.busType,
                            busNumber: widget.busNumber,
                            numberchairs: widget.numberchairs,
                            busModel: widget.busModel,
                            coding: widget.coding,
                            registrationNumber: widget.registrationNumber,
                            licenseStartDate: widget.licenseStartDate,
                            licenseEndDate: widget.licenseEndDate,
                            busId: widget.busId,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 14, 67),
                    ),
                    child: Text(
                      'bus_info'.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25.sp,
                      ),
                    ),
                  ),
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
