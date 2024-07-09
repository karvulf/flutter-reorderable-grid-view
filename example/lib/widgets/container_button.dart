import 'package:flutter/material.dart';

class ContainerButton extends StatelessWidget {
  final GestureTapCallback onTap;
  final IconData icon;

  const ContainerButton({
    required this.onTap,
    required this.icon,
    super.key,
  });

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
