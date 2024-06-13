import 'package:flutter/material.dart';
import 'package:social_notes/resources/colors.dart';

class AnimatedText extends StatefulWidget {
  const AnimatedText({super.key});

  @override
  State<AnimatedText> createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText> {
  double _offset = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnimation();
    });
  }

  void _startAnimation() {
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _offset = -MediaQuery.of(context).size.width * 0.87;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Center(
      child: SizedBox(
        width: size.width * 0.87,
        height: 40,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: _offset),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(value, 0.0),
              child: child,
            );
          },
          child: Text(
            'Wanted to welcome',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, color: whiteColor),
          ),
        ),
      ),
    );
  }
}
