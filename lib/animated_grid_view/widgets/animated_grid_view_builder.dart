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
      } else if (oldWidget.children.length < widget.children.length) {
        _handleAddedChildren();
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
      ..sort((a, b) => a.updatedOrderId.compareTo(b.updatedOrderId));

    for (final animatedGridViewEntity in sortedChildren) {
      children.add(
        AnimatedGridViewChild(
          animatedGridViewEntity: animatedGridViewEntity,
          onCreated: _handleCreated,
        ),
      );
    }

    return children;
  }

  AnimatedGridViewEntity? _handleCreated(
    AnimatedGridViewEntity animatedGridViewEntity,
    GlobalKey key,
  ) {
    var gridViewEntity = animatedGridViewEntity;
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) {
      assert(false, 'RenderBox of child should not be null!');
    } else {
      final localOffset = renderBox.localToGlobal(Offset.zero);
      final offset = Offset(
        localOffset.dx,
        localOffset.dy + _scrollController.position.pixels,
      );
      final size = renderBox.size;

      late final AnimatedGridViewEntity updatedReorderableEntity;

      final originalOrderId = animatedGridViewEntity.originalOrderId;

      if (animatedGridViewEntity.updatedOrderId != originalOrderId) {
        gridViewEntity = _childrenMap.values.firstWhere(
          (element) => element.updatedOrderId == originalOrderId,
        );
      }
      updatedReorderableEntity = gridViewEntity.copyWith(
        size: size,
        originalOffset: offset,
        updatedOffset: offset,
      );

      final keyHashCode = gridViewEntity.keyHashCode;
      _childrenMap[keyHashCode] = updatedReorderableEntity;
      print(
          'created ${updatedReorderableEntity.child.key} with offset $offset, orderId ${updatedReorderableEntity.originalOrderId}');

      return updatedReorderableEntity;
    }
  }

  void _handleAddedChildren() {
    var orderId = 0;
    var childBeforeCounter = 0;

    for (final child in widget.children) {
      final keyHashCode = child.key.hashCode;

      // check if child already exists
      if (_childrenMap.containsKey(keyHashCode)) {
        final animatedGridViewEntity = _childrenMap[keyHashCode]!;

        // check if there were already children added before child
        if (childBeforeCounter > 0) {
          final childBeforeOrderId = orderId - childBeforeCounter;

          // check if there existing children before child
          if (childBeforeOrderId > 0) {
            final childBefore = _childrenMap.values.firstWhere(
              (element) => element.originalOrderId == childBeforeOrderId,
            );
          } else {
            final currentOffset = animatedGridViewEntity.updatedOffset;
            final size = animatedGridViewEntity.size;
            _childrenMap[keyHashCode] = animatedGridViewEntity.copyWith(
              updatedOrderId: orderId,
              updatedOffset: Offset(
                currentOffset.dx + size.width,
                currentOffset.dy + size.height,
              ),
            );
          }
        } else {
          _childrenMap[keyHashCode] = animatedGridViewEntity.copyWith(
            updatedOrderId: orderId,
            originalOrderId: orderId,
          );
        }
      } else {
        _childrenMap[keyHashCode] = AnimatedGridViewEntity(
          child: child,
          originalOrderId: orderId,
          updatedOrderId: orderId,
        );
        childBeforeCounter++;
      }
      orderId++;
    }
    /*
    final sortedChildren = _childrenMap.values.toList()
      ..sort((a, b) => a.originalOrderId.compareTo(b.originalOrderId));
    print('----');
    for (final child in sortedChildren) {
      final updatedOrderId = child.updatedOrderId;
      final key = child.child.key;

      print('Key $key with updatedOrderId $updatedOrderId');
    }
    print('----');
    */

    setState(() {});
  }
}
