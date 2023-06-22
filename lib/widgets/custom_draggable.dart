import 'package:flutter/cupertino.dart';

class CustomDraggable extends StatelessWidget {
  final Widget child;
  final Object? data;

  const CustomDraggable({
    required this.child,
    this.data,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
