import 'package:flutter/material.dart';
import 'package:ipssisqy2023/controller/my_permission.dart';
import 'package:ipssisqy2023/view/loading_view.dart';
import 'package:ipssisqy2023/view/resgister_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  MyPermissionPhoto().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyRegisterView(),
      debugShowCheckedModeBanner: false,
    );
  }
}


