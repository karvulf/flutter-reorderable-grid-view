import 'package:flutter/material.dart';

///
class ReorderableScrollable {
  static late BuildContext _context;
  static late ScrollController? _scrollController;

  const ReorderableScrollable._();

  static ReorderableScrollable of(
    BuildContext context, {
    required ScrollController? scrollController,
  }) {
    _context = context;
    _scrollController = scrollController;

    return const ReorderableScrollable._();
  }

  /// Returning the current scroll position.
  ///
  /// There are two possibilities to get the scroll position.
  ///
  /// First one is, the returned child of [widget.builder] is a scrollable widget.
  /// In this case, it is important that the [widget.scrollController] is added
  /// to the scrollable widget to get the current scroll position.
  ///
  /// Another possibility is that one of the parents is scrollable.
  /// In that case, the position of the scroll is accessible inside [context].
  ///
  /// Otherwise, 0.0 will be returned.
  Offset getScrollOffset({required bool reverse}) {
    var scrollPosition = Scrollable.maybeOf(_context)?.position;
    final scrollController = _scrollController;

    // For example, in cases where there are nested scrollable widgets
    // like GridViews inside a parent scrollable widget,
    // the widget assigned to the controller will be used for scroll calculations
    if (scrollController != null && scrollController.hasClients) {
      scrollPosition = scrollController.position;
    }

    if (scrollPosition != null) {
      final pixels = scrollPosition.pixels;
      final isScrollingVertical = scrollPosition.axis == Axis.vertical;
      final offset = Offset(
        isScrollingVertical ? 0.0 : pixels,
        isScrollingVertical ? pixels : 0.0,
      );
      return reverse ? -offset : offset;
    }

    return Offset.zero;
  }

  /// No [ScrollController] means that this widget is already in a scrollable widget.
  ///
  /// [widget.scrollController] should be assigned if the scrollable widget
  /// is rendered inside this widget e.g. in a [GridView].
  bool get isScrollOutside {
    return _scrollController == null;
  }

  Axis? get scrollDirection {
    if (isScrollOutside) {
      return Scrollable.of(_context).position.axis;
    } else {
      return _scrollController?.position.axis;
    }
  }

  double? get pixels {
    if (isScrollOutside) {
      return Scrollable.of(_context).position.pixels;
    } else {
      return _scrollController?.offset;
    }
  }

  double? get maxScrollExtent {
    if (isScrollOutside) {
      return Scrollable.of(_context).position.maxScrollExtent;
    } else {
      return _scrollController?.position.maxScrollExtent;
    }
  }

  void jumpTo({required double value}) {
    if (isScrollOutside == true) {
      Scrollable.of(_context).position.moveTo(value);
    } else {
      _scrollController?.jumpTo(value);
    }
  }
}
