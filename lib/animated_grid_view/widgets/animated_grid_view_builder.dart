import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/animated_grid_view/entities/animated_grid_view_entity.dart';
import 'package:flutter_reorderable_grid_view/animated_grid_view/widgets/animated_grid_view_child.dart';

typedef AnimatedGridViewBuilderFunction = Widget Function(
  List<Widget> draggableChildren,
  ScrollController scrollController,
  GlobalKey contentGlobalKey,
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
  final _contentGlobalKey = GlobalKey();
  final _scrollController = ScrollController();

  var _childrenMap = <int, AnimatedGridViewEntity>{};

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
      _handleUpdatedChildren();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      _getAnimatedGridViewChildren(),
      _scrollController,
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
          animatedGridViewEntity: animatedGridViewEntity,
          onCreated: _handleCreated,
          onMovingFinished: _handleMovingFinished,
        ),
      );
    }

    return children;
  }

  void _handleCreated(
    AnimatedGridViewEntity animatedGridViewEntity,
    GlobalKey key,
  ) {
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
        localOffset.dy.abs() + _scrollController.position.pixels,
      );
      final size = renderBox.size;

      final originalOrderId = animatedGridViewEntity.originalOrderId;

      if (animatedGridViewEntity.updatedOrderId != originalOrderId) {
        // searching for original
        var newGridViewEntity = _childrenMap.values.firstWhere(
          (element) => element.updatedOrderId == originalOrderId,
        );

        // updating added entity
        newGridViewEntity = newGridViewEntity.copyWith(
          size: size,
          originalOffset: animatedGridViewEntity.originalOffset,
          updatedOffset: animatedGridViewEntity.originalOffset,
        );
        final newKeyHashCode = animatedGridViewEntity.keyHashCode;
        _childrenMap[newKeyHashCode] = newGridViewEntity;

        // updating existing
        final updatedGridViewEntity = animatedGridViewEntity.copyWith(
          updatedOffset: offset,
          isBuilding: false,
        );
        final updatedKeyHashCode = updatedGridViewEntity.keyHashCode;
        _childrenMap[updatedKeyHashCode] = updatedGridViewEntity;

        setState(() {});
      } else {
        final updatedGridViewEntity = animatedGridViewEntity.copyWith(
          size: size,
          originalOffset: offset,
          updatedOffset: offset,
        );
        final keyHashCode = animatedGridViewEntity.keyHashCode;
        _childrenMap[keyHashCode] = updatedGridViewEntity;
      }
    }
  }

  void _handleUpdatedChildren() {
    var orderId = 0;
    final updatedChildrenMap = <int, AnimatedGridViewEntity>{};

    for (final child in widget.children) {
      final keyHashCode = child.key.hashCode;

      // check if child already exists
      if (_childrenMap.containsKey(keyHashCode)) {
        final animatedGridViewEntity = _childrenMap[keyHashCode]!;

        final orderIdGridViewEntity = _getAnimatedGridViewEntity(
          orderId: orderId,
        );
        // check if there is already a child with that orderId
        if (orderIdGridViewEntity != null) {
          updatedChildrenMap[keyHashCode] = animatedGridViewEntity.copyWith(
            updatedOrderId: orderId,
            updatedOffset: orderIdGridViewEntity.originalOffset,
          );
        } else {
          updatedChildrenMap[keyHashCode] = animatedGridViewEntity.copyWith(
            updatedOrderId: orderId,
            isBuilding: true, // do I really need that?
          );
        }
      } else {
        updatedChildrenMap[keyHashCode] = AnimatedGridViewEntity(
          child: child,
          originalOrderId: orderId,
          updatedOrderId: orderId,
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

  AnimatedGridViewEntity? _getAnimatedGridViewEntity({required int orderId}) {
    for (final gridViewEntity in _childrenMap.values) {
      if (gridViewEntity.originalOrderId == orderId) {
        return gridViewEntity;
      }
    }
  }
}
