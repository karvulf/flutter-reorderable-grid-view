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

  ///
  final bool reverse;

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
    required this.reverse,
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
    if (widget.enableScrollingWhileDragging &&
        widget.reorderableChildKey != null &&
        widget.scrollController != null) {
      final position = details.localPosition;

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

    // todo gridviewbuilder macht probleme beim scrollen und reordern
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
  void _scrollTo({required bool scrollToTop}) {
    if (widget.reverse) {
      scrollToTop = !scrollToTop;
    }

    final scrollController = widget.scrollController;

    if (scrollController != null && scrollController.hasClients) {
      late final double value;

      if (scrollToTop) {
        value = scrollController.offset - 10;
      } else {
        value = scrollController.offset + 10;
      }

      if (value > 0 && value < scrollController.position.maxScrollExtent + 10) {
        scrollController.jumpTo(value);
        // widget.onScrollUpdate(Offset(value, value));
      }
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
      final currentContext = widget.reorderableChildKey?.currentContext;
      final renderBox = currentContext?.findRenderObject() as RenderBox?;

      if (renderBox != null) {
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
}
