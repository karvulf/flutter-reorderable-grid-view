import 'dart:async';

import 'package:flutter/cupertino.dart';

class ReorderableScrollingListener extends StatefulWidget {
  final Widget child;
  final bool isDragging;
  final double automaticScrollExtent;

  final PointerMoveEventListener onDragUpdate;
  final VoidCallback onDragEnd;
  final void Function(double scrollPixels) onScrollUpdate;

  final GlobalKey? scrollableContentKey;
  final ScrollController? scrollController;

  const ReorderableScrollingListener({
    required this.child,
    required this.isDragging,
    required this.automaticScrollExtent,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onScrollUpdate,
    required this.scrollableContentKey,
    required this.scrollController,
    Key? key,
  }) : super(key: key);

  @override
  State<ReorderableScrollingListener> createState() =>
      _ReorderableScrollingListenerState();
}

class _ReorderableScrollingListenerState
    extends State<ReorderableScrollingListener> {
  double _scrollPositionPixels = 0.0;

  Timer? _scrollCheckTimer;
  Size? _childSize;
  Offset? _childOffset;

  @override
  void didUpdateWidget(covariant ReorderableScrollingListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDragging != oldWidget.isDragging && widget.isDragging) {
      _updateChildSizeAndOffset();
      setState(() {
        _scrollPositionPixels = _scrollPixels;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerMove: (details) {
        if (widget.isDragging) {
          _handleDragUpdate(details);
        }
      },
      onPointerUp: (details) {
        if (widget.isDragging) {
          widget.onDragEnd();
        }
      },
      child: widget.child,
    );
  }

  /// Always called when the user moves the dragged child around.
  void _handleDragUpdate(PointerMoveEvent details) {
    if (widget.scrollableContentKey != null &&
        widget.scrollController != null) {
      final position = details.position;
      _scrollCheckTimer?.cancel();
      _scrollCheckTimer = Timer.periodic(
        const Duration(milliseconds: 10),
        (timer) {
          if (widget.isDragging) {
            _checkToScrollWhileDragging(dragPosition: position);
          } else {
            timer.cancel();
          }
        },
      );
    }

    widget.onDragUpdate(details);
  }

  void _checkToScrollWhileDragging({
    required Offset dragPosition,
  }) {
    // prevents dragging if timer is still active but isDragging is false
    if (!widget.isDragging) {
      _scrollCheckTimer?.cancel();
    }

    final size = _childSize;
    final offset = _childOffset;

    if (size != null && offset != null) {
      final allowedRange = widget.automaticScrollExtent;
      final minDy = offset.dy + allowedRange;
      final maxDy = offset.dy + size.height - allowedRange;
      const variance = 5;

      if (dragPosition.dy <= minDy && _scrollPositionPixels > 0) {
        _scrollPositionPixels -= variance;
        _scrollTo(dy: _scrollPositionPixels);
      } else if (dragPosition.dy >= maxDy &&
          _scrollPositionPixels <
              widget.scrollController!.position.maxScrollExtent) {
        _scrollPositionPixels += variance;
        // print('scroll to bottom if possible with scroll $_scrollPositionPixels!!!');
        _scrollTo(dy: _scrollPositionPixels);
      }
    }
  }

  void _scrollTo({required double dy}) {
    final scrollController = widget.scrollController;

    if (scrollController != null && scrollController.hasClients) {
      // end _scrollController.position.maxScrollExtent
      scrollController.jumpTo(dy);
      /*
      scrollController.animateTo(
        dy,
        duration: const Duration(milliseconds: 50),
        curve: Curves.ease,
      );
       */
      widget.onScrollUpdate(dy);
    }
  }

  void _updateChildSizeAndOffset() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      final renderBox = widget.scrollableContentKey?.currentContext
          ?.findRenderObject() as RenderBox?;

      if (renderBox != null) {
        _childOffset = renderBox.localToGlobal(Offset.zero);
        _childSize = renderBox.size;
      }
    });
  }

  /// Returning the current scroll position depending on [widget.scrollController] and [context].
  ///
  /// If the scroll position of [context] or [widget.scrollController] is accessible,
  /// then the value of the current position is returned.
  ///
  /// Otherwise 0.0.
  double get _scrollPixels {
    var pixels = Scrollable.of(context)?.position.pixels;
    final scrollController = widget.scrollController;

    if (pixels != null) {
      return pixels;
    } else if (scrollController != null && scrollController.hasClients) {
      return scrollController.position.pixels;
    } else {
      return 0.0;
    }
  }
}
