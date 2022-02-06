import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnimatedOpacityChild extends StatefulWidget {
  final Widget child;

  const AnimatedOpacityChild({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  _AnimatedOpacityChildState createState() => _AnimatedOpacityChildState();
}

class _AnimatedOpacityChildState extends State<AnimatedOpacityChild> {
  var opacity = 0.0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: kThemeAnimationDuration,
      child: widget.child,
    );
  }
}
