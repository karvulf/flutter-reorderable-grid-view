import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/grid_item_entity.dart';
import 'package:flutter_reorderable_grid_view/entities/reoderable_parameters.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_grid_view_parameters.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_type.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_wrap_parameters.dart';
import 'package:flutter_reorderable_grid_view/utils/reorderable_grid_utils.dart';
import 'package:flutter_reorderable_grid_view/widgets/draggable_item.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_single_child_scroll_view.dart';

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
  var _reorderableEntity = ReorderableEntity.create();
  final _removedReorderableEntity = ReorderableEntity.create();
  var _proxyReorderableEntity = ReorderableEntity.create();

  /// Bool to know if all children were build and updated.
  bool hasBuiltItems = false;

  /// Key of the [Wrap] or [GridView] that was used to build the widget
  final _reorderableKey = GlobalKey();

  /// Important for detecting the correct position of the dragged child inside Content
  final _reorderableContentKey = GlobalKey();

  /// Size of the [Wrap] that was used to build the widget
  Size _wrapSize = Size.zero;

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
  void didUpdateWidget(covariant Reorderable oldWidget) {
    super.didUpdateWidget(oldWidget);

    // childrenCopy has to get an update
    if (oldWidget.children != widget.children) {
      // resetting maps to built all children correctly when children size changes
      if (oldWidget.children.length != widget.children.length) {
        setState(() {
          _proxyReorderableEntity = _proxyReorderableEntity.copyWith(idMap: {});
          hasBuiltItems = false;
          if (widget.children.isEmpty) {
            _updateRemovedChildren();
            _reorderableEntity.clear();
          }
        });
      } else {
        setState(() {
          _reorderableEntity.children = List<Widget>.from(widget.children);
        });
      }
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
        setState(() {
          hasBuiltItems = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ReorderableSingleChildScrollView(
          reorderableEntity: _reorderableEntity,
          sizedBoxKey: _reorderableContentKey,
          physics: widget.physics,
          height: _wrapSize.height,
          width: _wrapSize.width,
          clipBehavior: widget.clipBehavior,
          enableAnimation: widget.enableAnimation,
          enableLongPress: widget.enableLongPress,
          longPressDelay: widget.longPressDelay,
          lockedChildren: widget.lockedChildren,
          onDragUpdate: _handleDragUpdate,
        ),
        IgnorePointer(
          ignoring: true,
          child: ReorderableSingleChildScrollView(
            reorderableEntity: _removedReorderableEntity,
            height: _wrapSize.height,
            width: _wrapSize.width,
            clipBehavior: widget.clipBehavior,
            willBeRemoved: true,
            onRemoveItem: _handleRemoveItem,
          ),
        ),
        Builder(
          builder: (context) {
            // after all children are added to animatedChildren
            if (!hasBuiltItems) {
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
                    orderId: index,
                    onCreated: _handleCreated,
                    longPressDelay: widget.longPressDelay,
                    enabled: !widget.lockedChildren.contains(index),
                  ),
                ),
              );
              switch (widget.reorderableType) {
                case ReorderableType.wrap:
                  return SingleChildScrollView(
                    child: Wrap(
                      key: _reorderableKey,
                      spacing: widget.spacing,
                      runSpacing: widget.runSpacing,
                      children: generatedChildren,
                    ),
                  );
                case ReorderableType.gridView:
                  return SingleChildScrollView(
                      child: GridView(
                    key: _reorderableKey,
                    shrinkWrap: true,
                    padding: widget.padding,
                    gridDelegate: widget.gridDelegate,
                    children: generatedChildren,
                    clipBehavior: widget.clipBehavior,
                  ));
                case ReorderableType.gridViewCount:
                  return SingleChildScrollView(
                    child: GridView.count(
                      key: _reorderableKey,
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
                      key: _reorderableKey,
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
    final wrapBox =
        _reorderableKey.currentContext!.findRenderObject()! as RenderBox;
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
    int orderId,
    Widget child,
  ) {
    final renderObject = key.currentContext?.findRenderObject();

    if (renderObject != null) {
      final wrapBox =
          _reorderableKey.currentContext!.findRenderObject()! as RenderBox;
      final _wrapPosition = wrapBox.localToGlobal(Offset.zero);

      final box = renderObject as RenderBox;
      final position = box.localToGlobal(Offset.zero);
      final size = box.size;

      final localPosition = Offset(
        position.dx - _wrapPosition.dx,
        position.dy - _wrapPosition.dy,
      );

      final proxyIdMap = _proxyReorderableEntity.idMap;
      // in this case id is equal to orderId and _childrenOrderIdMap must be used
      MapEntry<int, GridItemEntity>? existingEntry;
      for (final entry in proxyIdMap.entries) {
        if (entry.value.orderId == orderId) {
          existingEntry = entry;
          break;
        }
      }

      // if exists update position related to the orderId
      if (existingEntry != null) {
        final updatedGridItemEntity = existingEntry.value.copyWith(
          localPosition: localPosition,
          size: size,
        );
        proxyIdMap[existingEntry.key] = updatedGridItemEntity;

        // finished building all entries
        if (orderId == proxyIdMap.entries.length - 1) {
          _updateWrapSize();
          setState(() {
            hasBuiltItems = true;
          });
        }
      } else {
        final gridItemEntity = GridItemEntity(
          localPosition: localPosition,
          size: size,
          orderId: orderId,
        );
        proxyIdMap[orderId] = gridItemEntity;

        // checking if all widgets were built in proxy map
        if (proxyIdMap.length == widget.children.length) {
          // that means that at least one child were removed
          if (proxyIdMap.length < _reorderableEntity.idMap.length) {
            _updateRemovedChildren();
          }
          _updateWrapSize();

          setState(() {
            hasBuiltItems = true;
            _reorderableEntity = _reorderableEntity.copyWith(
              children: List<Widget>.from(widget.children),
              idMap: proxyIdMap,
            );
          });
        }
      }
    }
  }

  /// Searching for removed children and updates [_removedChildrenMap].
  ///
  /// Compares [_childrenIdMapProxy] that represents all new children and
  /// [_childrenIdMap] that represents the children before the update. When one
  /// child in [_childrenIdMapProxy] wasn't found, then that means it was removed.
  void _updateRemovedChildren() {
    for (int orderId = 0;
        orderId < _reorderableEntity.children.length;
        orderId++) {
      final child = _reorderableEntity.children[orderId];
      var found = false;

      for (final proxyChild in widget.children) {
        if (child.key == proxyChild.key) {
          found = true;
          break;
        }
      }
      if (!found) {
        final entry = _reorderableEntity.idMap.entries.firstWhere(
          (entry) => entry.value.orderId == orderId,
        );
        if (!_removedReorderableEntity.idMap.containsKey(entry.key)) {
          _removedReorderableEntity.idMap[entry.key] = entry.value.copyWith(
            orderId: _removedReorderableEntity.idMap.length,
          );
          _removedReorderableEntity.children.add(child);
        }
      }
    }
  }

  /// Called after item was removed with animation
  ///
  /// Updates all children that have a bigger orderId to make sure that
  /// there is no access to a child that is outside children list when the
  /// child was removed.
  void _handleRemoveItem(int id, Key key) {
    final idMap = _removedReorderableEntity.idMap;
    final entry = idMap[id]!;
    for (int i = entry.orderId + 1; i < idMap.length; i++) {
      for (final entry in idMap.entries) {
        if (entry.value.orderId == i) {
          idMap[entry.key] = entry.value.copyWith(orderId: i - 1);
        }
      }
    }
    setState(() {
      idMap.remove(id);
      _removedReorderableEntity.children.removeWhere(
        (child) => child.key == key,
      );
    });
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
    int dragOrderId,
    Offset position,
    Size size,
  ) {
    final renderParentObject =
        _reorderableContentKey.currentContext?.findRenderObject();

    if (renderParentObject == null) {
      return;
    }

    final parentBox = renderParentObject as RenderBox;
    final localPosition = parentBox.globalToLocal(position);

    final collisionOrderId = getItemsCollision(
      orderId: dragOrderId,
      position: localPosition,
      size: size,
      childrenIdMap: _reorderableEntity.idMap,
      lockedChildren: widget.lockedChildren,
    );

    if (collisionOrderId != null && collisionOrderId != dragOrderId) {
      // item changes multiple positions to the positive direction
      if (collisionOrderId > dragOrderId &&
          collisionOrderId - dragOrderId > 1) {
        handleMultipleCollisionsForward(
          collisionOrderId: collisionOrderId,
          dragOrderId: dragOrderId,
          childrenIdMap: _reorderableEntity.idMap,
          lockedChildren: widget.lockedChildren,
          onReorder: _handleReorder,
        );
      }
      // item changes multiple positions to the negative direction
      else if (collisionOrderId < dragOrderId &&
          dragOrderId - collisionOrderId > 1) {
        handleMultipleCollisionsBackward(
          dragOrderId: dragOrderId,
          collisionOrderId: collisionOrderId,
          childrenIdMap: _reorderableEntity.idMap,
          lockedChildren: widget.lockedChildren,
          onReorder: _handleReorder,
        );
      }
      // item changes position only to one item
      else {
        handleOneCollision(
          dragOrderId: dragOrderId,
          collisionOrderId: collisionOrderId,
          childrenIdMap: _reorderableEntity.idMap,
          lockedChildren: widget.lockedChildren,
          onReorder: _handleReorder,
        );
      }

      setState(() {
        _reorderableEntity = _reorderableEntity;
      });
    }
  }

  void _handleReorder(int oldIndex, int newIndex) {
    widget.onReorder(oldIndex, newIndex);
  }
}
