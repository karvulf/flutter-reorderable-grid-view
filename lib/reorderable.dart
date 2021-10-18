import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/grid_item_entity.dart';
import 'package:flutter_reorderable_grid_view/entities/reoderable_parameters.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_type.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_wrap_parameters.dart';
import 'package:flutter_reorderable_grid_view/utils/reorderable_grid_utils.dart';
import 'package:flutter_reorderable_grid_view/widgets/animated_draggable_item.dart';
import 'package:flutter_reorderable_grid_view/widgets/draggable_item.dart';

typedef ReoderableOnUpdateFunction = void Function(int oldIndex, int newIndex);

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
///
/// [onUpdate] always give you the old and new index of the moved children.
/// Make sure to update your list of children that you used to display your data.
/// See more on the example.
class Reorderable extends StatefulWidget
    implements ReorderableParameters, ReorderableWrapParameters {
  const Reorderable({
    required this.children,
    required this.reorderableType,
    this.lockedChildren = const [],
    this.spacing = 8,
    this.runSpacing = 8,
    this.enableAnimation = true,
    this.enableLongPress = true,
    this.longPressDelay = kLongPressTimeout,
    this.onUpdate,
    Key? key,
  }) : super(key: key);

  ///
  /// Default Parameter
  ///

  @override
  final List<Widget> children;

  @override
  final List<int> lockedChildren;

  @override
  final bool enableAnimation;

  @override
  final bool enableLongPress;

  @override
  final Duration longPressDelay;

  @override
  final void Function(int oldIndex, int newIndex)? onUpdate;

  ///
  /// Wrap
  ///

  @override
  final double spacing;

  @override
  final double runSpacing;

  ///
  /// Other
  ///

  final ReorderableType reorderableType;

  @override
  State<Reorderable> createState() => _ReorderableState();
}

class _ReorderableState extends State<Reorderable> with WidgetsBindingObserver {
  /// This widget always makes a copy of [widget.children]
  List<Widget> childrenCopy = <Widget>[];

  /// Represents all children inside a map with the index as key
  Map<int, GridItemEntity> _childrenIdMap = {};

  /// Represents all children inside a map with the orderId as key
  Map<int, GridItemEntity> _childrenOrderIdMap = {};

  /// Bool to know if all children were build and updated.
  bool hasBuiltItems = false;

  /// Key of the [Wrap] that was used to build the widget
  final _wrapKey = GlobalKey();

  /// Controller of the [SingleChildScrollView]
  final _scrollController = ScrollController();

  /// Size of the [Wrap] that was used to build the widget
  late Size _wrapSize;

  @override
  void initState() {
    super.initState();
    setState(() {
      childrenCopy = List<Widget>.from(widget.children);
    });
    WidgetsBinding.instance!.addObserver(this);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _updateWrapSize();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant Reorderable oldWidget) {
    super.didUpdateWidget(oldWidget);

    // childrenCopy has to get an update
    if (oldWidget.children != widget.children) {
      // resetting maps to built all children correctly when children size changes
      if (oldWidget.children.length != widget.children.length) {
        setState(() {
          _childrenIdMap = {};
          _childrenOrderIdMap = {};
          hasBuiltItems = false;
          childrenCopy = List<Widget>.from(widget.children);
        });
      } else {
        setState(() {
          childrenCopy = List<Widget>.from(widget.children);
        });
      }
    }
  }

  @override
  void didChangeMetrics() {
    final orientationBefore = MediaQuery.of(context).orientation;
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      final orientationAfter = MediaQuery.of(context).orientation;
      if (orientationBefore != orientationAfter) {
        setState(() {
          hasBuiltItems = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        // after all children are added to animatedChildren
        if (hasBuiltItems && childrenCopy.length == _childrenIdMap.length) {
          return SingleChildScrollView(
            controller: _scrollController,
            child: SizedBox(
              height: _wrapSize.height,
              width: _wrapSize.width,
              child: Stack(
                children: _childrenIdMap.entries
                    .map((e) => AnimatedDraggableItem(
                          key: Key(e.key.toString()),
                          enableAnimation: widget.enableAnimation,
                          entry: e,
                          enableLongPress: widget.enableLongPress,
                          onDragUpdate: _handleDragUpdate,
                          longPressDelay: widget.longPressDelay,
                          enabled: !widget.lockedChildren.contains(e.key),
                          child: childrenCopy[e.value.orderId],
                        ))
                    .toList(),
              ),
            ),
          );
        } else {
          switch (widget.reorderableType) {
            case ReorderableType.wrap:
              return Wrap(
                key: _wrapKey,
                spacing: widget.spacing,
                runSpacing: widget.runSpacing,
                children: List.generate(
                  childrenCopy.length,
                  (index) => DraggableItem(
                    child: childrenCopy[index],
                    enableLongPress: widget.enableLongPress,
                    id: index,
                    onCreated: _handleCreated,
                    longPressDelay: widget.longPressDelay,
                    enabled: !widget.lockedChildren.contains(index),
                  ),
                ),
              );
            case ReorderableType.gridViewCount:
              return GridView.count(
                key: _wrapKey,
                crossAxisCount: 2,
                children: List.generate(
                  childrenCopy.length,
                  (index) => DraggableItem(
                    child: childrenCopy[index],
                    enableLongPress: widget.enableLongPress,
                    id: index,
                    onCreated: _handleCreated,
                    longPressDelay: widget.longPressDelay,
                    enabled: !widget.lockedChildren.contains(index),
                  ),
                ),
              );
            case ReorderableType.gridView:
              throw UnimplementedError('Widget soon available!');
          }
        }
      },
    );
  }

  /// Looking for the current size of the [Wrap] and updates it.
  void _updateWrapSize() {
    final wrapBox = _wrapKey.currentContext!.findRenderObject()! as RenderBox;
    _wrapSize = wrapBox.size;
  }

  /// Creates [GridItemEntity] that contains all information for this widget.
  ///
  /// There are two different ways when a child was created.
  ///
  /// One would be that it already exists and was just updated, e. g. after an
  /// orientation change. Then the existing child gets an update in terms of
  /// position.
  ///
  /// If the item does not exist, then a new [GridItemEntity] is created.
  /// That includes the size and position (global and locally inside [Wrap]
  /// of the widget. Also an id and orderId is added that are important to
  /// know where the item is ordered and to identify the original item
  /// after changing the position.
  void _handleCreated(
    BuildContext context,
    GlobalKey key,
    int id,
  ) {
    final renderObject = key.currentContext?.findRenderObject();

    if (renderObject != null) {
      final wrapBox = _wrapKey.currentContext!.findRenderObject()! as RenderBox;
      final _wrapPosition = wrapBox.localToGlobal(Offset.zero);

      final box = renderObject as RenderBox;
      final position = box.localToGlobal(Offset.zero);
      final size = box.size;
      final localPosition = Offset(
        position.dx - _wrapPosition.dx,
        position.dy - _wrapPosition.dy,
      );

      // in this case id is equal to orderId and _childrenOrderIdMap must be used
      final existingItem = _childrenOrderIdMap[id];

      // if exists update position related to the orderId
      if (existingItem != null) {
        final gridItemEntity = existingItem.copyWith(
          localPosition: localPosition,
          globalPosition: position,
        );
        _childrenOrderIdMap[id] = gridItemEntity;
        _childrenIdMap[gridItemEntity.id] = gridItemEntity;

        if (id == _childrenIdMap.entries.length - 1) {
          _updateWrapSize();
          setState(() {
            hasBuiltItems = true;
          });
        }
      } else {
        final gridItemEntity = GridItemEntity(
          id: id,
          localPosition: localPosition,
          globalPosition: position,
          size: size,
          orderId: id,
        );
        _childrenIdMap[id] = gridItemEntity;
        _childrenOrderIdMap[id] = gridItemEntity;

        if (_childrenIdMap.entries.length == childrenCopy.length) {
          _updateWrapSize();
          setState(() {
            hasBuiltItems = true;
          });
        }
      }
    }
  }

  /// After dragging an item, if will be checked if there are some collisions.
  ///
  /// There are three different ways how an item can collision to another.
  ///
  /// The simplest way would be that the user drags the item next to another
  /// item on the left or right side. That means there will be only
  /// one collision to calculate.
  ///
  /// The second possibility would be that the dragged item changes more than
  /// just one position. For example after dragging above the items. That means
  /// that all items changes their direction after dragging backwards.
  ///
  /// The last way is the opposite of the second possibility. The user drags the
  /// item e. g. under the item and changes multiple positions.
  ///
  /// Another important thing is the possibility that there are locked items. A
  /// locked item can't change his position and should always be ignored when
  /// all items around changes their position.
  ///
  /// After all the position changes were done, there will be an update to
  /// [onUpdate] and the state will be updated inside this widget show the new
  /// positions of the items to the user.
  void _handleDragUpdate(
    BuildContext context,
    DragUpdateDetails details,
    int id,
  ) {
    final collisionId = getItemsCollision(
      id: id,
      position: details.globalPosition,
      childrenIdMap: _childrenIdMap,
      scrollPixelsY: _scrollController.position.pixels,
      lockedChildren: widget.lockedChildren,
    );

    if (collisionId != null && collisionId != id) {
      final dragItemOrderId = _childrenIdMap[id]!.orderId;
      final collisionItemOrderId = _childrenIdMap[collisionId]!.orderId;

      // item changes multiple positions to the positive direction
      if (collisionItemOrderId > dragItemOrderId &&
          collisionItemOrderId - dragItemOrderId > 1) {
        handleMultipleCollisionsForward(
          collisionItemOrderId: collisionItemOrderId,
          dragItemOrderId: dragItemOrderId,
          childrenIdMap: _childrenIdMap,
          lockedChildren: widget.lockedChildren,
          childrenOrderIdMap: _childrenOrderIdMap,
          onUpdate: _handleUpdate,
        );
      }
      // item changes multiple positions to the negative direction
      else if (collisionItemOrderId < dragItemOrderId &&
          dragItemOrderId - collisionItemOrderId > 1) {
        handleMultipleCollisionsBackward(
          dragItemOrderId: dragItemOrderId,
          collisionItemOrderId: collisionItemOrderId,
          childrenIdMap: _childrenIdMap,
          lockedChildren: widget.lockedChildren,
          childrenOrderIdMap: _childrenOrderIdMap,
          onUpdate: _handleUpdate,
        );
      }
      // item changes position only to one item
      else {
        handleOneCollision(
          dragId: id,
          collisionId: collisionId,
          childrenIdMap: _childrenIdMap,
          lockedChildren: widget.lockedChildren,
          childrenOrderIdMap: _childrenOrderIdMap,
          onUpdate: _handleUpdate,
        );
      }

      setState(() {
        _childrenIdMap = _childrenIdMap;
        _childrenOrderIdMap = _childrenOrderIdMap;
      });
    }
  }

  void _handleUpdate(int oldIndex, int newIndex) {
    setState(() {
      final draggedItem = childrenCopy[oldIndex];
      final collisionItem = childrenCopy[newIndex];
      childrenCopy[newIndex] = draggedItem;
      childrenCopy[oldIndex] = collisionItem;
    });

    if (widget.onUpdate != null) {
      widget.onUpdate!(oldIndex, newIndex);
    }
  }
}
