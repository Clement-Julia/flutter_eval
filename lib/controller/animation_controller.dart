import 'dart:async';

import 'package:flutter/material.dart';

class MyAnimationController extends StatefulWidget {
  int delay;
  Widget child;
  MyAnimationController({required this.child,required this.delay,super.key});

  @override
  State<MyAnimationController> createState() => _MyAnimationControllerState();
}

class _MyAnimationControllerState extends State<MyAnimationController> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> animationOffset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
      duration: const Duration(milliseconds: 1500)
    );
    CurvedAnimation curvedAnimation = CurvedAnimation(parent: _controller, curve: Curves.slowMiddle);
    animationOffset = Tween<Offset>(
      begin: const Offset(0, 5),
      end: Offset.zero
    ).animate(curvedAnimation);
    Timer(Duration(seconds: widget.delay), () {
      _controller.forward();
    });
    
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
        position: animationOffset,
      child: FadeTransition(
        opacity: _controller,
        child: widget.child,
      ),
    );
  }
}

