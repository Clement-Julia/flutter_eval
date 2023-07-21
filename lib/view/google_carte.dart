import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ipssisqy2023/class/FirestoreService.dart';
import 'package:ipssisqy2023/controller/firestore_helper.dart';
import 'package:ipssisqy2023/controller/preview_user.dart';
import 'package:ipssisqy2023/model/my_user.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'dart:ui' as ui;

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
    return FutureBuilder<Set<Marker>>(
      future: createMarkers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasData) {
          return GoogleMap(
            initialCameraPosition: camera,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            markers: snapshot.data!,
            onMapCreated: (control) {
              completer.complete(control);
            },
          );
        } else {
          return Center(
            child: Text("Pas de données"),
          );
        }
      },
    );
  }

  Future<Set<Marker>> createMarkers() async {
    Set<Marker> markers = {};

    for (var user in users) {
      print(user.fullName);
      print(user.avatar);
      if (user.position != null) {
        BitmapDescriptor? icon;
        if (user.avatar != null) {
          final Uint8List imageData = await createMarkerIcon(user.avatar!, Size(120, 120));
          icon = BitmapDescriptor.fromBytes(imageData);
        } else {
          icon = BitmapDescriptor.defaultMarker;
        }

        markers.add(
          Marker(
            markerId: MarkerId(user.id),
            position: LatLng(user.position!.latitude, user.position!.longitude),
            icon: icon,
            infoWindow: InfoWindow(
              title: user.fullName,
              snippet: "Voir le profil",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PreviewUser(utilisateur: user),
                  ),
                );
              },
            ),
          ),
        );
      }
    }

    return markers;
  }

  Future<Uint8List> createMarkerIcon(String avatarUrl, Size size) async {
    try {
      final response = await http.get(Uri.parse(avatarUrl));
      if (response.statusCode == 200) {
        final byteData = ByteData.view(response.bodyBytes.buffer);
        final codec = await ui.instantiateImageCodec(byteData.buffer.asUint8List(), targetHeight: size.height.toInt(), targetWidth: size.width.toInt());
        final frame = await codec.getNextFrame();
        final image = await frame.image.toByteData(format: ui.ImageByteFormat.png);
        return image!.buffer.asUint8List();
      } else {
        final ByteData byteData = await rootBundle.load("assets/default_marker.png");
        return byteData.buffer.asUint8List();
      }
    } catch (e) {
      print("Erreur lors du chargement de l'image : $e");
      final ByteData byteData = await rootBundle.load("assets/default_marker.png");
      return byteData.buffer.asUint8List();
    }
  }
}
