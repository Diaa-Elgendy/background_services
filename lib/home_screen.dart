import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:workmanager/workmanager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text('Click'),
          onPressed: () async {
            // Workmanager().registerPeriodicTask(
            //   'uniqueName',
            //   'taskName',
            //   frequency: const Duration(seconds: 2),
            //
            // );
            Location location = Location();

            bool serviceEnabled;
            PermissionStatus permissionGranted;
            LocationData _locationData;

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

            _locationData = await location.getLocation();
            location.enableBackgroundMode(enable: true);
            int ctr = 0;
            // Timer.periodic(const Duration(seconds: 10), (timer) {
            //   ctr++;
            //   print('${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}  , location:${_locationData.accuracy}');
            // });
            location.onLocationChanged.listen((LocationData currentLocation) {
              // Use current location
              ctr++;
              print('Location Changed $ctr - long:${currentLocation.longitude} lat:${currentLocation.latitude}');
            });
          },
        ),
      ),
    );
  }
}
