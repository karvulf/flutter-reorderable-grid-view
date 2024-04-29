import 'dart:async';

import 'package:flutter/cupertino.dart';

/// Uses [Listener] to indicate position updates while dragging a child and enables an autoscroll functionality.
class ReorderableScrollingListener extends StatefulWidget {
  /// [child] added to build method.
  final Widget child;

  /// Indicator if the user is using drag and drop.
  final bool isDragging;

  /// Indicator when the scrolling should start.
  ///
  /// The scrolling can be triggered earlier. That means if the dragged item
  /// is almost in the end of the visible area, the scroll would start.
  /// If [automaticScrollExtent] has a higher value, the scroll would start earlier.
  final double automaticScrollExtent;

  /// Enables the functionality to scroll while dragging a child to the top or bottom.
  final bool enableScrollingWhileDragging;

  /// Callback when the offset of the tapped area is changing.
  final PointerMoveEventListener onDragUpdate;

  /// Called when the current scrolling position changes.
  final void Function(Offset scrollOffset) onScrollUpdate;

  final Offset Function() getScrollOffset;

  /// Should be the key of the added [GridView].
  final GlobalKey? reorderableChildKey;

  /// Should be the [ScrollController] of the [GridView].
  final ScrollController? scrollController;

  const ReorderableScrollingListener({
    required this.child,
    required this.isDragging,
    required this.enableScrollingWhileDragging,
    required this.automaticScrollExtent,
    required this.onDragUpdate,
    required this.onScrollUpdate,
    required this.getScrollOffset,
    required this.reorderableChildKey,
    required this.scrollController,
    Key? key,
  }) : super(key: key);

  @override
  State<ReorderableScrollingListener> createState() =>
      _ReorderableScrollingListenerState();
}

class _ReorderableScrollingListenerState
    extends State<ReorderableScrollingListener> {
  /// If true, the widget outside of [ReorderableBuilder] is scrollable and not the widget inside ([GridView])
  bool _isScrollableOutside = false;

  /// Describes current scroll offset.
  ///
  /// Either dx or dy has a scroll position.
  Offset _scrollOffset = Offset.zero;

  /// Repeating timer to ensure that autoscroll also works when the user doesn't the dragged child.
  Timer? _scrollCheckTimer;

  /// [Size] of the child that was found in [widget.reorderableChildKey].
  Size? _childSize;

  /// [Offset] of the child that was found in [widget.reorderableChildKey].
  Offset? _childOffset;

  @override
  void didUpdateWidget(covariant ReorderableScrollingListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDragging != oldWidget.isDragging && widget.isDragging) {
      _updateChildSizeAndOffset();
      setState(() {
        _scrollOffset = widget.getScrollOffset();
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
      child: widget.child,
    );
  }

  /// Always called when the user moves the dragged child around.
  ///
  /// If there is a [widget.reorderableChildKey] and [widget.scrollController],
  /// then the autoscroll is starting by creating a repeating timer that calls
  /// himself every 10 ms to check if widget of [widget.reorderableChildKey]
  /// can be scrolled up or down.
  ///
  /// The timer cancels himself before recreating a new one and to ensure that
  /// no timer is ongoing when the [widget.isDragging] stopped, it checks also himself
  /// if it has to be canceled.
  void _handleDragUpdate(PointerMoveEvent details) {
    if (widget.enableScrollingWhileDragging &&
        widget.reorderableChildKey != null &&
        widget.scrollController != null) {
      final position = details.position;

      _scrollCheckTimer?.cancel();
      _scrollCheckTimer = Timer.periodic(
        const Duration(milliseconds: 10),
        (timer) {
          if (widget.isDragging) {
            _checkToScrollWhileDragging(
              dragPosition: position,
              scrollDirection: widget.scrollController!.position.axis,
            );
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
  /// This only works if [widget.reorderableChildKey] is not null. By defining
  /// a range ([widget.automaticScrollExtent]) that should trigger the autoscroll,
  /// it is checked whether to scroll down or up depending on the current [dragPosition].
  void _checkToScrollWhileDragging({
    required Offset dragPosition,
    required Axis scrollDirection,
  }) {
    final childSize = _childSize;
    final childOffset = _childOffset;

    if (childSize != null && childOffset != null) {
      final allowedRange = widget.automaticScrollExtent;
      late Offset minOffset;
      final maxOffset = Offset(
        childOffset.dx + childSize.width - allowedRange,
        childOffset.dy + childSize.height - allowedRange,
      );

      // minDy can be different when having the scrollable outside ReorderableBuilder
      // at the beginning the childOffset dy would be the correct minDy
      // but while scrolling this would lead to 0 and is important to trigger the automatic scroll at the right moment
      if (_isScrollableOutside) {
        minOffset = childOffset - _scrollOffset;
        if (_compareOffsets(
            bigger: Offset.zero,
            smaller: minOffset,
            scrollDirection: scrollDirection)) {
          minOffset = Offset.zero;
        }
        minOffset = Offset(
          minOffset.dx != 0.0 ? minOffset.dx + allowedRange : 0.0,
          minOffset.dy != 0.0 ? minOffset.dy + allowedRange : 0.0,
        );
      } else {
        minOffset = Offset(
          childOffset.dx + allowedRange,
          childOffset.dy + allowedRange,
        );
      }

      const variance = 5.0;

      final maxScrollExtent = widget.scrollController!.position.maxScrollExtent;

      // scroll to top/left
      if (_compareOffsets(
              bigger: minOffset,
              smaller: dragPosition,
              scrollDirection: scrollDirection) &&
          _compareOffsets(
              bigger: _scrollOffset,
              smaller: Offset.zero,
              scrollDirection: scrollDirection)) {
        _scrollOffset = _updateScrollOffset(
          variance: -variance,
          scrollDirection: scrollDirection,
        );
        _scrollTo(scrollOffset: _scrollOffset);
      } else if (_compareOffsets(
              bigger: dragPosition,
              smaller: maxOffset,
              scrollDirection: scrollDirection) &&
          _compareOffsets(
              bigger: Offset(maxScrollExtent, maxScrollExtent),
              smaller: _scrollOffset,
              scrollDirection: scrollDirection)) {
        _scrollOffset = _updateScrollOffset(
          variance: variance,
          scrollDirection: scrollDirection,
        );
        _scrollTo(scrollOffset: _scrollOffset);
      }
    }
  }

  /// Scrolling vertical or horizontal using [widget.scrollController].
  void _scrollTo({required Offset scrollOffset}) {
    final scrollController = widget.scrollController;

    if (scrollController != null && scrollController.hasClients) {
      final value = scrollOffset.dx > 0 ? scrollOffset.dx : scrollOffset.dy;
      scrollController.jumpTo(value);
      widget.onScrollUpdate(scrollOffset);
    }
  }

  /// Updates [_childOffset] and [_childSize] using the values defined in [widget.reorderableChildKey].
  ///
  /// There are two ways when scrolling. It is possible that the [GridView] is scrollable
  /// or a parent widget.
  /// To ensure that the parent widget is the scrollable part, the [GridView] has
  /// to have more height than the screen size. This is an indicator that the [GridView]
  /// is not scrollable.
  /// If that is the case, then the size of the [GridView] is calculated with the
  /// height of the screen and the current offset.dy of the [GridView].
  void _updateChildSizeAndOffset() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scrollDirection = widget.scrollController?.position.axis;

      // scrolling while dragging won't be possible
      if (scrollDirection == null) return;

      final currentContext = widget.reorderableChildKey?.currentContext;
      final reorderableChildRenderBox =
          currentContext?.findRenderObject() as RenderBox?;
      final screenSize = MediaQuery.of(context).size;

      if (reorderableChildRenderBox != null) {
        var reorderableChildOffset =
            reorderableChildRenderBox.localToGlobal(Offset.zero);

        // a scrollable widget is outside when there was found one, probably not the best solution to detect that
        _isScrollableOutside =
            Scrollable.maybeOf(context)?.position.pixels != null;

        if (_isScrollableOutside) {
          reorderableChildOffset += widget.getScrollOffset();
        }

        final reorderableChildSize = reorderableChildRenderBox.size;

        if (_compareOffsets(
            bigger: Offset(
                reorderableChildOffset.dx + reorderableChildSize.width,
                reorderableChildOffset.dy + reorderableChildSize.height),
            smaller: Offset(screenSize.width, screenSize.height),
            scrollDirection: scrollDirection)) {
          _childSize = Size(
            screenSize.width - reorderableChildOffset.dx,
            screenSize.height - reorderableChildOffset.dy,
          );
        } else {
          _childSize = reorderableChildSize;
        }
        _childOffset = reorderableChildOffset;
      }
    });
  }

  /// Depending on [scrollDirection], [_scrollOffset] will be updated in x- or y-direction.
  Offset _updateScrollOffset({
    required double variance,
    required Axis scrollDirection,
  }) {
    late final Offset updatedOffset;

    if (scrollDirection == Axis.horizontal) {
      updatedOffset = _scrollOffset + Offset(variance, 0.0);
    } else {
      updatedOffset = _scrollOffset + Offset(0.0, variance);
    }

    return updatedOffset;
  }

  bool _compareOffsets({
    required Offset bigger,
    required Offset smaller,
    required Axis scrollDirection,
  }) {
    if (scrollDirection == Axis.vertical) {
      return bigger.dy > smaller.dy;
    } else {
      return bigger.dx > smaller.dx;
    }
  }
}
