

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ipssisqy2023/controller/firestore_helper.dart';
import 'package:ipssisqy2023/globale.dart';

class MyUser {
  late String id;
  late String mail;
  late String nom;
  late String prenom;
  String? pseudo;
  DateTime? birthday;
  String? avatar;
  Gender genre = Gender.indefini;
  GeoPoint? position;
  List? favoris;
  List? conversation;

  String get fullName {
    return prenom + " "+ nom;
  }


  //
  MyUser.empty(){
    id = "";
    mail = "";
    nom = "";
    prenom = "";
  }

  MyUser(DocumentSnapshot snapshot){
    id = snapshot.id;
    Map<String,dynamic> map = snapshot.data() as Map<String,dynamic>;
    mail = map["EMAIL"];
    nom = map["NOM"];
    prenom = map["PRENOM"];
    String? provisoirePseudo =  map["PSEUDO"];
    favoris = map["FAVORIS"] ?? [];
    if(provisoirePseudo == null){
      pseudo = "";
    }
    else
      {
        pseudo = provisoirePseudo;
      }

    Timestamp? birthdaytprovisoire = map["BIRTHDAY"];
    if(birthdaytprovisoire == null){
      birthday = DateTime.now();
    }
    else
      {
        birthday = birthdaytprovisoire.toDate();
      }

    avatar = map["AVATAR"] ?? defaultImage;
    conversation = map["CONVERSATION"] ?? [];

    GeoPoint? geoPoint = map["POSITION"];
    if (geoPoint != null) {
      position = geoPoint;
    }
  }

  List<String> getUniqueRecipients() {
    final List<String> recipients = [];
    for (final message in me.conversation!) {
      final String recipientId = message['sentTo'];
      if (!recipients.contains(recipientId)) {
        recipients.add(recipientId);
      }
    }
    return recipients;
  }

  Future<String?> getLastMessageWithRecipient(String recipientId) async {
    MyUser user = await FirestoreHelper().getUser(recipientId);
    final List<dynamic> allMessages = [...user.conversation!, ...me.conversation!];
    final List<dynamic> recipientMessages = allMessages
        .where((message) => message['sentBy'] == recipientId || message['sentTo'] == recipientId)
        .toList();

    if (recipientMessages.isEmpty) {
      return null;
    }

    recipientMessages.sort((a, b) => b['date'].compareTo(a['date']));
    return recipientMessages.first['message'];
  }
}