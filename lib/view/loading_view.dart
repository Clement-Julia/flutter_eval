import 'package:flutter/material.dart';
import 'package:ipssisqy2023/view/resgister_view.dart';
import 'package:lottie/lottie.dart';

class MyLoading extends StatefulWidget {
  const MyLoading({super.key});

  @override
  State<MyLoading> createState() => _MyLoadingState();
}

class _MyLoadingState extends State<MyLoading> with SingleTickerProviderStateMixin {
  PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: PageView(
          controller: pageController,
          children: [
            Center(
              child: Lottie.asset("assets/animation_lk9q9z9s.json"),
            ),
            Center(
              child: Lottie.asset("assets/Animation - 1689771292734.json"),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyRegisterView()), // Remplace "NextPage" par le nom de ta page de destination
                );
              },
              child: Center(
                child: Lottie.asset("assets/animation_lk9rjl01.json"),
              ),
            ),
          ],
        ),
    );
  }
}
