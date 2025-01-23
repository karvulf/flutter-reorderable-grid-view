import 'package:flutter/material.dart';

/// A utility class to manage scrolling behavior for scrollable widgets.
///
/// The [ReorderableScrollable] class allows you to retrieve and control the
/// scroll position, direction, and offsets in both parent and child scrollable
/// contexts. It is particularly useful in scenarios involving nested
/// scrollable widgets or drag-and-drop operations.
class ReorderableScrollable {
  /// The build context associated with the widget using this class.
  static late BuildContext _context;

  /// The optional ScrollController for managing child scrollable widgets.
  static late ScrollController? _scrollController;

  /// Private constructor to prevent direct instantiation.
  const ReorderableScrollable._();

  /// Factory method to create a `ReorderableScrollable` instance.
  static ReorderableScrollable of(
    BuildContext context, {
    required ScrollController? scrollController,
  }) {
    _context = context;
    _scrollController = scrollController;

    return const ReorderableScrollable._();
  }

  /// Returns the current scroll offset as an `Offset`.
  ///
  /// This method determines the scroll offset by checking if the scrollable
  /// widget is managed by a parent or has its own `ScrollController`.
  ///
  /// - If a `ScrollController` is provided, it uses the controller to fetch the
  ///   scroll position.
  /// - If no controller is provided, it attempts to retrieve the scroll position
  ///   from the parent scrollable widget using the context.
  ///
  /// - [reverse]: Whether to reverse the direction of the offset.
  ///
  /// Returns an `Offset` representing the scroll position or `Offset.zero` if
  /// no position is available.
  Offset getScrollOffset({required bool reverse}) {
    var scrollPosition = Scrollable.maybeOf(_context)?.position;
    final scrollController = _scrollController;

    // Use the provided ScrollController's position if it has clients.
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

  /// Indicates whether the widget relies on a parent scrollable widget.
  ///
  /// If no [ScrollController] is assigned, it is assumed that the widget is
  /// already inside a scrollable parent widget.
  bool get isScrollOutside {
    return _scrollController == null;
  }

  /// Retrieves the scroll direction of the associated scrollable widget.
  ///
  /// - If no `ScrollController` is assigned, the scroll direction of the parent
  ///   scrollable widget is returned.
  /// - If a `ScrollController` is assigned, its direction is returned.
  Axis? get scrollDirection {
    if (isScrollOutside) {
      return Scrollable.of(_context).position.axis;
    } else {
      return _scrollController?.position.axis;
    }
  }

  /// Retrieves the current scroll position in pixels.
  ///
  /// - If no `ScrollController` is assigned, the scroll position of the parent
  ///   scrollable widget is returned.
  /// - If a `ScrollController` is assigned, its offset is returned.
  double? get pixels {
    if (isScrollOutside) {
      return Scrollable.of(_context).position.pixels;
    } else {
      return _scrollController?.offset;
    }
  }

  /// Retrieves the maximum scrollable extent.
  ///
  /// - If no `ScrollController` is assigned, the maximum scroll extent of the
  ///   parent scrollable widget is returned.
  /// - If a `ScrollController` is assigned, its maximum scroll extent is returned.
  double? get maxScrollExtent {
    if (isScrollOutside) {
      return Scrollable.of(_context).position.maxScrollExtent;
    } else {
      return _scrollController?.position.maxScrollExtent;
    }
  }

  /// Jumps to a specific scroll position.
  ///
  /// - [value]: The target scroll position in pixels.
  ///
  /// - If no `ScrollController` is assigned, the scroll position of the parent
  ///   scrollable widget is updated.
  /// - If a `ScrollController` is assigned, its `jumpTo` method is used to
  ///   update the scroll position.
  void jumpTo({required double value}) {
    if (isScrollOutside == true) {
      Scrollable.of(_context).position.moveTo(value);
    } else {
      _scrollController?.jumpTo(value);
    }
  }
}
