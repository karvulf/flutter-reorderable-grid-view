import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/entities/animated_grid_view_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/animated/animated_grid_view_child.dart';

typedef AnimatedGridViewBuilderFunction = Widget Function(
  List<Widget> draggableChildren,
  GlobalKey contentGlobalKey,
);

class AnimatedGridViewBuilder extends StatefulWidget {
  final List<Widget> children;
  final ScrollController scrollController;

  final AnimatedGridViewBuilderFunction builder;

  const AnimatedGridViewBuilder({
    required this.children,
    required this.scrollController,
    required this.builder,
    Key? key,
  }) : super(key: key);

  @override
  _AnimatedGridViewBuilderState createState() =>
      _AnimatedGridViewBuilderState();
}

class _AnimatedGridViewBuilderState extends State<AnimatedGridViewBuilder> {
  final _contentGlobalKey = GlobalKey();

  var _childrenMap = <int, AnimatedGridViewEntity>{};
  final _offsetMap = <int, Offset>{};

  @override
  void initState() {
    super.initState();

    var counter = 0;

    for (final child in widget.children) {
      _childrenMap[child.key.hashCode] = AnimatedGridViewEntity(
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
  Widget build(BuildContext context) {
    return widget.builder(
      _getAnimatedGridViewChildren(),
      _contentGlobalKey,
    );
  }

  List<Widget> _getAnimatedGridViewChildren() {
    final children = <Widget>[];
    final sortedChildren = _childrenMap.values.toList()
      ..sort((a, b) => a.updatedOrderId.compareTo(b.updatedOrderId));

    for (final animatedGridViewEntity in sortedChildren) {
      children.add(
        AnimatedGridViewChild(
          key: Key(animatedGridViewEntity.keyHashCode.toString()),
          animatedGridViewEntity: animatedGridViewEntity,
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
    AnimatedGridViewEntity animatedGridViewEntity,
    GlobalKey key,
  ) {
    final offset = _updateOffset(
      key: key,
      orderId: animatedGridViewEntity.updatedOrderId,
    );

    if (offset != null) {
      final updatedGridViewEntity = animatedGridViewEntity.copyWith(
        originalOffset: offset,
        updatedOffset: offset,
        isBuilding: false,
      );
      final keyHashCode = animatedGridViewEntity.keyHashCode;
      _childrenMap[keyHashCode] = updatedGridViewEntity;
    }
  }

  /// Updates offset of existing but new positioned child.
  void _handleBuilding(
    AnimatedGridViewEntity animatedGridViewEntity,
    GlobalKey key,
  ) {
    final offset = _updateOffset(
      key: key,
      orderId: animatedGridViewEntity.updatedOrderId,
    );

    if (offset != null) {
      // updating existing
      final updatedGridViewEntity = animatedGridViewEntity.copyWith(
        updatedOffset: offset,
        isBuilding: false,
      );
      final updatedKeyHashCode = updatedGridViewEntity.keyHashCode;
      _childrenMap[updatedKeyHashCode] = updatedGridViewEntity;

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
      assert(false, 'RenderBox of child should not be null!');
    } else {
      final contentOffset = contentRenderBox.localToGlobal(Offset.zero);
      final localOffset = renderBox.globalToLocal(contentOffset);

      final offset = Offset(
        localOffset.dx.abs(),
        localOffset.dy.abs() + widget.scrollController.position.pixels,
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
    final updatedChildrenMap = <int, AnimatedGridViewEntity>{};

    for (final child in widget.children) {
      final keyHashCode = child.key.hashCode;

      // check if child already exists
      if (_childrenMap.containsKey(keyHashCode)) {
        final animatedGridViewEntity = _childrenMap[keyHashCode]!;

        updatedChildrenMap[keyHashCode] = animatedGridViewEntity.copyWith(
          originalOrderId: !changedChildrenLength ? orderId : null,
          updatedOrderId: orderId,
          originalOffset: !changedChildrenLength ? _offsetMap[orderId] : null,
          updatedOffset: _offsetMap[orderId],
          isBuilding: !_offsetMap.containsKey(orderId),
        );
      } else {
        updatedChildrenMap[keyHashCode] = AnimatedGridViewEntity(
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

  void _handleMovingFinished(AnimatedGridViewEntity animatedGridViewEntity) {
    final keyHashCode = animatedGridViewEntity.keyHashCode;

    _childrenMap[keyHashCode] = animatedGridViewEntity.copyWith(
      originalOffset: animatedGridViewEntity.updatedOffset,
      originalOrderId: animatedGridViewEntity.updatedOrderId,
    );
  }
}
