import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/animated/animated_grid_view_child.dart';

typedef AnimatedGridViewBuilderFunction = Widget Function(
  List<Widget> draggableChildren,
  GlobalKey contentGlobalKey,
  ScrollController scrollController,
);

class AnimatedGridViewBuilder extends StatefulWidget {
  final List<Widget> children;
  final AnimatedGridViewBuilderFunction builder;

  final ScrollController? scrollController;

  const AnimatedGridViewBuilder({
    required this.children,
    required this.builder,
    this.scrollController,
    Key? key,
  }) : super(key: key);

  @override
  _AnimatedGridViewBuilderState createState() =>
      _AnimatedGridViewBuilderState();
}

class _AnimatedGridViewBuilderState extends State<AnimatedGridViewBuilder>
    with WidgetsBindingObserver {
  final _contentGlobalKey = GlobalKey();

  var _childrenMap = <int, ReorderableEntity>{};
  final _offsetMap = <int, Offset>{};

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);

    _scrollController = widget.scrollController ?? ScrollController();

    var counter = 0;

    for (final child in widget.children) {
      _childrenMap[child.key.hashCode] = ReorderableEntity(
        child: child,
        originalOrderId: counter,
        updatedOrderId: counter,
        isBuilding: true,
      );
      counter++;
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedGridViewBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldChildren = oldWidget.children;
    final children = widget.children;

    if (oldChildren != children) {
      final changedChildrenLength = oldChildren.length != children.length;
      _handleUpdatedChildren(
        changedChildrenLength: changedChildrenLength,
      );
    }
  }

  @override
  void didChangeMetrics() {
    final orientationBefore = MediaQuery.of(context).orientation;
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final orientationAfter = MediaQuery.of(context).orientation;
      if (orientationBefore != orientationAfter) {
        // rebuild all items
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      _getAnimatedGridViewChildren(),
      _contentGlobalKey,
      _scrollController,
    );
  }

  List<Widget> _getAnimatedGridViewChildren() {
    final children = <Widget>[];
    final sortedChildren = _childrenMap.values.toList()
      ..sort((a, b) => a.updatedOrderId.compareTo(b.updatedOrderId));

    for (final reorderableEntity in sortedChildren) {
      children.add(
        AnimatedGridViewChild(
          key: Key(reorderableEntity.keyHashCode.toString()),
          reorderableEntity: reorderableEntity,
          onCreated: _handleCreated,
          onBuilding: _handleBuilding,
          onMovingFinished: _handleMovingFinished,
        ),
      );
    }
    return children;
  }

  /// Updates offset new child.
  void _handleCreated(
    ReorderableEntity reorderableEntity,
    GlobalKey key,
  ) {
    final offset = _updateOffset(
      key: key,
      orderId: reorderableEntity.updatedOrderId,
    );

    if (offset != null) {
      final updatedReorderableEntity = reorderableEntity.copyWith(
        originalOffset: offset,
        updatedOffset: offset,
        isBuilding: false,
      );
      final keyHashCode = reorderableEntity.keyHashCode;
      _childrenMap[keyHashCode] = updatedReorderableEntity;
    }
  }

  /// Updates offset of existing but new positioned child.
  void _handleBuilding(
    ReorderableEntity reorderableEntity,
    GlobalKey key,
  ) {
    final offset = _updateOffset(
      key: key,
      orderId: reorderableEntity.updatedOrderId,
    );

    if (offset != null) {
      // updating existing
      final updatedReorderableEntity = reorderableEntity.copyWith(
        updatedOffset: offset,
        isBuilding: false,
      );
      final updatedKeyHashCode = updatedReorderableEntity.keyHashCode;
      _childrenMap[updatedKeyHashCode] = updatedReorderableEntity;

      setState(() {});
    }
  }

  Offset? _updateOffset({
    required int orderId,
    required GlobalKey key,
  }) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    final contentRenderBox =
        _contentGlobalKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null || contentRenderBox == null) {
      // assert(false, 'RenderBox of child should not be null!');
    } else {
      final contentOffset = contentRenderBox.localToGlobal(Offset.zero);
      final localOffset = renderBox.globalToLocal(contentOffset);

      final offset = Offset(
        localOffset.dx.abs(),
        localOffset.dy.abs() + _scrollController.position.pixels,
      );
      _offsetMap[orderId] = offset;

      return offset;
    }
  }

  /// Updates all children for [_childrenMap].
  ///
  /// If the length of children was the same, the originalOrderId and
  /// originalOffset will also be updated to prevent an animation.
  /// This case can happen, e. g. after a drag and drop, when the children
  /// change theirs position.
  void _handleUpdatedChildren({required bool changedChildrenLength}) {
    var orderId = 0;
    final updatedChildrenMap = <int, ReorderableEntity>{};

    for (final child in widget.children) {
      final keyHashCode = child.key.hashCode;

      // check if child already exists
      if (_childrenMap.containsKey(keyHashCode)) {
        final reorderableEntity = _childrenMap[keyHashCode]!;

        updatedChildrenMap[keyHashCode] = reorderableEntity.copyWith(
          child: child,
          originalOrderId: !changedChildrenLength ? orderId : null,
          updatedOrderId: orderId,
          originalOffset: !changedChildrenLength ? _offsetMap[orderId] : null,
          updatedOffset: _offsetMap[orderId],
          isBuilding: !_offsetMap.containsKey(orderId),
        );
      } else {
        updatedChildrenMap[keyHashCode] = ReorderableEntity(
          child: child,
          originalOrderId: orderId,
          updatedOrderId: orderId,
          isBuilding: true,
        );
      }
      orderId++;
    }
    setState(() {
      _childrenMap = updatedChildrenMap;
    });
  }

  void _handleMovingFinished(ReorderableEntity reorderableEntity) {
    final keyHashCode = reorderableEntity.keyHashCode;

    _childrenMap[keyHashCode] = reorderableEntity.copyWith(
      originalOffset: reorderableEntity.updatedOffset,
      originalOrderId: reorderableEntity.updatedOrderId,
    );
  }
}
