import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ipssisqy2023/model/my_user.dart';

class FirestoreService {
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('UTILISATEURS');

  Future<List<MyUser>> getUsers() async {
    List<MyUser> users = [];

    try {
      QuerySnapshot snapshot = await usersCollection.get();
      for (var doc in snapshot.docs) {
        MyUser user = MyUser(doc);
        users.add(user);
      }
    } catch (e) {
      print('Error fetching users: $e');
    }

    return users;
  }
}
