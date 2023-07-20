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
            icon: BitmapDescriptor.fromAssetImage(
              const ImageConfiguration(),
              user.avatar!, // Utilisez l'URL de l'avatar de l'utilisateur ici
            ),
            infoWindow: InfoWindow(
              title: user.fullName,
              snippet: "Cliquez pour voir plus de détails", // Vous pouvez personnaliser le texte de l'info-bulle ici
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
