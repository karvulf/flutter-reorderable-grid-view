import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/utils/reorderable_scrollable.dart';

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

  /// Manages the case where the order of children is reversed.
  final bool reverse;

  /// Should be the key of the added [GridView].
  final GlobalKey? reorderableChildKey;

  /// Should be the [ScrollController] of the [GridView].
  final ScrollController? scrollController;

  const ReorderableScrollingListener({
    required this.child,
    required this.isDragging,
    required this.enableScrollingWhileDragging,
    required this.automaticScrollExtent,
    required this.reverse,
    required this.onDragUpdate,
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      // fix for android release mode, otherwise dragging won't work correctly (since flutter 3.22.0)
      behavior: HitTestBehavior.deferToChild,
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
    final scrollDirection = _reorderableScrollable.scrollDirection;

    if (widget.enableScrollingWhileDragging &&
        widget.reorderableChildKey != null &&
        scrollDirection != null) {
      final position = details.localPosition;

      _scrollCheckTimer?.cancel();
      _scrollCheckTimer = Timer.periodic(
        const Duration(milliseconds: 10),
        (timer) {
          if (widget.isDragging) {
            _checkToScrollWhileDragging(
              dragPosition: position,
              scrollDirection: scrollDirection,
            );
          } else {
            timer.cancel();
          }
        },
      );
    }

    widget.onDragUpdate(details);
  }

  /// Depending on [dragPosition] a scroll will be triggered.
  ///
  /// Scrolls if [dragPosition] is within the area which is allowed to start
  /// the scroll.
  void _checkToScrollWhileDragging({
    required Offset dragPosition,
    required Axis scrollDirection,
  }) {
    final childSize = _childSize;
    final childOffset = _childOffset;

    if (childSize == null || childOffset == null) return;

    final absoluteDragPosition = dragPosition + childOffset;

    final automaticScrollExtent = widget.automaticScrollExtent;

    final minOffset = Offset(
      automaticScrollExtent,
      automaticScrollExtent,
    );
    final maxOffset = Offset(
      childSize.width - automaticScrollExtent,
      childSize.height - automaticScrollExtent,
    );

    if (scrollDirection == Axis.vertical) {
      if (absoluteDragPosition.dy < minOffset.dy) {
        _scrollTo(scrollToTop: true);
      } else if (absoluteDragPosition.dy > maxOffset.dy) {
        _scrollTo(scrollToTop: false);
      }
    } else {
      if (absoluteDragPosition.dx < minOffset.dx) {
        _scrollTo(scrollToTop: true);
      } else if (absoluteDragPosition.dx > maxOffset.dx) {
        _scrollTo(scrollToTop: false);
      }
    }
  }

  /// Scrolling vertical or horizontal using [widget.scrollController].
  ///
  /// [scrollToTop] scrolls into the current scroll direction to the right
  /// or top, otherwise it goes to left or bottom.
  /// If [widget.reverse] is true, then the scrolling direction is reversed.
  void _scrollTo({required bool scrollToTop}) {
    if (widget.reverse) {
      scrollToTop = !scrollToTop;
    }

    final scrollOffset = _reorderableScrollable.pixels;
    final maxScrollExtent = _reorderableScrollable.maxScrollExtent;

    if (scrollOffset != null && maxScrollExtent != null) {
      final value = scrollToTop ? scrollOffset - 10 : scrollOffset + 10;

      // only scroll in the viewport of scrollable widget
      if (value > 0 && value < maxScrollExtent + 10) {
        _reorderableScrollable.jumpTo(value: value);
      }
    }
  }

  /// Updates [_childOffset] and [_childSize] using the values defined in [widget.reorderableChildKey].
  ///
  /// There are two ways when scrolling. It is possible that the [GridView] is scrollable
  /// or a parent widget.
  /// Depending on the scrollable widget, the size and position of the [GridView]
  /// will be calculated.
  void _updateChildSizeAndOffset() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentContext = widget.reorderableChildKey?.currentContext;
      final renderBox = currentContext?.findRenderObject() as RenderBox?;

      if (renderBox != null) {
        // scroll is outside widget
        if (renderBox.constraints.biggest.isInfinite) {
          final dimension = Scrollable.of(context).position.viewportDimension;
          _childSize = Size(dimension, dimension);
          _childOffset = renderBox.localToGlobal(Offset.zero);
        } else {
          _childSize = renderBox.size;
          _childOffset = Offset.zero;
        }
      }
    });
  }

  ReorderableScrollable get _reorderableScrollable => ReorderableScrollable.of(
        context,
        scrollController: widget.scrollController,
      );
}
