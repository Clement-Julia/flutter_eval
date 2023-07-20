import 'package:flutter/material.dart';
import 'package:ipssisqy2023/controller/custom_path.dart';
import 'package:ipssisqy2023/globale.dart';

class MyBackground extends StatefulWidget {
  const MyBackground({super.key});

  @override
  State<MyBackground> createState() => _MyBackgroundState();
}

class _MyBackgroundState extends State<MyBackground> with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: MyCustomPath(),
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            // image: AssetImage("assets/undetale.jpg"),
            image: NetworkImage("https://img.freepik.com/free-vector/abstract-dirty-grunge-tire-marks_1017-17011.jpg?w=2000"),
            fit: BoxFit.fill
          )
        ),
        // color:  Colors.black
      ),
    );
  }
}
