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
        final updatedChildrenKeyHashCodes = widget.children.map(
          (e) => e.key.hashCode,
        );
        // sth was removed!!
        for (final animatedGridViewEntity in _childrenMap.values) {
          final keyHashCode = animatedGridViewEntity.child.key.hashCode;
          if (!updatedChildrenKeyHashCodes.contains(keyHashCode) &&
              !_removedChildrenMap.containsKey(keyHashCode)) {
            _removedChildrenMap[keyHashCode] = animatedGridViewEntity;
          }
        }
      } else if (oldWidget.children.length < widget.children.length) {
        // sth was added!!
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

    for (final animatedGridViewEntity in _childrenMap.values) {
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
      _removedChildrenMap.remove(keyHashCode);
      _childrenMap.remove(keyHashCode);
      setState(() {});
    }
  }
}
