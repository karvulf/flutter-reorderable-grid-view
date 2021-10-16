import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/grid_item_entity.dart';
import 'package:flutter_reorderable_grid_view/utils/reorderable_grid_utils.dart';
import 'package:flutter_reorderable_grid_view/widgets/animated_draggable_item.dart';
import 'package:flutter_reorderable_grid_view/widgets/draggable_item.dart';

/// Ordering [children] in a [Wrap] that can be drag and dropped.
///
/// Simple way of drag and drop [children] that were built inside a [Wrap].
///
/// To enable the possibility of the drag and drop, it's important to build
/// all [children] inside a [Wrap]. After that every child is added to the
/// entity [GridItemEntity] that contains the position and orderId of the build
/// item.
/// When all items are added to new map animatedChildren, the widget is
/// reconstructing the wrap inside a [Container]. This [Container] has the same
/// size as the [Wrap]. Inside the [Container], all children are rebuild with a
/// [Positioned] widget.
/// At the end, the same widget is build without a [Wrap] but now it's possible
/// to update the positions of the widgets with a drag and drop.
///
/// A list of [children] that are build inside a [Wrap].
///
/// Using [spacing] adds a space in vertical direction between [children].
/// The default value is 8.
///
/// Using [runSpacing] adds a space in horizontal direction between [children].
/// The default value is 8.
///
/// [enableAnimation] is enabling the animation of changing the positions of
/// [children] after drag and drop. The default value is true.
///
/// With [enableLongPress] you can decide if the user needs a long press to move
/// the item around. The default value is true.

class ReorderableGridView extends StatefulWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final bool enableAnimation;
  final bool enableLongPress;

  const ReorderableGridView({
    required this.children,
    this.spacing = 8,
    this.runSpacing = 8,
    this.enableAnimation = true,
    this.enableLongPress = true,
    Key? key,
  }) : super(key: key);

  @override
  State<ReorderableGridView> createState() => _ReorderableGridViewState();
}

class _ReorderableGridViewState extends State<ReorderableGridView> {
  Map<int, GridItemEntity> _animatedChildren = {};
  final _wrapKey = GlobalKey();
  final _scrollController = ScrollController();

  late final Offset _wrapPosition;
  late final Size _wrapSize;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final wrapBox = _wrapKey.currentContext!.findRenderObject()! as RenderBox;
      _wrapPosition = wrapBox.localToGlobal(Offset.zero);
      _wrapSize = wrapBox.size;
    });
  }

  @override
  Widget build(BuildContext context) {
    final children = widget.children;

    return SingleChildScrollView(
      controller: _scrollController,
      child: Builder(
        builder: (context) {
          // after all children are added to animatedChildren
          if (_animatedChildren.entries.length == children.length) {
            return SizedBox(
              height: _wrapSize.height,
              width: _wrapSize.width,
              child: Stack(
                children: _animatedChildren.entries
                    .map((e) => AnimatedDraggableItem(
                          key: Key(e.key.toString()),
                          enableAnimation: widget.enableAnimation,
                          entry: e,
                          enableLongPress: widget.enableLongPress,
                          onDragUpdate: _handleDragUpdate,
                        ))
                    .toList(),
              ),
            );
          } else {
            return Wrap(
              key: _wrapKey,
              spacing: widget.spacing,
              runSpacing: widget.runSpacing,
              children: List.generate(
                children.length,
                (index) => DraggableItem(
                  item: children.elementAt(index),
                  enableLongPress: widget.enableLongPress,
                  id: index,
                  onCreated: _handleCreated,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  void _handleCreated(
    BuildContext context,
    GlobalKey key,
    Widget item,
    int id,
  ) {
    final renderObject = key.currentContext?.findRenderObject();
    if (renderObject != null) {
      final box = renderObject as RenderBox;
      final position = box.localToGlobal(Offset.zero);
      final size = box.size;
      final localPosition = Offset(
        position.dx - _wrapPosition.dx,
        position.dy - _wrapPosition.dy,
      );

      _animatedChildren[id] = GridItemEntity(
        localPosition: localPosition,
        globalPosition: position,
        size: size,
        item: item,
        orderId: id,
      );

      if (_animatedChildren.entries.length == widget.children.length) {
        setState(() {
          _animatedChildren = _animatedChildren;
        });
      }
    }
  }

  void _handleDragUpdate(
    BuildContext context,
    DragUpdateDetails details,
    int id,
  ) {
    final collisionId = getItemsCollision(
      id: id,
      position: details.globalPosition,
      children: _animatedChildren,
      scrollPixelsY: _scrollController.position.pixels,
    );

    if (collisionId != null && collisionId != id) {
      final dragItemOrderId = _animatedChildren[id]!.orderId;
      final collisionItemOrderId = _animatedChildren[collisionId]!.orderId;

      if (collisionItemOrderId > dragItemOrderId &&
          collisionItemOrderId - dragItemOrderId > 1) {
        handleMultipleCollisionsForward(
          collisionItemOrderId: collisionItemOrderId,
          dragItemOrderId: dragItemOrderId,
          children: _animatedChildren,
        );
      } else if (collisionItemOrderId < dragItemOrderId &&
          dragItemOrderId - collisionItemOrderId > 1) {
        handleMultipleCollisionsBackward(
          dragItemOrderId: dragItemOrderId,
          collisionItemOrderId: collisionItemOrderId,
          children: _animatedChildren,
        );
      } else {
        handleOneCollision(
          dragId: id,
          collisionId: collisionId,
          children: _animatedChildren,
        );
      }

      setState(() {
        _animatedChildren = _animatedChildren;
      });
    }
  }
}
