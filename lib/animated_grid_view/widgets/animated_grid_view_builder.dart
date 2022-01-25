import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/animated_grid_view/entities/animated_grid_view_entity.dart';
import 'package:flutter_reorderable_grid_view/animated_grid_view/widgets/animated_grid_view_child.dart';

typedef AnimatedGridViewBuilderFunction = Widget Function(
  List<Widget> draggableChildren,
  ScrollController scrollController,
);

class AnimatedGridViewBuilder extends StatefulWidget {
  final List<Widget> children;

  final AnimatedGridViewBuilderFunction builder;

  const AnimatedGridViewBuilder({
    required this.children,
    required this.builder,
    Key? key,
  }) : super(key: key);

  @override
  _AnimatedGridViewBuilderState createState() =>
      _AnimatedGridViewBuilderState();
}

class _AnimatedGridViewBuilderState extends State<AnimatedGridViewBuilder> {
  final _scrollController = ScrollController();

  final _childrenMap = <int, AnimatedGridViewEntity>{};
  final _removedChildrenMap = <int, AnimatedGridViewEntity>{};

  @override
  void initState() {
    super.initState();

    var counter = 0;

    for (final child in widget.children) {
      _childrenMap[child.key.hashCode] = AnimatedGridViewEntity(
        child: child,
        originalOrderId: counter,
        updatedOrderId: counter,
      );
      counter++;
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedGridViewBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.children != widget.children) {
      if (oldWidget.children.length > widget.children.length) {
        _handleRemovedChild();
      } else if (oldWidget.children.length < widget.children.length) {
        _handleAddedChild();
        /*
        var counter = 0;

        for (final child in widget.children) {
          final value = _childrenMap[child.key.hashCode];
          if (value == null) {
            _childrenMap[child.key.hashCode] = AnimatedGridViewEntity(
              child: child,
              originalOrderId: counter,
              updatedOrderId: counter,
            );
          } else {
            _childrenMap[child.key.hashCode] = value.copyWith(
              child: child,
              originalOrderId: counter,
              updatedOrderId: counter,
            );
          }
          counter++;
        }*/
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      _getAnimatedGridViewChildren(),
      _scrollController,
    );
  }

  List<Widget> _getAnimatedGridViewChildren() {
    final children = <Widget>[];
    final sortedChildren = _childrenMap.values.toList()
      ..sort((a, b) => a.originalOrderId.compareTo(b.originalOrderId));

    for (final animatedGridViewEntity in sortedChildren) {
      final keyHashCode = animatedGridViewEntity.child.key.hashCode;
      children.add(
        AnimatedGridViewChild(
          animatedGridViewEntity: animatedGridViewEntity,
          onCreated: _handleCreated,
          opacity: _removedChildrenMap.containsKey(keyHashCode) ? 0.0 : 1.0,
          onEndAnimatedOpacity: _handleEndAnimatedOpacity,
        ),
      );
    }

    return children;
  }

  AnimatedGridViewEntity? _handleCreated(int hashKey, GlobalKey key) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) {
      assert(false, 'RenderBox of child should not be null!');
    } else {
      final reorderableEntity = _childrenMap[hashKey]!;
      final localOffset = renderBox.localToGlobal(Offset.zero);
      final offset = Offset(
        localOffset.dx,
        localOffset.dy + _scrollController.position.pixels,
      );
      final size = renderBox.size;
      final updatedReorderableEntity = reorderableEntity.copyWith(
        size: size,
        originalOffset: offset,
        updatedOffset: offset,
      );
      _childrenMap[hashKey] = updatedReorderableEntity;

      return updatedReorderableEntity;
    }
  }

  void _handleEndAnimatedOpacity(
    AnimatedGridViewEntity animatedGridViewEntity,
  ) {
    final keyHashCode = animatedGridViewEntity.child.key.hashCode;

    if (_removedChildrenMap.containsKey(keyHashCode)) {
      for (final childrenEntry in _childrenMap.entries) {
        _childrenMap[childrenEntry.key] = childrenEntry.value.copyWith(
          originalOffset: childrenEntry.value.updatedOffset,
          originalOrderId: childrenEntry.value.updatedOrderId,
        );
      }
      _removedChildrenMap.remove(keyHashCode);
      _childrenMap.remove(keyHashCode);
      setState(() {});
    }
  }

  void _handleRemovedChild() {
    final updatedChildrenKeyHashCodes = widget.children.map(
      (e) => e.key.hashCode,
    );

    final childrenOrderIdList = _childrenMap.values.toList()
      ..sort((a, b) => a.originalOrderId.compareTo(b.originalOrderId));

    final updatedRemovedChildrenOrderIdMap = <int, AnimatedGridViewEntity>{};
    final updatedRemovedChildrenOrderIdList = <AnimatedGridViewEntity>[];

    for (final animatedGridViewEntity in childrenOrderIdList) {
      final keyHashCode = animatedGridViewEntity.child.key.hashCode;
      if (!updatedChildrenKeyHashCodes.contains(keyHashCode) &&
          !_removedChildrenMap.containsKey(keyHashCode)) {
        updatedRemovedChildrenOrderIdList.add(animatedGridViewEntity);
        updatedRemovedChildrenOrderIdMap[keyHashCode] = animatedGridViewEntity;
      }
    }

    var moveCounts = 1;

    for (int i = 0; i < updatedRemovedChildrenOrderIdList.length; i++) {
      final removedChild = updatedRemovedChildrenOrderIdList[i];
      var nextOrderId = _childrenMap.length - 1;

      if (updatedRemovedChildrenOrderIdList.last != removedChild) {
        nextOrderId = updatedRemovedChildrenOrderIdList[i + 1].originalOrderId;
      }

      for (int j = removedChild.originalOrderId + 1; j <= nextOrderId; j++) {
        final animatedGridViewEntityBefore =
            childrenOrderIdList[j - moveCounts];
        final animatedGridViewEntity = childrenOrderIdList[j];

        final keyHashCode = animatedGridViewEntity.child.key.hashCode;
        _childrenMap[keyHashCode] = animatedGridViewEntity.copyWith(
          updatedOrderId: animatedGridViewEntityBefore.originalOrderId,
          updatedOffset: animatedGridViewEntityBefore.originalOffset,
        );
      }
      moveCounts++;
    }
    _removedChildrenMap.addAll(updatedRemovedChildrenOrderIdMap);
    setState(() {});
  }

  void _handleAddedChild() {
    final updatedAddedChildrenOrderIdMap = <int, AnimatedGridViewEntity>{};
    final updatedAddedChildrenOrderIdList = <AnimatedGridViewEntity>[];

    final childrenOrderIdList = _childrenMap.values.toList()
      ..sort((a, b) => a.originalOrderId.compareTo(b.originalOrderId));

    var orderId = 0;

    var counter = 0;
    bool lastChildWasNew = false;

    for (final child in widget.children) {
      final keyHashCode = child.key.hashCode;

      if (!_childrenMap.containsKey(keyHashCode)) {
        _childrenMap[keyHashCode] = AnimatedGridViewEntity(
          child: child,
          originalOrderId: orderId,
          updatedOrderId: orderId,
        );
        counter++;
        lastChildWasNew = true;
      } else if (counter > 0) {
        final childEntity = _childrenMap[keyHashCode]!;

        late final Offset updatedOffset;

        if (childEntity.originalOrderId > 0) {
          final childBefore = _childrenMap.values.firstWhere(
            (element) =>
                element.originalOrderId ==
                childEntity.originalOrderId - counter,
          );

          updatedOffset = childBefore.originalOffset;
        } else {
          updatedOffset = Offset(
            -childEntity.size.width,
            -childEntity.size.height,
          );
        }

        _childrenMap[keyHashCode] = childEntity.copyWith(
          originalOrderId: orderId,
          updatedOrderId: orderId,
          updatedOffset: updatedOffset,
        );
      }
      orderId++;
    }

    return;
    var moveCounts = 1;

    for (int i = 0; i < updatedAddedChildrenOrderIdList.length; i++) {
      final addedChild = updatedAddedChildrenOrderIdList[i];

      var nextOrderId = _childrenMap.length;

      if (updatedAddedChildrenOrderIdList.last != addedChild) {
        nextOrderId = updatedAddedChildrenOrderIdList[i + 1].originalOrderId;
      }

      for (int j = addedChild.originalOrderId + 1; j < nextOrderId; j++) {
        final indexBefore = j - moveCounts;

        final animatedGridViewEntity = childrenOrderIdList[j];
        final keyHashCode = animatedGridViewEntity.child.key.hashCode;

        final animatedGridViewEntityBefore = childrenOrderIdList[indexBefore];

        _childrenMap[keyHashCode] = animatedGridViewEntity.copyWith(
          updatedOffset: animatedGridViewEntityBefore.originalOffset,
        );
      }
      moveCounts++;
    }

    _childrenMap.addAll(updatedAddedChildrenOrderIdMap);

    setState(() {});
  }
}
