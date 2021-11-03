import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/grid_item_entity.dart';
import 'package:flutter_reorderable_grid_view/entities/reoderable_parameters.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_grid_view_parameters.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_type.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_wrap_parameters.dart';
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
/// [onReorder] always give you the old and new index of the moved children.
/// Make sure to update your list of children that you used to display your data.
/// See more on the example.
class Reorderable extends StatefulWidget
    implements
        ReorderableParameters,
        ReorderableWrapParameters,
        ReorderableGridViewParameters {
  const Reorderable({
    required this.children,
    required this.reorderableType,
    required this.onReorder,
    this.lockedChildren = const [],
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.enableAnimation = true,
    this.enableLongPress = true,
    this.longPressDelay = kLongPressTimeout,
    this.mainAxisSpacing = 0.0,
    this.clipBehavior = Clip.none,
    this.maxCrossAxisExtent = 0.0,
    this.crossAxisSpacing = 0.0,
    this.gridDelegate = const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
    ),
    this.childAspectRatio = 1.0,
    this.crossAxisCount,
    this.physics,
    this.padding,
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
  final ReorderCallback onReorder;

  ///
  /// Wrap
  ///

  @override
  final double spacing;

  @override
  final double runSpacing;

  ///
  /// GridView
  ///
  @override
  final int? crossAxisCount;

  @override
  final double mainAxisSpacing;

  @override
  final ScrollPhysics? physics;

  @override
  final double maxCrossAxisExtent;

  @override
  final Clip clipBehavior;

  @override
  final double crossAxisSpacing;

  @override
  final SliverGridDelegate gridDelegate;

  @override
  final EdgeInsetsGeometry? padding;

  @override
  final double childAspectRatio;

  ///
  /// Other
  ///

  @override
  final ReorderableType reorderableType;

  @override
  State<Reorderable> createState() => _ReorderableState();
}

class _ReorderableState extends State<Reorderable> with WidgetsBindingObserver {
  /// This widget always makes a copy of [widget.children]
  List<Widget> childrenCopy = <Widget>[];

  /// Represents all children inside a map with the index as key
  Map<int, GridItemEntity> _childrenIdMap = {};
  Map<int, GridItemEntity> _childrenIdMapProxy = {};

  /// Represents all children inside a map with the orderId as key
  Map<int, GridItemEntity> _childrenOrderIdMap = {};
  Map<int, GridItemEntity> _childrenOrderIdMapProxy = {};

  /// Bool to know if all children were build and updated.
  bool hasBuiltItems = false;

  /// Key of the [Wrap] that was used to build the widget
  final _wrapKey = GlobalKey();

  final _copyReorderableKey = GlobalKey();

  /// Size of the [Wrap] that was used to build the widget
  Size _wrapSize = Size.zero;

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
          _childrenIdMapProxy = {};
          _childrenOrderIdMapProxy = {};
          hasBuiltItems = false;
          if (widget.children.isEmpty) {
            _childrenIdMap = {};
            _childrenOrderIdMap = {};
            childrenCopy.clear();
          }
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
    final generatedChildren = List.generate(
      widget.children.length,
      (index) => Visibility(
        visible: false,
        maintainAnimation: true,
        maintainSize: true,
        maintainState: true,
        child: DraggableItem(
          child: widget.children[index],
          enableLongPress: widget.enableLongPress,
          id: index,
          onCreated: _handleCreated,
          longPressDelay: widget.longPressDelay,
          enabled: !widget.lockedChildren.contains(index),
        ),
      ),
    );
    return Stack(
      children: [
        SingleChildScrollView(
          physics: widget.physics,
          child: SizedBox(
            key: _copyReorderableKey,
            height: _wrapSize.height,
            width: _wrapSize.width,
            child: Stack(
              clipBehavior: widget.clipBehavior,
              children: _childrenIdMap.entries
                  .map((e) => AnimatedDraggableItem(
                        key: e.value.key ?? Key(e.key.toString()),
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
        ),
        Builder(
          builder: (context) {
            // after all children are added to animatedChildren
            if (!hasBuiltItems) {
              switch (widget.reorderableType) {
                case ReorderableType.wrap:
                  return SingleChildScrollView(
                    child: Wrap(
                      key: _wrapKey,
                      spacing: widget.spacing,
                      runSpacing: widget.runSpacing,
                      children: generatedChildren,
                    ),
                  );
                case ReorderableType.gridView:
                  return SingleChildScrollView(
                      child: GridView(
                    key: _wrapKey,
                    shrinkWrap: true,
                    padding: widget.padding,
                    gridDelegate: widget.gridDelegate,
                    children: generatedChildren,
                    clipBehavior: widget.clipBehavior,
                  ));
                case ReorderableType.gridViewCount:
                  return SingleChildScrollView(
                    child: GridView.count(
                      key: _wrapKey,
                      shrinkWrap: true,
                      crossAxisCount: widget.crossAxisCount!,
                      mainAxisSpacing: widget.mainAxisSpacing,
                      children: generatedChildren,
                      padding: widget.padding,
                      clipBehavior: widget.clipBehavior,
                    ),
                  );
                case ReorderableType.gridViewExtent:
                  return SingleChildScrollView(
                    child: GridView.extent(
                      key: _wrapKey,
                      shrinkWrap: true,
                      maxCrossAxisExtent: widget.maxCrossAxisExtent,
                      clipBehavior: widget.clipBehavior,
                      mainAxisSpacing: widget.mainAxisSpacing,
                      crossAxisSpacing: widget.crossAxisSpacing,
                      children: generatedChildren,
                      padding: widget.padding,
                      childAspectRatio: widget.childAspectRatio,
                    ),
                  );
              }
            } else {
              return const SingleChildScrollView();
            }
          },
        ),
      ],
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
    Key? childKey,
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
      final existingItem = _childrenOrderIdMapProxy[id];

      // if exists update position related to the orderId
      if (existingItem != null) {
        final gridItemEntity = existingItem.copyWith(
          localPosition: localPosition,
          size: size,
        );
        _childrenOrderIdMapProxy[id] = gridItemEntity;
        _childrenIdMapProxy[gridItemEntity.id] = gridItemEntity;

        if (id == _childrenIdMapProxy.entries.length - 1) {
          _updateWrapSize();
          setState(() {
            hasBuiltItems = true;
          });
        }
      } else {
        final gridItemEntity = GridItemEntity(
          id: id,
          localPosition: localPosition,
          size: size,
          orderId: id,
          key: childKey,
        );
        _childrenIdMapProxy[id] = gridItemEntity;
        _childrenOrderIdMapProxy[id] = gridItemEntity;

        if (_childrenIdMapProxy.entries.length == widget.children.length) {
          _updateWrapSize();
          setState(() {
            hasBuiltItems = true;
            childrenCopy = widget.children;
            _childrenIdMap = _childrenIdMapProxy;
            _childrenOrderIdMap = _childrenOrderIdMapProxy;
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
  /// [onReorder] and the state will be updated inside this widget show the new
  /// positions of the items to the user.
  void _handleDragUpdate(
    int id,
    Offset position,
    Size size,
  ) {
    final renderParentObject =
        _copyReorderableKey.currentContext?.findRenderObject();

    if (renderParentObject == null) {
      return;
    }

    final parentBox = renderParentObject as RenderBox;
    final localPosition = parentBox.globalToLocal(position);

    final collisionId = getItemsCollision(
      id: id,
      position: localPosition,
      size: size,
      childrenIdMap: _childrenIdMap,
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
          onReorder: _handleReorder,
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
          onReorder: _handleReorder,
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
          onReorder: _handleReorder,
        );
      }

      setState(() {
        _childrenIdMap = _childrenIdMap;
        _childrenOrderIdMap = _childrenOrderIdMap;
      });
    }
  }

  void _handleReorder(int oldIndex, int newIndex) {
    setState(() {
      final draggedItem = childrenCopy[oldIndex];
      final collisionItem = childrenCopy[newIndex];
      childrenCopy[newIndex] = draggedItem;
      childrenCopy[oldIndex] = collisionItem;
    });

    widget.onReorder(oldIndex, newIndex);
  }
}
