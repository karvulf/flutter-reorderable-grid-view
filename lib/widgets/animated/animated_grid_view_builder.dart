import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/animated/animated_grid_view_item.dart';

typedef AnimatedGridViewBuilderFunction = Widget Function(
  List<Widget> draggableChildren,
  GlobalKey contentGlobalKey,
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

class _AnimatedGridViewBuilderState extends State<AnimatedGridViewBuilder>
    with WidgetsBindingObserver {
  /// This key should describe the content where all children are placed, e. g. the GridView
  final _contentGlobalKey = GlobalKey();

  /// Represents all children with the unique key of the widget as key
  var _childrenMap = <int, ReorderableEntity>{};

  /// Containing [Offset] for every calculated position of child in GridView
  final _offsetMap = <int, Offset>{};

  ///
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);

    var orderId = 0;

    // adding all children for _childrenMap
    for (final child in widget.children) {
      _childrenMap[child.key.hashCode] = ReorderableEntity(
        child: child,
        originalOrderId: orderId,
        updatedOrderId: orderId,
        isBuilding: true,
      );
      orderId++;
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
        // Todo: rebuild all items but how?
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

  /// Returning a list of children wrapped with [AnimatedGridViewItem]
  List<Widget> _getAnimatedGridViewChildren() {
    final children = <Widget>[];

    // sorting all children with their updatedOrderId
    final sortedChildren = _childrenMap.values.toList()
      ..sort((a, b) => a.updatedOrderId.compareTo(b.updatedOrderId));

    for (final reorderableEntity in sortedChildren) {
      children.add(
        AnimatedGridViewItem(
          key: Key(reorderableEntity.keyHashCode.toString()),
          reorderableEntity: reorderableEntity,
          onCreated: _handleCreated,
          onBuilding: _handleBuilding,
          onMovingFinished: _handleMovingFinished,
          onOpacityFinished: _handleOpacityFinished,
        ),
      );
    }
    return children;
  }

  /// Called when child with [key] is built and updates the [ReorderableEntity] inside [_childrenMap].
  void _handleCreated(
    ReorderableEntity reorderableEntity,
    GlobalKey key,
  ) {
    final offset = _getOffset(
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
      setState(() {});
    }
  }

  /// Updates [reorderableEntity] for [_childrenMap] with new [Offset].
  ///
  /// Usually called when the child with [key] was rebuilt or got a new position.
  void _handleBuilding(
    ReorderableEntity reorderableEntity,
    GlobalKey key,
  ) {
    final offset = _getOffset(
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

  /// Returns optional calculated [Offset] related to [key].
  ///
  /// If the renderBox for [key] and [_contentGlobalKey] was found,
  /// the offset for [key] inside the renderBox of [_contentGlobalKey]
  /// is calculated.
  Offset? _getOffset({
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
        // Todo: Scroll position könnte auch von den parents kommen, anpassen wie in reorderableBuilder
        localOffset.dy.abs() + _scrollController.position.pixels,
      );
      _offsetMap[orderId] = offset;

      return offset;
    }

    return null;
  }

  /// Updates all children for [_childrenMap].
  ///
  /// If the length of children was the same, the originalOrderId and
  /// originalOffset will also be updated to prevent a moving animation.
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

        final updatedReorderableEntity = reorderableEntity.copyWith(
          child: child,
          originalOrderId: !changedChildrenLength ? orderId : null,
          updatedOrderId: orderId,
          originalOffset: !changedChildrenLength ? _offsetMap[orderId] : null,
          updatedOffset: _offsetMap[orderId],
          isBuilding: !_offsetMap.containsKey(orderId),
        );
        updatedChildrenMap[keyHashCode] = updatedReorderableEntity;
      } else {
        updatedChildrenMap[keyHashCode] = ReorderableEntity(
          child: child,
          originalOrderId: orderId,
          updatedOrderId: orderId,
          isBuilding: false,
          isNew: true,
        );
      }
      orderId++;
    }
    setState(() {
      _childrenMap = updatedChildrenMap;
    });
  }

  /// After [reorderableEntity] moved to the new position, the offset and orderId get an update.
  void _handleMovingFinished(ReorderableEntity reorderableEntity) {
    final keyHashCode = reorderableEntity.keyHashCode;

    _childrenMap[keyHashCode] = reorderableEntity.copyWith(
      originalOffset: reorderableEntity.updatedOffset,
      originalOrderId: reorderableEntity.updatedOrderId,
    );
  }

  /// After [reorderableEntity] faded in, the parameter isNew is false.
  void _handleOpacityFinished(ReorderableEntity reorderableEntity) {
    final keyHashCode = reorderableEntity.keyHashCode;

    setState(() {
      _childrenMap[keyHashCode] = reorderableEntity.copyWith(
        isNew: false,
      );
    });
  }
}
