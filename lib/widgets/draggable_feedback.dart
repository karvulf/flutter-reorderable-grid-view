import 'package:flutter/material.dart';

class DraggableFeedback extends StatefulWidget {
  final Widget child;
  final Size size;
  final Animation<Decoration> decoration;
  final VoidCallback onDeactivate;

  const DraggableFeedback({
    required this.child,
    required this.size,
    required this.decoration,
    required this.onDeactivate,
    Key? key,
  }) : super(key: key);

  @override
  State<DraggableFeedback> createState() => _DraggableFeedbackState();
}

class _DraggableFeedbackState extends State<DraggableFeedback> {
  @override
  void deactivate() {
    widget.onDeactivate();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;

    return Material(
      color: Colors.transparent, // removes white corners when having shadow
      child: SizedBox(
        height: size.height,
        width: size.width,
        child: DecoratedBoxTransition(
          position: DecorationPosition.background,
          decoration: widget.decoration,
          child: widget.child,
        ),
      ),
    );
  }
}
