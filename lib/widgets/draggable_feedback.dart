import 'package:flutter/material.dart';

class DraggableFeedback extends StatefulWidget {
  final Widget child;
  final Size size;
  final Animation<Decoration> decoration;
  final double feedbackScaleFactor;
  final VoidCallback onDeactivate;

  const DraggableFeedback({
    required this.child,
    required this.size,
    required this.decoration,
    required this.feedbackScaleFactor,
    required this.onDeactivate,
    Key? key,
  }) : super(key: key);

  @override
  State<DraggableFeedback> createState() => _DraggableFeedbackState();
}

class _DraggableFeedbackState extends State<DraggableFeedback> {
  /// The initial size of the feedback widget.
  ///
  /// This size can expand to visually indicate that the drag operation has started.
  late Size _size = widget.size;

  /// The offset ensures that the feedback widget, when scaled, remains centered.
  Offset _offset = Offset.zero;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scaleAndCenterFeedback();
    });
  }

  @override
  void deactivate() {
    widget.onDeactivate();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent, // removes white corners when having shadow
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: _size.height,
        width: _size.width,
        transform: Matrix4.translationValues(_offset.dx, _offset.dy, 0.0),
        child: DecoratedBoxTransition(
          position: DecorationPosition.background,
          decoration: widget.decoration,
          child: widget.child,
        ),
      ),
    );
  }

  void _scaleAndCenterFeedback() {
    final feedbackSize = _size * widget.feedbackScaleFactor;
    final offsetToCenterFeedback = Offset(
      -(feedbackSize.width - _size.width) / 2,
      -(feedbackSize.height - _size.height) / 2,
    );

    setState(() {
      _size = feedbackSize;
      _offset = offsetToCenterFeedback;
    });
  }
}
