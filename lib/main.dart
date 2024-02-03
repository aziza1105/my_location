import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _textEditingController = TextEditingController();
  TextEditingController _textEditingControllerLongitude = TextEditingController();
  Position? myPosition;
  Position? enteredPosition;
  double? distanceInMeters;

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied, we cannot request permissions.';
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _calculateDifference() async {
    try {
      myPosition = await _determinePosition();
      double enteredLatitude = double.tryParse(_textEditingController.text) ?? 0.0;
      double enteredLongitude =
          double.tryParse(_textEditingControllerLongitude.text) ?? 0.0;

      if (enteredLatitude == 0.0 || enteredLongitude == 0.0) {
        print('Please enter valid latitude and longitude values.');
        return;
      }

      enteredPosition = Position(
        latitude: enteredLatitude,
        longitude: enteredLongitude,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        floor: 0,
        isMocked: false,
      );

      if (myPosition != null && enteredPosition != null) {
        distanceInMeters = Geolocator.distanceBetween(
          myPosition!.latitude,
          myPosition!.longitude,
          enteredPosition!.latitude,
          enteredPosition!.longitude,
        );
      }

      setState(() {});
    } catch (e) {
      print('Error getting location: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'My current position is: ${myPosition?.latitude}, ${myPosition?.longitude} ',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Gap(5),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _calculateDifference();
                } catch (e) {
                  print('Error getting location: $e');
                }
              },
              child: const Icon(Icons.location_searching_rounded),
            ),
            const Gap(35),
            const Text(
              'Enter another position:',
              style: TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.w800,
                  fontSize: 25),
            ),
            const Gap(5),
            TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                labelText: 'Enter latitude',
                border: OutlineInputBorder(),
              ),
            ),
            const Gap(15),
            TextField(
              controller: _textEditingControllerLongitude,
              decoration: const InputDecoration(
                labelText: 'Enter longitude',
                border: OutlineInputBorder(),
              ),
            ),
            const Gap(5),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _calculateDifference();
                } catch (e) {
                  print('Error getting location: $e');
                }
              },
              child: const Text('Submit'),
            ),
            const Gap(50),
            Text(
              'Entered position is: : ${enteredPosition?.latitude}, ${enteredPosition?.longitude} ',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (distanceInMeters != null)
              const Gap(20),
              Text(
                'Difference between positions: ${distanceInMeters?.toStringAsFixed(2)} meters',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
          ],
        ),
      ),
    );
  }
}
