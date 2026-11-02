import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_animation_config.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:flutter_reorderable_grid_view/widgets/custom_draggable.dart';
import 'package:flutter_reorderable_grid_view_example/examples/playground/playground_child.dart';
import 'package:flutter_reorderable_grid_view_example/examples/playground/playground_type.dart';

/// [ReorderableBuilder] with the layout of [type] showing [items].
class PlaygroundReorderable extends StatelessWidget {
  final PlaygroundType type;
  final List<int> items;
  final List<int> lockedIndices;
  final List<int> nonDraggableIndices;
  final ScrollController scrollController;
  final GlobalKey gridViewKey;
  final OnReorderCallback<int> onReorder;
  final ValueChanged<int> onDragStarted;
  final ValueChanged<int> onUpdatedDraggedChild;
  final ValueChanged<int> onDragEnd;

  const PlaygroundReorderable({
    required this.type,
    required this.items,
    required this.lockedIndices,
    required this.nonDraggableIndices,
    required this.scrollController,
    required this.gridViewKey,
    required this.onReorder,
    required this.onDragStarted,
    required this.onUpdatedDraggedChild,
    required this.onDragEnd,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final key = Key(gridViewKey.toString());

    switch (type) {
      case PlaygroundType.gridView:
        return ReorderableBuilder(
          key: key,
          onReorder: onReorder,
          lockedIndices: lockedIndices,
          nonDraggableIndices: nonDraggableIndices,
          onDragStarted: onDragStarted,
          onUpdatedDraggedChild: onUpdatedDraggedChild,
          onDragEnd: onDragEnd,
          scrollController: scrollController,
          reverse: true,
          animationConfig: const ReorderableAnimationConfig(
            draggingPositionChangeDuration: Duration(milliseconds: 500),
            releasedItemDuration: Duration(seconds: 1),
          ),
          builder: (children) => GridView(
            key: gridViewKey,
            controller: scrollController,
            reverse: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 4,
              crossAxisSpacing: 8,
            ),
            children: children,
          ),
          children: _buildChildren(),
        );

      case PlaygroundType.gridViewCount:
        return ReorderableBuilder(
          key: key,
          onReorder: onReorder,
          lockedIndices: lockedIndices,
          nonDraggableIndices: nonDraggableIndices,
          scrollController: scrollController,
          builder: (children) => GridView.count(
            key: gridViewKey,
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            crossAxisCount: 3,
            shrinkWrap: true,
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
            children: children,
          ),
          children: _buildChildren(),
        );

      case PlaygroundType.gridViewExtent:
        return ReorderableBuilder(
          key: key,
          onReorder: onReorder,
          lockedIndices: lockedIndices,
          nonDraggableIndices: nonDraggableIndices,
          scrollController: scrollController,
          builder: (children) => GridView.extent(
            key: gridViewKey,
            controller: scrollController,
            maxCrossAxisExtent: 200,
            padding: EdgeInsets.zero,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: children,
          ),
          children: _buildChildren(),
        );

      case PlaygroundType.gridViewBuilder:
        return ReorderableBuilder.builder(
          key: key,
          onReorder: onReorder,
          lockedIndices: lockedIndices,
          nonDraggableIndices: nonDraggableIndices,
          onDragStarted: onDragStarted,
          onUpdatedDraggedChild: onUpdatedDraggedChild,
          onDragEnd: onDragEnd,
          scrollController: scrollController,
          animationConfig: const ReorderableAnimationConfig(
            insert: ReorderableItemTransition(
              duration: Duration(milliseconds: 800),
            ),
            defaultAnimationCurve: Curves.easeOut,
            changePositionAfterFadeOut: true,
          ),
          itemCount: items.length,
          childBuilder: (itemBuilder) => GridView.builder(
            key: gridViewKey,
            controller: scrollController,
            itemCount: items.length,
            itemBuilder: (context, index) => itemBuilder(
              _buildChild(index: index),
              index,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 4,
              crossAxisSpacing: 8,
            ),
          ),
        );

      // children have different widths to show the Wrap layout
      case PlaygroundType.wrap:
        return SingleChildScrollView(
          child: ReorderableBuilder.wrap(
            key: key,
            onReorder: onReorder,
            lockedIndices: lockedIndices,
            nonDraggableIndices: nonDraggableIndices,
            builder: (children) => Wrap(
              spacing: 8,
              runSpacing: 4,
              children: children,
            ),
            children: [
              for (final (index, item) in items.indexed)
                _buildChild(index: index, width: 60.0 + (item % 4) * 40.0),
            ],
          ),
        );
    }
  }

  List<Widget> _buildChildren() => [
        for (var index = 0; index < items.length; index++)
          _buildChild(index: index),
      ];

  // CustomDraggable has to be the child itself to pass the index as data
  Widget _buildChild({required int index, double width = 100.0}) =>
      CustomDraggable(
        key: Key(items[index].toString()),
        data: index,
        child: PlaygroundChild(
          value: items[index],
          isLocked: lockedIndices.contains(index),
          width: width,
        ),
      );
}
