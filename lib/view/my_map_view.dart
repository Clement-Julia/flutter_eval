import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ipssisqy2023/controller/permission_gps.dart';
import 'package:ipssisqy2023/view/google_carte.dart';

class MyMapView extends StatefulWidget {
  const MyMapView({super.key});

  @override
  State<MyMapView> createState() => _MyMapViewState();
}

class _MyMapViewState extends State<MyMapView> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Position>(
      future: PermissionGps().init(),
      builder: (context, snap){
        if(snap.data == null){
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          Position location = snap.data!;
          return CarteGoogle(location: location);
        }
      },
    );
  }
}
