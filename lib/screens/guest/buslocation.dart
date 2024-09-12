// ignore_for_file: unused_field, use_build_context_synchronously, deprecated_member_use

import 'dart:async';

import 'package:bus_uni2/widget/drawerguest.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:bus_uni2/widget/app_bar.dart';
import 'package:bus_uni2/widget/error_operation.dart';
import 'package:bus_uni2/widget/float_button.dart';
import 'package:bus_uni2/widget/gradient.dart';

class BusLocation extends StatefulWidget {
  const BusLocation({Key? key}) : super(key: key);

  @override
  State<BusLocation> createState() => _BusLocationState();
}

class _BusLocationState extends State<BusLocation> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  late BitmapDescriptor carIcon;
  late Timer _timer;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? selectedBusPlace;
  bool _isUploading = false;
  List<String> _busPlace = [];
  Position? _position;
  List<LatLng> allLatLngs = []; // لتخزين كل المواقع
  LatLng? currentPosition; // لتخزين الموقع الحالي

  @override
  void initState() {
    super.initState();
    _loadCarIcon();
    viewBusPlace();
    _getCurrentLocation();
  }

  void _getCurrentLocation() {
    try {
      setState(
        () {
          _isUploading = true;
        },
      );
      Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        forceAndroidLocationManager: true,
        timeLimit: const Duration(seconds: 10),
      ).then(
        (Position position) {
          setState(
            () {
              _position = position;
              _isUploading = false;
            },
          );
          mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(
                  position.latitude,
                  position.longitude,
                ),
                zoom: 19,
              ),
            ),
          );
        },
      ).catchError(
        (error) {
          ErrorOperator(
            errorMessage: '$error',
          );
        },
      );
    } catch (e) {
      ErrorOperator(
        errorMessage: '$e',
      );
      setState(
        () {
          _isUploading = false;
        },
      );
    }
  }

  Future<void> _loadCarIcon() async {
    carIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(
        size: Size(40.w, 40.h),
      ),
      'assets/images/bus_icon.png',
    );
  }

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

    if (_busPlace.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('error'.tr()),
            content: Text('no_buses_available'.tr()),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).pop(); // Close the current page
                },
                child: Text('done_button'.tr()),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collectionGroup('buses').snapshots(),
      builder: (context, snapshot) {
        markers.clear();
        List<LatLng> allLatLngs = []; // لتخزين كل المواقع
        LatLng? currentPosition; // لتخزين الموقع الحالي

        if (snapshot.hasData && snapshot.data != null) {
          for (var doc in snapshot.data!.docs) {
            final long = doc.get('longitude');
            final lat = doc.get('latitude');
            final busNumber = doc.get('busNumber');
            final numberChairs = doc.get('numberchairsavailable');
            final busPlaceArabic = doc.get('busPlaceArabic');
            final busPlaceEnglish = doc.get('busPlaceEnglish');

            if (selectedBusPlace == null ||
                (Localizations.localeOf(context).languageCode == 'en'
                    ? busPlaceEnglish == selectedBusPlace
                    : busPlaceArabic == selectedBusPlace)) {
              final position = LatLng(lat, long);
              allLatLngs.add(position); // إضافة الموقع إلى قائمة المواقع

              markers.add(
                Marker(
                  markerId: MarkerId(doc.id),
                  position: position,
                  infoWindow: InfoWindow(
                    title: '$busNumber',
                    snippet: numberChairs == 0
                        ? 'Full'
                        : '${"number_chairs".tr()}:  $numberChairs',
                  ),
                  icon: carIcon,
                ),
              );
            }
          }

          // حساب الحدود لتناسب جميع العلامات والموقع الحالي
          if (allLatLngs.isNotEmpty && selectedBusPlace != null) {
            Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
              forceAndroidLocationManager: true,
              timeLimit: const Duration(seconds: 10),
            ).then((Position position) {
              currentPosition = LatLng(position.latitude, position.longitude);
              if (currentPosition != null) {
                allLatLngs
                    .add(currentPosition!); // إضافة الموقع الحالي إلى القائمة
              }

              LatLngBounds bounds = LatLngBounds(
                southwest: LatLng(
                  allLatLngs
                      .map((e) => e.latitude)
                      .reduce((a, b) => a < b ? a : b),
                  allLatLngs
                      .map((e) => e.longitude)
                      .reduce((a, b) => a < b ? a : b),
                ),
                northeast: LatLng(
                  allLatLngs
                      .map((e) => e.latitude)
                      .reduce((a, b) => a > b ? a : b),
                  allLatLngs
                      .map((e) => e.longitude)
                      .reduce((a, b) => a > b ? a : b),
                ),
              );

              // تحديث الكاميرا لتناسب الحدود
              mapController?.animateCamera(
                CameraUpdate.newLatLngBounds(
                    bounds, 50), // المعامل 50 هو الهامش حول الحدود
              );

              setState(() {
                _position = position;
                _isUploading = false;
              });
            }).catchError((error) {
              ErrorOperator(
                errorMessage: '$error',
              );
            });
          } else {
            Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
              forceAndroidLocationManager: true,
              timeLimit: const Duration(seconds: 10),
            ).then(
              (Position position) {
                setState(
                  () {
                    _position = position;
                    _isUploading = false;
                  },
                );
                mapController!.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(
                        position.latitude,
                        position.longitude,
                      ),
                      zoom: 17,
                    ),
                  ),
                );
              },
            ).catchError(
              (error) {
                ErrorOperator(
                  errorMessage: '$error',
                );
              },
            );
          }
        }

        //عرض بيانات المستخدم
        return Scaffold(
          appBar: StyleAppBar(title: 'location_bus'.tr()),
          drawer: const GuestDrawer(),
          body: Container(
            decoration: BoxDecoration(
              gradient: StyleGradient(),
            ),
            child: Padding(
              padding: EdgeInsets.all(15.w),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Image.asset(
                        'assets/images/iu-logo-jordan.png',
                        width: 175.w,
                        height: 175.h,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
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
                              floatingLabelAlignment:
                                  FloatingLabelAlignment.center,
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
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
                        ),
                        SizedBox(width: 15.w),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              selectedBusPlace = null;
                            });
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    if (_isUploading)
                      Column(
                        children: [
                          const CircularProgressIndicator(
                            color: Colors.blue,
                          ),
                          SizedBox(height: 300.h)
                        ],
                      ),
                    if (!_isUploading)
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: 500.h,
                          child: kIsWeb
                              ? Container(
                                  color: const Color.fromARGB(255, 0, 14, 67),
                                  child: Center(
                                    child: Text(
                                      'error_show_map'.tr(),
                                      style: TextStyle(
                                          fontSize: 23.sp, color: Colors.red),
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
                                  myLocationEnabled: true,
                                  initialCameraPosition: CameraPosition(
                                    target: LatLng(
                                      _position!.latitude,
                                      _position!.longitude,
                                    ),
                                    zoom: 17,
                                  ),
                                  markers: markers,
                                ),
                        ),
                      ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: const MyFloatingActionButton(),
        );
      },
    );
  }
}
