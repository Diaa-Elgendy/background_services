import 'dart:async';
import 'dart:math';

import 'package:background_services/notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Location location = Location();

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  @override
  void initState() {
    super.initState();
    Noti.initialize(flutterLocalNotificationsPlugin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            child: const Text('Get My Location'),
            onPressed: () async {
              bool serviceEnabled;
              PermissionStatus permissionGranted;
              LocationData placeLocation;
              LocationData myLocation;

              serviceEnabled = await location.serviceEnabled();
              if (!serviceEnabled) {
                serviceEnabled = await location.requestService();
                if (!serviceEnabled) {
                  return;
                }
              }

              permissionGranted = await location.hasPermission();
              if (permissionGranted == PermissionStatus.denied) {
                permissionGranted = await location.requestPermission();
                if (permissionGranted != PermissionStatus.granted) {
                  return;
                }
              }

              myLocation = await location.getLocation();
              placeLocation = myLocation;
              location.changeSettings(accuracy: LocationAccuracy.high);
              location.enableBackgroundMode(enable: true);
              int ctr = 0;

              // var _distanceInMeters = await Geolocator.distanceBetween(
              //   myLocation.latitude!,
              //   myLocation.longitude!,
              //   placeLocation.latitude!,
              //   placeLocation.longitude!,
              // );

              // print('Distance: $_distanceInMeters');

              location.onLocationChanged.listen((LocationData currentLocation) {
                // Use current location
                ctr++;
                double diff = calculateDistance(
                        myLocation.latitude!,
                        myLocation.longitude!,
                        placeLocation.latitude!,
                        placeLocation.longitude!) *
                    1000;
                print(
                    'Location Changed $ctr - long:${currentLocation.longitude} lat:${currentLocation.latitude}');
                Noti.showBigTextNotification(
                  title:
                      '$ctr long:${currentLocation.longitude} lat:${currentLocation.latitude}',
                  body: 'difference: $diff',
                  fln: flutterLocalNotificationsPlugin,
                );
              });
            },
          ),
          ElevatedButton(
            child: const Text('Dispose Location Services'),
            onPressed: () async {
              location.enableBackgroundMode(enable: false);
            },
          ),
          ElevatedButton(
            child: const Text('Show Notification'),
            onPressed: () async {
              Noti.showBigTextNotification(
                  title: 'Title',
                  body: 'Notification Body',
                  fln: flutterLocalNotificationsPlugin);
            },
          ),
        ],
      ),
    );
  }
}
