import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CarteGoogle extends StatefulWidget {
  late Position location;
  CarteGoogle({super.key, required this.location});

  @override
  State<CarteGoogle> createState() => _CarteGoogleState();
}

class _CarteGoogleState extends State<CarteGoogle> with SingleTickerProviderStateMixin {
  Completer<GoogleMapController> completer = Completer();
  late CameraPosition camera;

  @override
  void initState() {
    camera = CameraPosition(target: LatLng(widget.location.latitude, widget.location.longitude),zoom: 14);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
        initialCameraPosition: camera,
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        onMapCreated: (control){
          // String newStyle = await DefaultAssetBundle.of(context).loadString(key);
          completer.complete(control);
        }
    );
  }
}
