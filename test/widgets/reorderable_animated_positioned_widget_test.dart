import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_animated_positioned.dart';
import 'package:flutter_test/flutter_test.dart';

import '../reorderable_builder.dart';

void main() {
  final reorderableBuilder = ReorderableBuilder();

  const givenPositionDuration = Duration(milliseconds: 500);
  const givenDraggingPositionDuration = Duration(milliseconds: 400);
  const givenChild = Placeholder();
  final givenReorderableEntity = reorderableBuilder.getEntity();

  Future<void> pumpWidget(
    WidgetTester tester, {
    required ReorderableEntity reorderableEntity,
    required bool isDragging,
    required VoidCallback onMovingFinished,
  }) async =>
      tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableAnimatedPositioned(
              reorderableEntity: reorderableEntity,
              isDragging: isDragging,
              positionChangeDuration: givenPositionDuration,
              draggingPositionChangeDuration: givenDraggingPositionDuration,
              onMovingFinished: onMovingFinished,
              child: givenChild,
            ),
          ),
        ),
      );

  void findContainerWithMatrix({
    required double x,
    required double y,
  }) {
    expect(
        find.byWidgetPredicate((widget) =>
            widget is Container &&
            widget.transform == Matrix4.translationValues(x, y, 0.0)),
        findsOneWidget);
  }

  group('#initState', () {
    testWidgets(
        'GIVEN isDragging = true and reorderableEntity '
        'WHEN pumping [ReorderableAnimatedPositioned] '
        'THEN should show expected widgets', (WidgetTester tester) async {
      // given
      int callCounter = 0;

      // when
      await pumpWidget(
        tester,
        reorderableEntity: givenReorderableEntity,
        isDragging: true,
        onMovingFinished: () {
          callCounter++;
        },
      );
      await tester.pumpAndSettle();

      // then
      expect(
          find.byWidgetPredicate((widget) =>
              widget is Container &&
              widget.transform == Matrix4.translationValues(0.0, 0.0, 0.0) &&
              widget.child == givenChild),
          findsOneWidget);
      expect(callCounter, equals(0));
    });

    testWidgets(
        'GIVEN isDragging = false and reorderableEntity.isNew = true '
        'WHEN pumping [ReorderableAnimatedPositioned] '
        'THEN should show expected widgets', (WidgetTester tester) async {
      // given
      final givenReorderableEntity = reorderableBuilder.getEntity(
        originalOrderId: -1,
      );
      int callCounter = 0;

      // when
      await pumpWidget(
        tester,
        reorderableEntity: givenReorderableEntity,
        isDragging: false,
        onMovingFinished: () {
          callCounter++;
        },
      );
      await tester.pumpAndSettle();

      // then
      findContainerWithMatrix(x: 0.0, y: 0.0);
      expect(callCounter, equals(0));
    });

    testWidgets(
        'GIVEN isDragging = false and reorderableEntity.isNew = false '
        'WHEN pumping [ReorderableAnimatedPositioned] '
        'THEN should show expected widgets', (WidgetTester tester) async {
      // given
      final givenReorderableEntity = reorderableBuilder.getEntity(
        originalOffset: Offset.zero,
        updatedOffset: const Offset(100.0, 200.0),
      );
      int callCounter = 0;

      // when
      await pumpWidget(
        tester,
        reorderableEntity: givenReorderableEntity,
        isDragging: false,
        onMovingFinished: () {
          callCounter++;
        },
      );

      // then
      findContainerWithMatrix(x: -100.0, y: -200.0);
      expect(callCounter, equals(0));
    });

    testWidgets(
        'GIVEN [ReorderableAnimatedPositioned], isDragging = false '
        'and reorderableEntity.isNew = false '
        'WHEN animation finishes '
        'THEN should call onMovingFinished', (WidgetTester tester) async {
      // given
      final givenReorderableEntity = reorderableBuilder.getEntity(
        originalOffset: Offset.zero,
        updatedOffset: const Offset(100.0, 200.0),
      );
      int callCounter = 0;

      await pumpWidget(
        tester,
        reorderableEntity: givenReorderableEntity,
        isDragging: false,
        onMovingFinished: () {
          callCounter++;
        },
      );

      // when
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // then
      expect(callCounter, equals(1));
    });
  });

  group('#didUpdateWidget', () {
    Future<void> pumpWidgetAndUpdate(
      WidgetTester tester, {
      required ReorderableEntity reorderableEntity,
      required ReorderableEntity updatedReorderableEntity,
      required bool isDragging,
      required VoidCallback onMovingFinished,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TestUpdateReorderableAnimatedPositioned(
              reorderableEntity: reorderableEntity,
              updatedReorderableEntity: updatedReorderableEntity,
              isDragging: isDragging,
              onMovingFinished: onMovingFinished,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextButton));
      // finish animation of position
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
    }

    testWidgets(
        'GIVEN updatedOffset changed, buildingOffset same, key same '
        'and isDragging = true, isNew = true, isBuildingOffset = true '
        'WHEN pumping [ReorderableAnimatedPositioned] '
        'THEN nothing should happen', (WidgetTester tester) async {
      // given
      final givenReorderableEntity = reorderableBuilder.getEntity(
        originalOffset: Offset.zero,
        updatedOffset: const Offset(100.0, 200.0),
        originalOrderId: 0,
      );
      final givenUpdatedReorderableEntity = reorderableBuilder.getEntity(
        originalOffset: Offset.zero,
        updatedOffset: const Offset(0.0, 0.0),
        originalOrderId: -1,
        isBuildingOffset: true,
      );
      int callCounter = 0;

      // when
      await pumpWidgetAndUpdate(
        tester,
        reorderableEntity: givenReorderableEntity,
        updatedReorderableEntity: givenUpdatedReorderableEntity,
        isDragging: true,
        onMovingFinished: () {
          callCounter++;
        },
      );

      // then
      findContainerWithMatrix(x: 0.0, y: 0.0);
      expect(callCounter, equals(0));
    });

    testWidgets(
        'GIVEN updatedOffset changed, buildingOffset same, key same '
        'and isDragging = false, isNew = false, isBuildingOffset = false '
        'and hasSwappedOrder = false '
        'WHEN pumping [ReorderableAnimatedPositioned] '
        'THEN should animate position and call onMovingFinished',
        (WidgetTester tester) async {
      // given
      final givenReorderableEntity = reorderableBuilder.getEntity(
        originalOffset: Offset.zero,
        updatedOffset: const Offset(0.0, 0.0),
        originalOrderId: 0,
      );
      final givenUpdatedReorderableEntity = reorderableBuilder.getEntity(
        originalOffset: Offset.zero,
        updatedOffset: const Offset(100.0, 200.0),
        originalOrderId: 1,
        isBuildingOffset: false,
        hasSwappedOrder: false,
      );
      int callCounter = 0;

      // when
      await pumpWidgetAndUpdate(
        tester,
        reorderableEntity: givenReorderableEntity,
        updatedReorderableEntity: givenUpdatedReorderableEntity,
        isDragging: false,
        onMovingFinished: () {
          callCounter++;
        },
      );

      // then
      expect(callCounter, equals(1));
    });

    testWidgets(
        'GIVEN updatedOffset same, buildingOffset changed, key same '
        'and isDragging = false, isNew = false, isBuildingOffset = false '
        'and hasSwappedOrder = true '
        'WHEN pumping [ReorderableAnimatedPositioned] '
        'THEN should animate position and call onMovingFinished',
        (WidgetTester tester) async {
      // given
      final givenReorderableEntity = reorderableBuilder.getEntity(
        originalOffset: Offset.zero,
        updatedOffset: const Offset(100.0, 200.0),
        originalOrderId: 0,
        isBuildingOffset: true,
      );
      final givenUpdatedReorderableEntity = reorderableBuilder.getEntity(
        originalOffset: Offset.zero,
        updatedOffset: const Offset(100.0, 200.0),
        originalOrderId: 1,
        isBuildingOffset: false,
        hasSwappedOrder: true,
      );
      int callCounter = 0;

      // when
      await pumpWidgetAndUpdate(
        tester,
        reorderableEntity: givenReorderableEntity,
        updatedReorderableEntity: givenUpdatedReorderableEntity,
        isDragging: false,
        onMovingFinished: () {
          callCounter++;
        },
      );

      // then
      expect(callCounter, equals(1));
    });

    testWidgets(
        'GIVEN updatedOffset same, buildingOffset same, key changed '
        'and isDragging = true, isNew = false '
        'WHEN pumping [ReorderableAnimatedPositioned] '
        'THEN should animate position', (WidgetTester tester) async {
      // given
      final givenReorderableEntity = reorderableBuilder.getEntity(
        originalOffset: Offset.zero,
        updatedOffset: const Offset(100.0, 200.0),
        originalOrderId: 0,
        key: 'original',
      );
      final givenUpdatedReorderableEntity = reorderableBuilder.getEntity(
        originalOffset: Offset.zero,
        updatedOffset: const Offset(100.0, 200.0),
        originalOrderId: 1,
        isBuildingOffset: false,
        hasSwappedOrder: true,
        key: 'updated',
      );
      int callCounter = 0;

      // when
      await pumpWidgetAndUpdate(
        tester,
        reorderableEntity: givenReorderableEntity,
        updatedReorderableEntity: givenUpdatedReorderableEntity,
        isDragging: true,
        onMovingFinished: () {
          callCounter++;
        },
      );

      // then
      findContainerWithMatrix(x: 100.0, y: 200.0);
      expect(callCounter, equals(0));
    });

    testWidgets(
        'GIVEN updatedOffset same, buildingOffset same, key same '
        'WHEN pumping [ReorderableAnimatedPositioned] '
        'THEN nothing should happen', (WidgetTester tester) async {
      // given
      final givenReorderableEntity = reorderableBuilder.getEntity(
        originalOffset: Offset.zero,
        updatedOffset: const Offset(0.0, 0.0),
        originalOrderId: 0,
      );
      final givenUpdatedReorderableEntity = reorderableBuilder.getEntity(
        originalOffset: Offset.zero,
        updatedOffset: const Offset(0.0, 0.0),
        originalOrderId: 1,
        isBuildingOffset: false,
        hasSwappedOrder: true,
      );
      int callCounter = 0;

      // when
      await pumpWidgetAndUpdate(
        tester,
        reorderableEntity: givenReorderableEntity,
        updatedReorderableEntity: givenUpdatedReorderableEntity,
        isDragging: true,
        onMovingFinished: () {
          callCounter++;
        },
      );

      // then
      findContainerWithMatrix(x: 0.0, y: 0.0);
      expect(callCounter, equals(0));
    });
  });

  group('#animationDuration', () {
    testWidgets(
        'GIVEN positionChangeDuration = 500ms '
        'WHEN pumping before and after the duration '
        'THEN onMovingFinished is called only after 500ms',
        (WidgetTester tester) async {
      // given
      final givenReorderableEntity = reorderableBuilder.getEntity(
        originalOffset: Offset.zero,
        updatedOffset: const Offset(100.0, 200.0),
      );
      int callCounter = 0;

      // when
      await pumpWidget(
        tester,
        reorderableEntity: givenReorderableEntity,
        isDragging: false,
        onMovingFinished: () {
          callCounter++;
        },
      );

      // start first animation frame before measuring elapsed duration
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 499));

      // then
      expect(callCounter, equals(0));

      // when
      await tester.pump(const Duration(milliseconds: 2));
      await tester.pump();

      // then
      expect(callCounter, equals(1));
    });

    testWidgets(
        'GIVEN draggingPositionChangeDuration = 400ms '
        'WHEN updating position while dragging '
        'THEN translation reaches end offset after 400ms',
        (WidgetTester tester) async {
      // given
      final givenReorderableEntity = reorderableBuilder.getEntity(
        originalOffset: Offset.zero,
        updatedOffset: const Offset(0.0, 0.0),
        originalOrderId: 0,
      );
      final givenUpdatedReorderableEntity = reorderableBuilder.getEntity(
        originalOffset: Offset.zero,
        updatedOffset: const Offset(100.0, 200.0),
        originalOrderId: 1,
        isBuildingOffset: false,
        key: 'updated',
      );
      int callCounter = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TestUpdateReorderableAnimatedPositioned(
              reorderableEntity: givenReorderableEntity,
              updatedReorderableEntity: givenUpdatedReorderableEntity,
              isDragging: true,
              positionChangeDuration: givenPositionDuration,
              draggingPositionChangeDuration: givenDraggingPositionDuration,
              onMovingFinished: () {
                callCounter++;
              },
            ),
          ),
        ),
      );

      // when
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 399));

      // then
      findContainerWithMatrix(x: 99.75, y: 199.5);
      expect(callCounter, equals(0));

      // when
      await tester.pump(const Duration(milliseconds: 1));

      // then
      findContainerWithMatrix(x: 100.0, y: 200.0);
      expect(callCounter, equals(0));
    });
  });
}

class _TestUpdateReorderableAnimatedPositioned extends StatefulWidget {
  final ReorderableEntity reorderableEntity;
  final ReorderableEntity updatedReorderableEntity;
  final bool isDragging;
  final VoidCallback onMovingFinished;
  final Duration positionChangeDuration;
  final Duration draggingPositionChangeDuration;

  const _TestUpdateReorderableAnimatedPositioned({
    required this.reorderableEntity,
    required this.updatedReorderableEntity,
    required this.isDragging,
    required this.onMovingFinished,
    this.positionChangeDuration = const Duration(milliseconds: 200),
    this.draggingPositionChangeDuration = const Duration(milliseconds: 300),
  });

  @override
  State<_TestUpdateReorderableAnimatedPositioned> createState() =>
      _TestUpdateReorderableAnimatedPositionedState();
}

class _TestUpdateReorderableAnimatedPositionedState
    extends State<_TestUpdateReorderableAnimatedPositioned> {
  late ReorderableEntity reorderableEntity = widget.reorderableEntity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextButton(
            onPressed: () {
              setState(() {
                reorderableEntity = widget.updatedReorderableEntity;
              });
            },
            child: const Text('Update'),
          ),
          ReorderableAnimatedPositioned(
            reorderableEntity: reorderableEntity,
            isDragging: widget.isDragging,
            positionChangeDuration: widget.positionChangeDuration,
            draggingPositionChangeDuration:
                widget.draggingPositionChangeDuration,
            onMovingFinished: widget.onMovingFinished,
            child: const Placeholder(),
          ),
        ],
      ),
    );
  }
}
