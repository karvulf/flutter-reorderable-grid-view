import 'dart:async';

import 'package:flutter/cupertino.dart';

/// Uses [Listener] to indicate position updates while dragging a child and enables an autoscroll functionality.
class ReorderableScrollingListener extends StatefulWidget {
  final Widget child;
  final bool isDragging;
  final double automaticScrollExtent;

  final PointerMoveEventListener onDragUpdate;
  final VoidCallback onDragEnd;

  /// Called when the current scrolling position changes.
  final void Function(double scrollPixels) onScrollUpdate;

  /// Should be the key of the added [GridView].
  final GlobalKey? scrollableContentKey;

  /// Should be the [ScrollController] of the [GridView].
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
  /// Describes current scroll position in pixels.
  double _scrollPositionPixels = 0.0;

  /// Repeating timer to ensure that autoscroll also works when the user doesn't the dragged child.
  Timer? _scrollCheckTimer;

  /// [Size] of the child that was found in [widget.scrollableContentKey].
  Size? _childSize;

  /// [Offset] of the child that was found in [widget.scrollableContentKey].
  Offset? _childOffset;

  @override
  void didUpdateWidget(covariant ReorderableScrollingListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDragging != oldWidget.isDragging) {
      if (widget.isDragging) {
        _updateChildSizeAndOffset();
        setState(() {
          _scrollPositionPixels = _scrollPixels;
        });
      }
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
  ///
  /// If there is a [widget.scrollableContentKey] and [widget.scrollController],
  /// then the autoscroll is starting by creating a repeating timer that calls
  /// himself every 10 ms to check if widget of [widget.scrollableContentKey]
  /// can be scrolled up or down.
  ///
  /// The timer cancels himself before recreating a new one and to ensure that
  /// no timer is ongoing when the [widget.isDragging] stopped, it checks also himself
  /// if it has to be canceled.
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

  /// Checks if [widget.scrollController] can scrolling up or down depending on [widget.automaticScrollExtent].
  ///
  /// This only works if [widget.scrollableContentKey] is not null. By defining
  /// a range ([widget.automaticScrollExtent]) that should trigger the autoscroll,
  /// it is checked whether to scroll down or up depending on the current [dragPosition].
  void _checkToScrollWhileDragging({required Offset dragPosition}) {
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
        _scrollTo(dy: _scrollPositionPixels);
      }
    }
  }

  /// Scrolling to the specified [dy] using [widget.scrollController].
  void _scrollTo({required double dy}) {
    final scrollController = widget.scrollController;

    if (scrollController != null && scrollController.hasClients) {
      scrollController.jumpTo(dy);
      widget.onScrollUpdate(dy);
    }
  }

  /// Updates [_childOffset] and [_childSize] using the values defined in [widget.scrollableContentKey].
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
