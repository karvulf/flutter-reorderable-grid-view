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
  bool _disableAnimations = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scaleAndCenterFeedback();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _disableAnimations = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  }

  @override
  void deactivate() {
    widget.onDeactivate();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final size = _disableAnimations ? _feedbackSize : _size;
    final offset = _disableAnimations ? _feedbackOffset : _offset;

    return Material(
      color: Colors.transparent, // removes white corners when having shadow
      child: AnimatedContainer(
        duration: _animationDuration,
        height: size.height,
        width: size.width,
        transform: Matrix4.translationValues(offset.dx, offset.dy, 0.0),
        child: DecoratedBoxTransition(
          position: DecorationPosition.background,
          decoration: widget.decoration,
          child: widget.child,
        ),
      ),
    );
  }

  /// Updates size and offset of [widget.child].
  ///
  /// By changing the size, it is more clear that the dragging of [widget.child]
  /// has started. Because the size change, also the offset has to be changed
  /// to ensure that the widget is still centered.
  void _scaleAndCenterFeedback() {
    if (_disableAnimations) {
      return;
    }

    setState(() {
      _size = _feedbackSize;
      _offset = _feedbackOffset;
    });
  }

  Size get _feedbackSize => widget.size * widget.feedbackScaleFactor;

  Offset get _feedbackOffset {
    final feedbackSize = _feedbackSize;
    return Offset(
      -(feedbackSize.width - widget.size.width) / 2,
      -(feedbackSize.height - widget.size.height) / 2,
    );
  }

  Duration get _animationDuration {
    if (_disableAnimations) {
      return Duration.zero;
    }
    return const Duration(milliseconds: 150);
  }
}
