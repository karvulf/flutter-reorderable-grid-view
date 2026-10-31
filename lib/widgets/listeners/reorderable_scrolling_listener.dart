import 'dart:async';

import 'package:flutter/widgets.dart';
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
    super.key,
  });

  @override
  State<ReorderableScrollingListener> createState() =>
      _ReorderableScrollingListenerState();
}

class _ReorderableScrollingListenerState
    extends State<ReorderableScrollingListener> {
  /// Repeating timer to ensure that autoscroll also works when the user doesn't the dragged child.
  Timer? _scrollCheckTimer;

  /// Visible area of the scrollable widget, found when dragging starts.
  ///
  /// The scroll is triggered when the dragged child is near its edges.
  RenderBox? _scrollableRenderBox;

  Offset? _lastDragPosition;

  @override
  void didUpdateWidget(covariant ReorderableScrollingListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDragging != oldWidget.isDragging) {
      if (widget.isDragging) {
        _updateScrollableRenderBox();
      } else {
        _scrollCheckTimer?.cancel();
        _scrollCheckTimer = null;
        _lastDragPosition = null;
      }
    }
  }

  @override
  void dispose() {
    _scrollCheckTimer?.cancel();
    super.dispose();
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
  /// The timer is now created once and kept alive while dragging, instead
  /// of being cancelled and recreated on every pointer move. This prevents
  /// timer starvation on high-refresh-rate devices where pointer events fire
  /// faster than the 10ms timer interval.
  void _handleDragUpdate(PointerMoveEvent details) {
    final scrollDirection = _reorderableScrollable.scrollDirection;

    if (widget.enableScrollingWhileDragging &&
        widget.reorderableChildKey != null &&
        scrollDirection != null) {
      _lastDragPosition = details.position;

      if (_scrollCheckTimer == null || !_scrollCheckTimer!.isActive) {
        _scrollCheckTimer = Timer.periodic(
          const Duration(milliseconds: 10),
          (timer) {
            if (widget.isDragging) {
              final position = _lastDragPosition;
              if (position != null) {
                _checkToScrollWhileDragging(
                  dragPosition: position,
                  scrollDirection: scrollDirection,
                );
              }
            } else {
              timer.cancel();
            }
          },
        );
      }
    }

    widget.onDragUpdate(details);
  }

  /// Depending on [dragPosition] a scroll will be triggered.
  ///
  /// [dragPosition] is the global position of the dragged child. It scrolls
  /// if it is within [ReorderableScrollingListener.automaticScrollExtent]
  /// of an edge of the visible scrollable area.
  void _checkToScrollWhileDragging({
    required Offset dragPosition,
    required Axis scrollDirection,
  }) {
    final scrollableRenderBox = _scrollableRenderBox;
    if (scrollableRenderBox == null || !scrollableRenderBox.attached) return;

    final position = scrollableRenderBox.globalToLocal(dragPosition);
    final size = scrollableRenderBox.size;
    final automaticScrollExtent = widget.automaticScrollExtent;

    final isVertical = scrollDirection == Axis.vertical;
    final value = isVertical ? position.dy : position.dx;
    final length = isVertical ? size.height : size.width;

    if (value < automaticScrollExtent) {
      _scrollTo(scrollToTop: true);
    } else if (value > length - automaticScrollExtent) {
      _scrollTo(scrollToTop: false);
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
      final step = scrollToTop ? -10 : 10;
      // clamp so the last step reaches the edges exactly
      final value = (scrollOffset + step).clamp(0.0, maxScrollExtent);

      if (value != scrollOffset) {
        _reorderableScrollable.jumpTo(value: value);
      }
    }
  }

  /// Updates [_scrollableRenderBox] with the visible area of the scrollable.
  ///
  /// There are two ways when scrolling. It is possible that the [GridView] is
  /// scrollable or a parent widget.
  void _updateScrollableRenderBox() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final currentContext = widget.reorderableChildKey?.currentContext;
      final renderBox = currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) return;

      // scroll is outside widget
      if (renderBox.constraints.biggest.isInfinite) {
        final scrollableContext = Scrollable.maybeOf(context)?.context;
        _scrollableRenderBox =
            scrollableContext?.findRenderObject() as RenderBox?;
      } else {
        _scrollableRenderBox = _innerScrollableRenderBox ?? renderBox;
      }
    });
  }

  /// [RenderBox] of the scrollable using [widget.scrollController].
  RenderBox? get _innerScrollableRenderBox {
    final scrollController = widget.scrollController;
    if (scrollController == null || !scrollController.hasClients) return null;

    final scrollContext = scrollController.position.context.notificationContext;
    return scrollContext?.findRenderObject() as RenderBox?;
  }

  ReorderableScrollable get _reorderableScrollable => ReorderableScrollable.of(
        context,
        scrollController: widget.scrollController,
      );
}
