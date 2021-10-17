import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
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
///
/// [onUpdate] contains a list of int values that represents the current order
/// in the list.
/// E. g. if you have two children in a list, then the start value would be
/// [0, 1]. After swapping their positions, the new order would be [1, 0]. That
/// means the first child is now on position 1 and the second child is on
/// position 0.
/// Or you have four children, than the start order would be [0, 1, 2, 3]. After
/// changing the position between the first and third item, the list would have
/// the following order: [2, 0, 1, 3]. That means that the first item is on the
/// position 2, the second item is on the position 0, the third item is on the
/// position 1 and the fourth item still has positon 3.
class ReorderableGridView extends StatefulWidget {
  const ReorderableGridView({
    required this.children,
    this.lockedChildren = const [],
    this.spacing = 8,
    this.runSpacing = 8,
    this.enableAnimation = true,
    this.enableLongPress = true,
    this.longPressDelay = kLongPressTimeout,
    this.onUpdate,
    Key? key,
  }) : super(key: key);

  /// Adding [children] that should be displayed inside this widget
  final List<Widget> children;

  final List<int> lockedChildren;

  /// Spacing between displayed items in horizontal direction
  final double spacing;

  /// Spacing between displayed items in vertical direction
  final double runSpacing;

  /// By default animation is enabled when the position of the items changes
  final bool enableAnimation;

  /// By default long press is enabled when tapping an item
  final bool enableLongPress;

  /// By default it has a duration of 500ms before an item can be moved.
  ///
  /// Can only be used if [enableLongPress] is enabled.
  final Duration longPressDelay;

  /// Every time one ore more items change the position, this function is called.
  ///
  /// [updatedChildren] contains a list of all children in the same order they
  /// were added to this widget. The number in the list represents the current
  /// order in the list.
  ///
  /// For example you have three items. At the beginning, the order would be
  /// [0, 1, 2]. After changing the position between the first and last item,
  /// the position changes, so the list would have the following order [2, 0, 1].
  /// All items have still the same order in the list, but the first item has
  /// now the position 2, the second item the position 0 and the last item the
  /// position 1.
  final void Function(List<int> updatedChildren)? onUpdate;

  @override
  State<ReorderableGridView> createState() => _ReorderableGridViewState();
}

class _ReorderableGridViewState extends State<ReorderableGridView>
    with WidgetsBindingObserver {
  /// Represents all children inside a map with the index as key
  Map<int, GridItemEntity> _childrenIdMap = {};

  /// Represents all children inside a map with the orderId as key
  Map<int, GridItemEntity> _childrenOrderIdMap = {};

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
  void didUpdateWidget(covariant ReorderableGridView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.children.length != widget.children.length) {
      setState(() {
        _childrenIdMap = {};
        _childrenOrderIdMap = {};
        hasBuiltItems = false;
      });
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
    final children = widget.children;

    return SingleChildScrollView(
      controller: _scrollController,
      child: Builder(
        builder: (context) {
          // after all children are added to animatedChildren
          if (hasBuiltItems && children.length == _childrenIdMap.length) {
            return SizedBox(
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
                  longPressDelay: widget.longPressDelay,
                  enabled: !widget.lockedChildren.contains(index),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  void _updateWrapSize() {
    final wrapBox = _wrapKey.currentContext!.findRenderObject()! as RenderBox;
    _wrapSize = wrapBox.size;
  }

  /// Creates [GridItemEntity] that contains all information for this widget.
  ///
  /// After an item was built inside the [Wrap], this method takes all his
  /// information to create a [GridItemEntity]. That includes the size and
  /// position (global and locally inside [Wrap] of the widget. Also an id and
  /// orderId is added that are important to know where the item is ordered and
  /// to identify the original item after changing the position.
  void _handleCreated(
    BuildContext context,
    GlobalKey key,
    Widget item,
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

      // in this case id is equal to orderId
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
          item: item,
          orderId: id,
        );
        _childrenIdMap[id] = gridItemEntity;
        _childrenOrderIdMap[id] = gridItemEntity;

        if (_childrenIdMap.entries.length == widget.children.length) {
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
        );
      }

      // notifiy about the update in the list
      if (widget.onUpdate != null) {
        widget.onUpdate!(
          _childrenIdMap.values.map((e) => e.orderId).toList(),
        );
      }

      setState(() {
        _childrenIdMap = _childrenIdMap;
        _childrenOrderIdMap = _childrenOrderIdMap;
      });
    }
  }
}
