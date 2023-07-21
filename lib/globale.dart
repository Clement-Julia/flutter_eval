import 'package:ipssisqy2023/model/my_user.dart';
import 'package:permission_handler/permission_handler.dart';

enum Gender {homme,femme,transgenre,indefini}
enum MessageMenuAction {copy,edit,delete}

MyUser me = MyUser.empty();
String defaultImage = "https://www.stickpng.com/assets/thumbs/585e4beacb11b227491c3399.png";
