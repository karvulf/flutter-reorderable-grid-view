import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/utils/definitions.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_animated_opcacity.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_animated_positioned.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_animated_released_container.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder_item.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_draggable.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_init_child.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helper/widget_test_helper.dart';
import '../reorderable_builder.dart';

void main() {
  final reorderableBuilder = ReorderableBuilder();

  final givenReorderableEntity = reorderableBuilder.getEntity(
    key: 'initial',
  );
  final givenUpdatedReorderableEntity = reorderableBuilder.getEntity(
    key: 'Updated',
  );
  const givenFadeInDuration = Duration(milliseconds: 300);
  const givenPositionDuration = Duration(milliseconds: 400);
  final givenReleasedReorderableEntity = reorderableBuilder.getReleasedEntity();
  const givenScrollOffset = Offset(11.1, 12.2);
  const givenReleasedChildDuration = Duration(milliseconds: 500);
  const givenEnableDraggable = true;
  const givenEnableLongPress = false;
  const givenLongPressDelay = Duration(milliseconds: 600);
  const givenDragChildBoxDecoration = BoxDecoration();
  const givenFeedbackScaleFactor = 1.31;
  const givenChild = Placeholder();

  // functions
  ReorderableEntity givenOnOpacityFinished(
    ReorderableEntity reorderableEntity,
  ) {
    return givenReorderableEntity;
  }

  ReorderableEntity givenOnMovingFinished(
    ReorderableEntity reorderableEntity,
  ) {
    return givenReorderableEntity;
  }

  ReorderableEntity givenOnCreated(
    ReorderableEntity reorderableEntity,
    GlobalKey key,
  ) {
    return givenReorderableEntity;
  }

  void givenOnDragStarted(
    ReorderableEntity reorderableEntity,
  ) {}

  void givenOnDragEnd(
    ReorderableEntity reorderableEntity,
    Offset? globalOffset,
  ) {}

  void givenOnDragCanceled(
    ReorderableEntity reorderableEntity,
  ) {}

  Future<void> pumpWidget(
    WidgetTester tester, {
    ReorderableEntity? currentDraggedEntity,
    ReturnReorderableEntityCallback? onOpacityFinished,
    ReturnReorderableEntityCallback? onMovingFinished,
    ReturnOnCreatedFunction? onCreated,
    ReorderableEntityCallback? onDragStarted,
    OnDragEndFunction? onDragEnd,
    ReorderableEntityCallback? onDragCanceled,
  }) async =>
      tester.pumpWidget(
        MaterialApp(
          home: ReorderableBuilderItem(
            reorderableEntity: givenReorderableEntity,
            fadeInDuration: givenFadeInDuration,
            onOpacityFinished: onOpacityFinished ?? givenOnOpacityFinished,
            currentDraggedEntity: currentDraggedEntity,
            positionDuration: givenPositionDuration,
            onMovingFinished: onMovingFinished ?? givenOnMovingFinished,
            onCreated: onCreated ?? givenOnCreated,
            releasedReorderableEntity: givenReleasedReorderableEntity,
            scrollOffset: givenScrollOffset,
            releasedChildDuration: givenReleasedChildDuration,
            enableDraggable: givenEnableDraggable,
            enableLongPress: givenEnableLongPress,
            longPressDelay: givenLongPressDelay,
            dragChildBoxDecoration: givenDragChildBoxDecoration,
            feedbackScaleFactor: givenFeedbackScaleFactor,
            onDragStarted: onDragStarted ?? givenOnDragStarted,
            onDragEnd: onDragEnd ?? givenOnDragEnd,
            onDragCanceled: onDragCanceled ?? givenOnDragCanceled,
            child: givenChild,
          ),
        ),
      );

  testWidgets(
      "GIVEN values with currentDraggedEntity == null "
      "WHEN pumping [ReorderableBuilderItem] "
      "THEN should show expected widgets", (tester) async {
    // given

    // when
    await pumpWidget(
      tester,
      currentDraggedEntity: null,
    );

    // then
    expect(
      find.byWidgetPredicate((widget) =>
          widget is ReorderableAnimatedOpacity &&
          widget.reorderableEntity == givenReorderableEntity &&
          widget.fadeInDuration == givenFadeInDuration &&
          widget.child is ReorderableAnimatedPositioned),
      findsOneWidget,
    );
    expect(
        find.byWidgetPredicate((widget) =>
            widget is ReorderableAnimatedPositioned &&
            widget.reorderableEntity == givenReorderableEntity &&
            !widget.isDragging &&
            widget.positionDuration == givenPositionDuration &&
            widget.child is ReorderableInitChild),
        findsOneWidget);
    expect(
        find.byWidgetPredicate((widget) =>
            widget is ReorderableInitChild &&
            widget.reorderableEntity == givenReorderableEntity &&
            widget.child is ReorderableAnimatedReleasedContainer),
        findsOneWidget);
    expect(
        find.byWidgetPredicate((widget) =>
            widget is ReorderableAnimatedReleasedContainer &&
            widget.reorderableEntity == givenReorderableEntity &&
            widget.releasedReorderableEntity ==
                givenReleasedReorderableEntity &&
            widget.scrollOffset == givenScrollOffset &&
            widget.releasedChildDuration == givenReleasedChildDuration &&
            widget.child is ReorderableDraggable),
        findsOneWidget);
    expect(
        find.byWidgetPredicate((widget) =>
            widget is ReorderableDraggable &&
            widget.reorderableEntity == givenReorderableEntity &&
            widget.enableDraggable == givenEnableDraggable &&
            widget.currentDraggedEntity == null &&
            widget.enableLongPress == givenEnableLongPress &&
            widget.longPressDelay == givenLongPressDelay &&
            widget.feedbackScaleFactor == givenFeedbackScaleFactor &&
            widget.dragChildBoxDecoration == givenDragChildBoxDecoration &&
            widget.child == givenChild),
        findsOneWidget);
  });

  testWidgets(
      "GIVEN values with currentDraggedEntity != null "
      "WHEN pumping [ReorderableBuilderItem] "
      "THEN should show expected widgets", (tester) async {
    // given

    // when
    await pumpWidget(
      tester,
      currentDraggedEntity: givenReorderableEntity,
    );

    // then
    expect(
        find.byWidgetPredicate((widget) =>
            widget is ReorderableAnimatedPositioned && widget.isDragging),
        findsOneWidget);
  });

  group('#calling functions', () {
    testWidgets(
        "GIVEN [ReorderableBuilderItem] "
        "WHEN calling onAnimationStarted "
        "THEN should update reorderableEntity and call onOpacityFinished",
        (tester) async {
      // given
      ReorderableEntity? actualReorderableEntity;

      await pumpWidget(
        tester,
        onOpacityFinished: (reorderableEntity) {
          actualReorderableEntity = reorderableEntity;
          return givenUpdatedReorderableEntity;
        },
      );

      // when
      findWidget<ReorderableAnimatedOpacity>().onAnimationStarted();
      // calling pumpAndSettle would init the normal fade in
      await tester.pump();

      // then
      expect(actualReorderableEntity, equals(givenReorderableEntity));
      expect(
          find.byWidgetPredicate((widget) =>
              widget is ReorderableDraggable &&
              widget.reorderableEntity == givenUpdatedReorderableEntity),
          findsOneWidget);
    });

    testWidgets(
        "GIVEN [ReorderableBuilderItem] "
        "WHEN calling onMovingFinished "
        "THEN should update reorderableEntity and call onMovingFinished",
        (tester) async {
      // given
      ReorderableEntity? actualReorderableEntity;

      await pumpWidget(
        tester,
        onMovingFinished: (reorderableEntity) {
          actualReorderableEntity = reorderableEntity;
          return givenUpdatedReorderableEntity;
        },
      );

      // when
      findWidget<ReorderableAnimatedPositioned>().onMovingFinished();
      await tester.pump();

      // then
      expect(actualReorderableEntity, equals(givenReorderableEntity));
      expect(
          find.byWidgetPredicate((widget) =>
              widget is ReorderableDraggable &&
              widget.reorderableEntity == givenUpdatedReorderableEntity),
          findsOneWidget);
    });

    testWidgets(
        "GIVEN [ReorderableBuilderItem] "
        "WHEN calling onCreated "
        "THEN should update reorderableEntity and call onCreated",
        (tester) async {
      // given
      final givenKey = GlobalKey();
      ReorderableEntity? actualReorderableEntity;
      GlobalKey? actualKey;

      await pumpWidget(
        tester,
        onCreated: (reorderableEntity, key) {
          actualReorderableEntity = reorderableEntity;
          actualKey = key;
          return givenUpdatedReorderableEntity;
        },
      );
      await tester.pumpAndSettle();

      // when
      findWidget<ReorderableInitChild>().onCreated(givenKey);
      await tester.pump();

      // then
      expect(actualReorderableEntity, equals(givenReorderableEntity));
      expect(actualKey, equals(givenKey));
      expect(
          find.byWidgetPredicate((widget) =>
              widget is ReorderableDraggable &&
              widget.reorderableEntity == givenUpdatedReorderableEntity),
          findsOneWidget);
    });

    testWidgets(
        "GIVEN [ReorderableBuilderItem] "
        "WHEN calling onDragStarted "
        "THEN should call onDragStarted", (tester) async {
      // given
      ReorderableEntity? actualReorderableEntity;

      await pumpWidget(
        tester,
        onDragStarted: (reorderableEntity) {
          actualReorderableEntity = reorderableEntity;
        },
      );
      await tester.pumpAndSettle();

      // when
      findWidget<ReorderableDraggable>().onDragStarted();
      await tester.pump();

      // then
      expect(actualReorderableEntity, equals(givenReorderableEntity));
    });

    testWidgets(
        "GIVEN [ReorderableBuilderItem] "
        "WHEN calling onDragEnd "
        "THEN should call onDragEnd", (tester) async {
      // given
      const givenOffset = Offset(12.34, 56.78);
      ReorderableEntity? actualReorderableEntity;
      Offset? actualGlobalOffset;

      await pumpWidget(
        tester,
        onDragEnd: (reorderableEntity, globalOffset) {
          actualReorderableEntity = reorderableEntity;
          actualGlobalOffset = globalOffset;
        },
      );
      await tester.pumpAndSettle();

      // when
      findWidget<ReorderableDraggable>().onDragEnd(givenOffset);
      await tester.pump();

      // then
      expect(actualReorderableEntity, equals(givenReorderableEntity));
      expect(actualGlobalOffset, equals(givenOffset));
    });

    testWidgets(
        "GIVEN [ReorderableBuilderItem] "
        "WHEN calling onDragCanceled "
        "THEN should call onDragCanceled", (tester) async {
      // given
      ReorderableEntity? actualReorderableEntity;

      await pumpWidget(
        tester,
        onDragCanceled: (reorderableEntity) {
          actualReorderableEntity = reorderableEntity;
        },
      );
      await tester.pumpAndSettle();

      // when
      findWidget<ReorderableDraggable>().onDragCanceled();
      await tester.pump();

      // then
      expect(actualReorderableEntity, equals(givenReorderableEntity));
    });
  });

  group('#didUpdateWidget', () {
    testWidgets(
        "GIVEN [ReorderableBuilderItem] "
        "WHEN updating reorderableEntity which is new "
        "THEN should update reorderableEntity", (tester) async {
      // given
      await tester.pumpWidget(
        MaterialApp(
          home: _TestReorderableBuilderItem(
            reorderableEntity: givenReorderableEntity,
            onUpdate: () {
              return givenUpdatedReorderableEntity;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      findWidget<ReorderableAnimatedPositioned>().onMovingFinished();
      await tester.pump();

      // when
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // then
      expect(
          find.byWidgetPredicate((widget) =>
              widget is ReorderableDraggable &&
              widget.reorderableEntity == givenUpdatedReorderableEntity),
          findsOneWidget);
    });

    testWidgets(
        "GIVEN [ReorderableBuilderItem] "
        "WHEN updating reorderableEntity which is newer but the same as the current one in widget "
        "THEN should not update reorderableEntity", (tester) async {
      // given
      final givenUpdatedReorderableEntity2 = reorderableBuilder.getEntity(
        key: 'Newer Update',
      );
      await tester.pumpWidget(
        MaterialApp(
          home: _TestReorderableBuilderItem(
            reorderableEntity: givenReorderableEntity,
            onUpdate: () {
              return givenUpdatedReorderableEntity2;
            },
            onMovingFinished: (_) {
              return givenUpdatedReorderableEntity2;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // when
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // then
      expect(
          find.byWidgetPredicate((widget) =>
              widget is ReorderableDraggable &&
              widget.reorderableEntity == givenUpdatedReorderableEntity2),
          findsOneWidget);
    });
  });
}

class _TestReorderableBuilderItem extends StatefulWidget {
  final ReorderableEntity reorderableEntity;
  final ReorderableEntity Function() onUpdate;
  final ReturnReorderableEntityCallback? onMovingFinished;

  const _TestReorderableBuilderItem({
    required this.reorderableEntity,
    required this.onUpdate,
    this.onMovingFinished,
    // ignore: unused_element
    super.key,
  });

  @override
  State<_TestReorderableBuilderItem> createState() =>
      _TestReorderableBuilderItemState();
}

class _TestReorderableBuilderItemState
    extends State<_TestReorderableBuilderItem> {
  late ReorderableEntity _reorderableEntity = widget.reorderableEntity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _reorderableEntity = widget.onUpdate();
              });
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ReorderableBuilderItem(
        reorderableEntity: _reorderableEntity,
        fadeInDuration: const Duration(milliseconds: 200),
        onOpacityFinished: (_) => _reorderableEntity,
        currentDraggedEntity: null,
        positionDuration: const Duration(milliseconds: 200),
        onMovingFinished: widget.onMovingFinished ?? (_) => _reorderableEntity,
        onCreated: (_, __) => _reorderableEntity,
        releasedReorderableEntity: null,
        scrollOffset: Offset.zero,
        releasedChildDuration: const Duration(milliseconds: 200),
        enableDraggable: true,
        enableLongPress: true,
        longPressDelay: const Duration(milliseconds: 200),
        dragChildBoxDecoration: null,
        feedbackScaleFactor: 1.5,
        onDragStarted: (_) {},
        onDragEnd: (_, __) {},
        onDragCanceled: (_) {},
        child: const SizedBox.square(
          dimension: 200.0,
          child: Placeholder(),
        ),
      ),
    );
  }
}
