// ignore_for_file: library_private_types_in_public_api,  use_build_context_synchronously, unused_element, deprecated_member_use

import 'dart:async';
import 'dart:math';

import 'package:bus_uni2/screens/admin/busschedules/viewbussechdule.dart';
import 'package:flutter/foundation.dart'; // استيراد المكتبة للتحقق من النظام الأساسي

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:bus_uni2/screens/student/detailsuser.dart';
import 'package:bus_uni2/screens/report/report.dart';
import 'package:bus_uni2/screens/splash/splash_wait.dart';
import 'package:bus_uni2/widget/app_bar.dart';
import 'package:bus_uni2/widget/drawer.dart';
import 'package:bus_uni2/widget/error_operation.dart';
import 'package:bus_uni2/widget/float_button.dart';
import 'package:bus_uni2/widget/gradient.dart';

User users = FirebaseAuth.instance.currentUser!;

String userId = users.uid;

final usersRef = FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('information');

class StudentScreen extends StatefulWidget {
  const StudentScreen({Key? key}) : super(key: key);

  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> usernameFuture;
  late Future<QuerySnapshot<Map<String, dynamic>>> usernameFuture2;

  GoogleMapController? mapController;
  String currentLocation = '';
  Set<Marker> markers = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late BitmapDescriptor carIcon;
  late BitmapDescriptor boyIcon;
  int nearbyPeopleCount = 0;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  String? selectedRegistrationPlace;
  Position? _position;
  var _isUploading = false;
  bool isPassenger = false;
  bool isShare = false;
  bool isnewShare = false;
  String? selectedBusPlace;
  String? busPlaceArabic;
  String? busPlaceEnglish;
  late Timer _timer;
  bool notificationSent = false;
  late Timer timer;
  int? busnewNumber;
  List<String> _busPlace = [];

  Future<void> _loadCarIcon() async {
    carIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(
        size: Size(40.w, 40.h),
      ),
      'assets/images/bus_icon.png',
    );
  }

  Future<void> _initMessaging() async {
    await Firebase.initializeApp();
    _firebaseMessaging.requestPermission();
    _firebaseMessaging.getToken().then(
      (token) {
        ErrorOperator(errorMessage: '${'firebase_token'.tr()}: $token');
      },
    );
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        ErrorOperator(errorMessage: '${'error'.tr()}: $message');
      },
    );
    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        ErrorOperator(errorMessage: '${'error'.tr()}: $message');
      },
    );
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    _geolocatorPlatform.getPositionStream().listen(
      (position) {
        if (isPassenger == false && isnewShare == true) {
          _checkNearbyPeople(position);
        }
      },
    );
  }

  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    ErrorOperator(errorMessage: '${'error'.tr()}: $message');
  }

  void _checkNearbyPeople(Position position) async {
    const double proximityThreshold =
        10; // المسافة بالأمتار // تم تغييرها لفحص التطبيق من 25 الى 10

    nearbyPeopleCount = 0; // إعادة تهيئة العداد

    for (var marker in markers) {
      var personLat = marker.position.latitude;
      var personLon = marker.position.longitude;
      var distance = distanceBetweenPoints(
        position.latitude,
        position.longitude,
        personLat,
        personLon,
      );
      if (distance <= proximityThreshold) {
        if (notificationSent == false) {
          notificationSent = true;

          _sendNotification();
        }
      }
    }
    setState(
      () {},
    );
  }

  Future<bool> checkIfUserIsPassenger() async {
    var studentDoc = await FirebaseFirestore.instance
        .collection('students')
        .doc(userId)
        .get();
    bool isnewPassenger = studentDoc.get('isPassengers') == 'true';

    setState(() {
      isPassenger = isnewPassenger;
    });
    return isPassenger;
  }

  Future<bool> checkIfUserIsShare() async {
    var studentDoc = await FirebaseFirestore.instance
        .collection('students')
        .doc(userId)
        .get();
    bool isShare = studentDoc.get('isShare') == 'true';

    setState(() {
      isnewShare = isShare;
    });
    return isnewShare;
  }

  double distanceBetweenPoints(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0; // نصف قطر الأرض بالكيلومترات
    var dLat = _toRadians(lat2 - lat1);
    var dLon = _toRadians(lon2 - lon1);
    var a = pow(sin(dLat / 2), 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * pow(sin(dLon / 2), 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c * 100;
  }

  double _toRadians(double degree) {
    return degree * (pi / 180);
  }

  void _sendNotification() async {
    var androidDetails = const AndroidNotificationDetails(
      'channelId',
      'channelName',
      priority: Priority.high,
      importance: Importance.max,
    );
    var platformChannelSpecifics = NotificationDetails(
      android: androidDetails,
    );
    await FlutterLocalNotificationsPlugin().show(
      0,
      'worng'.tr(),
      'bus_approaching_you'.tr(),
      platformChannelSpecifics,
      payload: 'item x',
    );
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

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(
      const Duration(seconds: 10),
      (timer) {
        setState(
          () {
            notificationSent = false;
          },
        );
      },
    );

    viewBusPlace();

    _loadCarIcon();
    _getCurrentLocation();

    timer = Timer.periodic(
      const Duration(seconds: 10),
      (Timer timer) {
        _getUpdateCurrentLocation();
      },
    );
    getBusNumber();
    _initMessaging();

    Timer.periodic(
      const Duration(seconds: 10),
      (timer) {
        checkIfUserIsPassenger();
        checkIfUserIsShare();
      },
    );

    usernameFuture = getUsers();
    usernameFuture2 = getUsers2();
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

  Future<void> getBusNumber() async {
    setState(() {
      _isUploading = true;
    });

    // استعراض جميع الأرقام من 1 إلى 100 كمستندات
    for (int i = 1; i <= 100; i++) {
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('passengers')
          .doc(i.toString())
          .collection('student')
          .doc(userId)
          .get();

      if (studentDoc.exists) {
        setState(() {
          busnewNumber = studentDoc['busNumber'] ?? 0;
        });
        break; // الخروج من الحلقة إذا وجدنا الطالب
      }
    }

    setState(() {
      _isUploading = false;
    });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUsers() async {
    User user = FirebaseAuth.instance.currentUser!;
    String userId = user.uid;
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(userId)
        .collection('information')
        .doc(userId)
        .get();

    return snapshot;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getUsers2() async {
    User user = FirebaseAuth.instance.currentUser!;
    userId = user.uid; // Update userId
    return await usersRef
        .where(
          'email',
          isEqualTo: '${users.email}',
        )
        .get();
  }

  @override
  Widget build(BuildContext context) {
    User user = FirebaseAuth.instance.currentUser!;
    String userId = user.uid;

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
        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: usernameFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreenWait();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              String username = snapshot.data!['username'];
              String usertype = snapshot.data!['userType'];
              String imageuser = snapshot.data!['image'];
              String gender = snapshot.data!['gender'];
              String phone = snapshot.data!['phonenumber'];
              String living = snapshot.data!['living'];
              String age = snapshot.data!['age'];
              String college = snapshot.data!['college'];
              String specialization = snapshot.data!['specialization'];
              String academicYear = snapshot.data!['academic_year'];

              return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                future: usernameFuture2,
                builder: (context, snapshot) {
                  return Scaffold(
                    drawer: MyDrawer(
                      snapshot: snapshot,
                      drawemail: '${FirebaseAuth.instance.currentUser?.email}',
                      drawusername: username,
                      imageusers: imageuser,
                      detailsUser: () {
                        Navigator.pop(context);
                        Navigator.of(context).pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsUser(
                              userName: username,
                              userEmail:
                                  '${FirebaseAuth.instance.currentUser?.email}',
                              imageUsers: imageuser,
                              userId: FirebaseAuth.instance.currentUser!.uid,
                              gender: gender,
                              phone: phone,
                              living: living,
                              age: age,
                              college: college,
                              specialization: specialization,
                              academicYear: academicYear,
                            ),
                          ),
                        );
                      },
                    ),
                    appBar: StyleAppBar(
                      title: username,
                      actionBar: IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ViewBusSchedules(type: ''),
                              ),
                            );
                          },
                          icon: const Icon(Icons.list_alt)),
                    ),
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
                                          borderRadius:
                                              BorderRadius.circular(10.0.r),
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
                                          borderRadius:
                                              BorderRadius.circular(10.0.r),
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
                                const CircularProgressIndicator(
                                  color: Colors.blue,
                                ),
                              if (!_isUploading)
                                Expanded(
                                  flex: 3,
                                  child: SizedBox(
                                    height: 500.h,
                                    child: kIsWeb
                                        ? Container(
                                            color: const Color.fromARGB(
                                                255, 0, 14, 67),
                                            child: Center(
                                              child: Text(
                                                'error_show_map'.tr(),
                                                style: TextStyle(
                                                    fontSize: 23.sp,
                                                    color: Colors.red),
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
                                            initialCameraPosition:
                                                CameraPosition(
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (!isPassenger)
                                    if (!isShare)
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () async {
                                            if (mapController != null) {
                                              mapController!.dispose();
                                            }
                                            var status = await Permission
                                                .location
                                                .request();

                                            if (status ==
                                                PermissionStatus.granted) {
                                              Position position =
                                                  await Geolocator
                                                      .getCurrentPosition();
                                              setState(
                                                () {
                                                  _updateUserLocation(
                                                    position.latitude,
                                                    position.longitude,
                                                    username,
                                                  );

                                                  mapController!.animateCamera(
                                                    CameraUpdate.newLatLngZoom(
                                                      LatLng(
                                                        position.latitude,
                                                        position.longitude,
                                                      ),
                                                      17.0,
                                                    ),
                                                  );
                                                },
                                              );
                                            } else {
                                              ErrorOperator(
                                                errorMessage:
                                                    'location_permission_denied'
                                                        .tr(),
                                              );
                                            }
                                          },
                                          label: Text('share_location'.tr()),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 0, 14, 67),
                                            textStyle: const TextStyle(
                                              color: Colors.white,
                                            ),
                                            padding: EdgeInsets.all(15.w),
                                            foregroundColor: Colors.white,
                                          ),
                                          icon: const Icon(Icons.share),
                                        ),
                                      ),
                                  SizedBox(width: 7.w),
                                  if (!isPassenger)
                                    if (isShare)
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () async {
                                            markers.clear();
                                            await FirebaseFirestore.instance
                                                .collection('students')
                                                .doc(userId)
                                                .update({
                                              'isShare': 'false',
                                            });
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title:
                                                      Text('sucessfully'.tr()),
                                                  content: Text(
                                                      'delete_location_sucessfully'
                                                          .tr()),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                          'done_button'.tr()),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          label: Text('delete_location'.tr()),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 134, 2, 2),
                                            textStyle: const TextStyle(
                                              color: Colors.white,
                                            ),
                                            padding: EdgeInsets.all(15.w),
                                            foregroundColor: Colors.white,
                                          ),
                                          icon: const Icon(Icons.delete),
                                        ),
                                      ),
                                ],
                              ),
                              SizedBox(height: 20.h),
                              if (isPassenger)
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Report(
                                            studentName: username,
                                            userType: usertype,
                                          ),
                                        ),
                                      );
                                    },
                                    label: Text('report'.tr()),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color.fromARGB(255, 67, 0, 0),
                                      textStyle: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      padding: EdgeInsets.all(15.w),
                                      foregroundColor: Colors.white,
                                    ),
                                    icon: const Icon(Icons.list_alt),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    floatingActionButton: const MyFloatingActionButton(),
                  );
                },
              );
            } else {
              return const Center(
                child: SplashScreenWait(),
              );
            }
          },
        );
      },
    );
  }

  void _updateUserLocation(
      double latitude, double longitude, String username) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      // إضافة الموقع لقاعدة البيانات
      await _addUserLocationToFirestore(
        userId,
        latitude,
        longitude,
        username,
      );
      // تحديث الموقع للمستخدم في قاعدة البيانات
      await _updateUserLocationInDatabase(
        userId,
        latitude,
        longitude,
        username,
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('sucessfully'.tr()),
            content: Text('share_location_sucessfully'.tr()),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('done_button'.tr()),
              ),
            ],
          );
        },
      );
    }
  }

  void _updateUserLocationdirect(double latitude, double longitude) async {
    var studentDoc = await FirebaseFirestore.instance
        .collection('students')
        .doc(userId)
        .get();
    var isShare = studentDoc.get('isShare') == 'true';

    setState(() {
      this.isShare = isShare;
    });

    if (isShare == true && isPassenger == false) {
      DocumentReference locationReference =
          _firestore.collection('students').doc(userId);

      await locationReference.set({
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> _addUserLocationToFirestore(
      String userId, double latitude, double longitude, String username) async {
    DocumentReference locationReference = _firestore
        .collection('users')
        .doc(userId)
        .collection('location')
        .doc(userId);

    await locationReference.set({
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': FieldValue.serverTimestamp(),
      'username': username,
      'email': FirebaseAuth.instance.currentUser!.email,
      'isShare': 'true',
    }, SetOptions(merge: true));
  }

  Future<void> _updateUserLocationInDatabase(
      String userId, double latitude, double longitude, String username) async {
    DocumentReference locationReference2 =
        _firestore.collection('students').doc(userId);

    await locationReference2.set({
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': FieldValue.serverTimestamp(),
      'username': username,
      'email': FirebaseAuth.instance.currentUser!.email,
      'isShare': 'true',
    }, SetOptions(merge: true));
  }

  Future<void> _getUpdateCurrentLocation() async {
    var studentDoc = await FirebaseFirestore.instance
        .collection('students')
        .doc(userId)
        .get();
    var isShare = studentDoc.get('isShare') == 'true';

    setState(() {
      this.isShare = isShare;
    });

    if (isShare == true && isPassenger == false) {
      try {
        User user = FirebaseAuth.instance.currentUser!;
        String userId = user.uid;
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        // Check if the user is present in the locationStudent collection

        if (studentDoc.exists) {
          // If user exists in locationStudent, update the location
          await FirebaseFirestore.instance
              .collection('students')
              .doc(userId)
              .set({
            'latitude': position.latitude,
            'longitude': position.longitude,
            'timestamp': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      } catch (e) {
        ErrorOperator(errorMessage: '$e');
      }
    }
  }
}
