import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_reorderable_grid_view/entities/order_update_entity.dart';
import 'package:flutter_reorderable_grid_view/release_4/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/release_4/widgets/reorderable_animated_opacity.dart';
import 'package:flutter_reorderable_grid_view/release_4/widgets/reorderable_animated_positioned.dart';
import 'package:flutter_reorderable_grid_view/release_4/widgets/reorderable_init_child.dart';

typedef DraggableBuilder = Widget Function(
  List<Widget> children,
);

typedef ReorderListCallback = void Function(List<OrderUpdateEntity>);

/// Enables animated drag and drop behaviour for built widgets in [builder].
///
/// Be sure not to replace, add or remove your children while you are dragging
/// because this can lead to an unexpected behavior.
class ReorderableBuilder extends StatefulWidget {
  ///
  final List<Widget>? children;

  ///
  final Widget Function(
    Widget Function(Widget child, int index) itemBuilder,
  )? childBuilder;

  /// Specify indices for [children] that should not change their position while dragging.
  ///
  /// Default value: <int>[]
  final List<int> lockedIndices;

  /// The drag of a child can be started with the long press.
  ///
  /// Default value: true
  final bool enableLongPress;

  /// Specify the [Duration] for the pressed child before starting the dragging.
  ///
  /// Default value: kLongPressTimeout
  final Duration longPressDelay;

  /// When disabling draggable, the drag and drop behavior is not working.
  ///
  /// When [enableDraggable] is true, [onReorder] must not be null.
  ///
  /// Default value: true
  final bool enableDraggable;

  /// Enables the functionality to scroll while dragging a child to the top or bottom.
  ///
  /// Combined with the value of [automaticScrollExtent], an automatic scroll starts,
  /// when you drag the child and the widget of [builder] is scrollable.
  ///
  /// Defualt value: true
  final bool enableScrollingWhileDragging;

  /// Defines the height of the top or bottom before the dragged child indicates a scrolling.
  ///
  /// Default value: 80.0
  final double automaticScrollExtent;

  /// [BoxDecoration] for the child that is dragged around.
  final BoxDecoration? dragChildBoxDecoration;

  /// Callback to return updated [children].
  final DraggableBuilder? builder;

  /// After releasing the dragged child, [onReorder] is called.
  ///
  /// [enableDraggable] has to be true to ensure this is called.
  final ReorderListCallback? onReorder;

  /// Adding delay after initializing [children].
  ///
  /// Usually, the delay would be a postFrameCallBack. But sometimes, if the app
  /// is a bit slow, or there are a lot of things happening at the same time, a
  /// longer delay is necessary to ensure a correct behavior when using drag and drop.
  ///
  /// Not recommended to use.
  final Duration? initDelay;

  /// Callback when dragging starts.
  ///
  /// Prevent updating your children while you are dragging because this can lead
  /// to an unexpected behavior.
  final VoidCallback? onDragStarted;

  /// Callback when the dragged child was released.
  final VoidCallback? onDragEnd;

  /// [ScrollController] to get the current scroll position. Important for calculations!
  ///
  /// This controller has to be assigned if the returned widget of [builder] is
  /// scrollable. Every [GridView] is scrollable by default.
  ///
  /// So usually, you should assign the controller to the [ReorderableBuilder]
  /// and to your [GridView].
  final ScrollController? scrollController;

  const ReorderableBuilder({
    required this.children,
    required this.builder,
    this.scrollController,
    this.onReorder,
    this.lockedIndices = const [],
    this.enableLongPress = true,
    this.longPressDelay = kLongPressTimeout,
    this.enableDraggable = true,
    this.automaticScrollExtent = 80.0,
    this.enableScrollingWhileDragging = true,
    this.dragChildBoxDecoration,
    this.initDelay,
    this.onDragStarted,
    this.onDragEnd,
    Key? key,
  })  : assert((enableDraggable && onReorder != null) || !enableDraggable),
        childBuilder = null,
        super(key: key);

  const ReorderableBuilder.builder({
    required this.childBuilder,
    this.scrollController,
    this.onReorder,
    this.lockedIndices = const [],
    this.enableLongPress = true,
    this.longPressDelay = kLongPressTimeout,
    this.enableDraggable = true,
    this.automaticScrollExtent = 80.0,
    this.enableScrollingWhileDragging = true,
    this.dragChildBoxDecoration,
    this.initDelay,
    this.onDragStarted,
    this.onDragEnd,
    Key? key,
  })  : assert((enableDraggable && onReorder != null) || !enableDraggable),
        children = null,
        builder = null,
        super(key: key);

  @override
  State<ReorderableBuilder> createState() => _ReorderableBuilderState();
}

class _ReorderableBuilderState extends State<ReorderableBuilder> {
  var _childrenOrderMap = <int, ReorderableEntity>{};
  var _childrenKeyMap = <dynamic, ReorderableEntity>{};
  final _offsetMap = <int, Offset>{};

  @override
  void initState() {
    super.initState();

    final children = widget.children;
    if (children == null) return;

    var index = 0;
    for (final child in children) {
      _checkChildState(child: child);
      assert(!_childrenKeyMap.containsKey(child.key), "Key is duplicated!");
      final key = child.key! as ValueKey;
      final reorderableEntity = ReorderableEntity.create(
        key: key,
        updatedOrderId: index,
      );
      _updateMaps(reorderableEntity: reorderableEntity);
      index++;
    }
  }

  @override
  void didUpdateWidget(covariant ReorderableBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    final children = widget.children;
    if (oldWidget.children == children || children == null) return;

    var updatedChildrenKeyMap = <dynamic, ReorderableEntity>{};
    var updatedChildrenOrderMap = <int, ReorderableEntity>{};

    var index = 0;
    for (final child in children) {
      final reorderableEntity = _getReorderableEntity(
        child: child,
        index: index++,
      );
      final originalOrderId = reorderableEntity.originalOrderId;
      updatedChildrenOrderMap[originalOrderId] = reorderableEntity;
      updatedChildrenKeyMap[reorderableEntity.key.value] = reorderableEntity;
    }

    setState(() {
      _childrenOrderMap = updatedChildrenOrderMap;
      _childrenKeyMap = updatedChildrenKeyMap;
    });
  }

  void _updateMaps({required ReorderableEntity reorderableEntity}) {
    _childrenOrderMap[reorderableEntity.originalOrderId] = reorderableEntity;
    _childrenKeyMap[reorderableEntity.key.value] = reorderableEntity;
  }

  @override
  Widget build(BuildContext context) {
    final builder = widget.builder;
    if (builder == null) {
      return widget.childBuilder!(_buildItem);
    } else {
      return builder(_wrapChildren());
    }
  }

  Widget _buildItem(Widget child, int index) {
    final childInKeyMap = _childrenKeyMap[(child.key as ValueKey).value];
    if (childInKeyMap != null &&
        childInKeyMap.originalOrderId == ReorderableEntity.isNewChildId) {
      return _wrapChild(
        child: child,
        reorderableEntity: childInKeyMap,
      );
    }

    final reorderableEntity = _getReorderableEntity(
      child: child,
      index: index,
    );
    final originalOrderId = reorderableEntity.originalOrderId;
    // todo vlt eher der index?
    _childrenOrderMap[originalOrderId] = reorderableEntity;
    _childrenKeyMap[reorderableEntity.key.value] = reorderableEntity;
    return _wrapChild(
      child: child,
      reorderableEntity: reorderableEntity,
    );
  }

  ReorderableEntity _getReorderableEntity({
    required Widget child,
    required int index,
  }) {
    _checkChildState(child: child);

    final key = child.key as ValueKey;
    final childInKeyMap = _childrenKeyMap[key.value];
    final offset = _offsetMap[index];
    late final ReorderableEntity reorderableEntity;

    if (childInKeyMap == null) {
      reorderableEntity = ReorderableEntity.create(
        key: key,
        updatedOrderId: index,
        offset: offset,
      );
    } else {
      reorderableEntity = childInKeyMap.updated(
        updatedOrderId: index,
        updatedOffset: offset,
      );
    }
    return reorderableEntity;
  }

  List<Widget> _wrapChildren() {
    final children = widget.children;
    if (children == null) return <Widget>[];

    final updatedChildren = <Widget>[];

    for (final child in children) {
      final reorderableEntity = _childrenKeyMap[(child.key as ValueKey).value]!;
      updatedChildren.add(
        _wrapChild(
          child: child,
          reorderableEntity: reorderableEntity,
        ),
      );
    }
    return updatedChildren;
  }

  Widget _wrapChild({
    required Widget child,
    required ReorderableEntity reorderableEntity,
  }) {
    return ReorderableAnimatedOpacity(
      reorderableEntity: reorderableEntity,
      onOpacityFinished: _handleOpacityFinished,
      onDispose: (ReorderableEntity reorderableEntity) {
        // with children, this would lead into an opacity bug with the last child
        if (widget.children == null) {
          _childrenKeyMap.remove(reorderableEntity.key.value);
          _childrenOrderMap.remove(reorderableEntity.updatedOrderId);
        }
      },
      child: ReorderableAnimatedPositioned(
        reorderableEntity: reorderableEntity,
        onMovingFinished: _handleMovingFinished,
        child: ReorderableInitChild(
          reorderableEntity: reorderableEntity,
          onCreated: _handleCreatedChild,
          child: child,
        ),
      ),
    );
  }

  void _handleMovingFinished(ReorderableEntity reorderableEntity) {
    _updateMaps(
      reorderableEntity: reorderableEntity.positionUpdated(),
    );
    setState(() {});
  }

  void _handleOpacityFinished(ReorderableEntity reorderableEntity) {
    _updateMaps(
      reorderableEntity: reorderableEntity.fadedIn(),
    );
    setState(() {});
  }

  void _handleCreatedChild(
    GlobalKey key,
    ReorderableEntity reorderableEntity,
  ) {
    Offset? offset;

    var index = reorderableEntity.updatedOrderId;
    final renderObject = key.currentContext?.findRenderObject();

    if (renderObject != null && _offsetMap[index] == null) {
      final renderBox = renderObject as RenderBox;
      offset = renderBox.localToGlobal(Offset.zero);
      _offsetMap[index] = offset;
    }

    _updateMaps(
      reorderableEntity: reorderableEntity.creationFinished(
        offset: offset,
      ),
    );
    setState(() {});
  }

  void _checkChildState({
    required Widget child,
  }) {
    assert(child.key != null, "Key can't be null!");
    assert(child.key is ValueKey, 'Key has to type of [ValueKey]!');
  }
}
