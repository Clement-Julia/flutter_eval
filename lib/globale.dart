import 'package:ipssisqy2023/model/my_user.dart';
import 'package:permission_handler/permission_handler.dart';

enum Gender {homme,femme,transgenre,indefini}
enum MessageMenuAction {copy,edit,delete}

MyUser me = MyUser.empty();
String defaultImage = "https://tse1.mm.bing.net/th?id=OIP.zRmpjD_EOxCboGENHfjxHAHaEc&pid=Api";
