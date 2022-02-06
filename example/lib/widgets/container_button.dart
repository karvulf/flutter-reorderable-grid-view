import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ContainerButton extends StatelessWidget {
  final GestureTapCallback onTap;
  final IconData icon;
  final Color color;

  const ContainerButton({
    required this.onTap,
    required this.icon,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.lightBlue,
        height: 50,
        width: 50,
        child: Center(
          child: Icon(
            icon,
            size: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
