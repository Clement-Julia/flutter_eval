import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ipssisqy2023/class/FirestoreService.dart';
import 'package:ipssisqy2023/controller/firestore_helper.dart';
import 'package:ipssisqy2023/model/my_user.dart';

class CarteGoogle extends StatefulWidget {
  final Position location;

  CarteGoogle({Key? key, required this.location}) : super(key: key);

  @override
  State<CarteGoogle> createState() => _CarteGoogleState();
}

class _CarteGoogleState extends State<CarteGoogle> with SingleTickerProviderStateMixin {
  Completer<GoogleMapController> completer = Completer();
  late CameraPosition camera;
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  List<MyUser> users = [];

  @override
  void initState() {
    fetchUsers();
    camera = CameraPosition(target: LatLng(widget.location.latitude, widget.location.longitude), zoom: 14);
    super.initState();
  }

  Future<void> fetchUsers() async {
    FirestoreService firestoreService = FirestoreService();
    List<MyUser> fetchedUsers = await firestoreService.getUsers();
    setState(() {
      users = fetchedUsers;
    });
  }

  void addCustomIcon() {
    BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "assets/Location_marker.png")
        .then(
          (icon) {
        setState(() {
          markerIcon = icon;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: camera,
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      markers: createMarkers(),
      onMapCreated: (control) {
        completer.complete(control);
      },
    );
  }

  Set<Marker> createMarkers() {
    Set<Marker> markers = {};

    for (var user in users) {
      if (user.position != null) {
        markers.add(
          Marker(
            markerId: MarkerId(user.id),
            position: LatLng(user.position!.latitude, user.position!.longitude),
            icon: markerIcon,
            infoWindow: InfoWindow(
              title: user.fullName,
              snippet: "Messagerie >",
            ),
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => Messagerie(user: user),
              //   ),
              // );
            },
          ),
        );
      }
    }

    return markers;
  }
}
