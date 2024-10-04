import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/custom_draggable.dart';
import 'package:flutter_reorderable_grid_view/widgets/draggable_feedback.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_draggable.dart';
import 'package:flutter_test/flutter_test.dart';

import '../reorderable_builder.dart';

void main() {
  final reorderableBuilder = ReorderableBuilder();

  const givenChild = Text('Source');
  final givenReorderableEntity = reorderableBuilder.getEntity();
  const givenLongPressDelay = Duration(milliseconds: 300);
  const givenFeedbackScaleFactor = 1.43;

  Future<void> pumpWidget(
    WidgetTester tester, {
    required bool enableLongPress,
    required bool enableDraggable,
    ReorderableEntity? currentDraggedEntity,
    Widget? child,
    VoidCallback? onDragStarted,
    void Function(Offset globalOffset)? onDragEnd,
    VoidCallback? onDragCanceled,
  }) async =>
      tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableDraggable(
              enableDraggable: enableDraggable,
              reorderableEntity: givenReorderableEntity,
              currentDraggedEntity: currentDraggedEntity,
              enableLongPress: enableLongPress,
              longPressDelay: givenLongPressDelay,
              feedbackScaleFactor: givenFeedbackScaleFactor,
              dragChildBoxDecoration: null,
              onDragStarted: onDragStarted ?? () {},
              onDragEnd: onDragEnd ?? (_) {},
              onDragCanceled: onDragCanceled ?? () {},
              child: child ?? givenChild,
            ),
          ),
        ),
      );

  testWidgets(
      "GIVEN enableDraggable = false"
      "WHEN pumping [ReorderableDraggable] "
      "THEN should show expected widgets", (WidgetTester tester) async {
    // given

    // when
    await pumpWidget(
      tester,
      enableDraggable: false,
      enableLongPress: true,
    );

    // then
    expect(find.byWidget(givenChild), findsOneWidget);
    expect(find.byType(LongPressDraggable), findsNothing);
    expect(find.byType(Draggable), findsNothing);
  });

  testWidgets(
      "GIVEN enableDraggable = true and enableLongPress = true "
      "WHEN pumping [ReorderableDraggable] "
      "THEN should show expected widgets", (WidgetTester tester) async {
    // given

    // when
    await pumpWidget(
      tester,
      enableDraggable: true,
      enableLongPress: true,
    );

    // then
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Visibility &&
            widget.visible &&
            widget.maintainAnimation &&
            widget.maintainSize &&
            widget.maintainState &&
            widget.child is LongPressDraggable,
      ),
      findsOneWidget,
    );
    expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is LongPressDraggable &&
              widget.delay == givenLongPressDelay &&
              (widget.feedback as DraggableFeedback).size ==
                  givenReorderableEntity.size &&
              (widget.feedback as DraggableFeedback).decoration.value ==
                  const BoxDecoration() &&
              (widget.feedback as DraggableFeedback).feedbackScaleFactor ==
                  givenFeedbackScaleFactor &&
              widget.childWhenDragging == null &&
              widget.data == null &&
              widget.child == givenChild,
        ),
        findsOneWidget);
    expect(find.byType(Draggable), findsNothing);
  });

  testWidgets(
      "GIVEN dragged and reorderableEntity have same updatedOrderId "
      "and enableDraggable = true and enableLongPress = false "
      "WHEN pumping [ReorderableDraggable] "
      "THEN should show expected widgets", (WidgetTester tester) async {
    // given
    const givenData = 'data123';
    const givenCustomDraggable = CustomDraggable(
      key: Key('key'),
      data: givenData,
      child: givenChild,
    );

    // when
    await pumpWidget(
      tester,
      enableDraggable: true,
      enableLongPress: false,
      currentDraggedEntity: givenReorderableEntity,
      child: givenCustomDraggable,
    );

    // then
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Visibility &&
            !widget.visible &&
            widget.maintainAnimation &&
            widget.maintainSize &&
            widget.maintainState &&
            widget.child is LongPressDraggable,
      ),
      findsOneWidget,
    );
    expect(
        find.byWidgetPredicate((widget) =>
            widget is LongPressDraggable && widget.delay == Duration.zero),
        findsOneWidget);
  });

  group('#LongPressDraggable', () {
    testWidgets(
        "GIVEN [ReorderableDraggable] with LongPressDraggable "
        "WHEN start dragging "
        "THEN should call onDragStarted and update feedback",
        (WidgetTester tester) async {
      // given
      int callCounter = 0;

      await pumpWidget(
        tester,
        enableDraggable: true,
        enableLongPress: true,
        onDragStarted: () {
          callCounter++;
        },
      );
      await tester.pumpAndSettle();

      // when
      final firstLocation = tester.getCenter(find.text('Source'));
      await tester.startGesture(firstLocation, pointer: 7);
      await tester.pump(givenLongPressDelay);
      await tester.pumpAndSettle();

      // then
      expect(callCounter, equals(1));

      expect(find.byWidgetPredicate((widget) {
        if (widget is LongPressDraggable) {
          final boxDecoration = ((widget.feedback as DraggableFeedback)
              .decoration
              .value as BoxDecoration);
          expect(boxDecoration.boxShadow?.length, equals(1));
          final shadow = boxDecoration.boxShadow![0];
          expect(shadow.color, equals(Colors.black.withOpacity(0.2)));
          expect(shadow.spreadRadius, equals(5));
          expect(shadow.blurRadius, equals(6));
          expect(shadow.offset, equals(const Offset(0, 3)));
          return true;
        }
        return false;
      }), findsOneWidget);
    });

    testWidgets(
        "GIVEN [ReorderableDraggable] with LongPressDraggable "
        "WHEN cancelling dragging "
        "THEN should call onDragEnd and reset feedback",
        (WidgetTester tester) async {
      // given
      Offset? actualOffset;
      int onDragCanceledCallCounter = 0;

      await pumpWidget(
        tester,
        enableDraggable: true,
        enableLongPress: true,
        onDragEnd: (offset) {
          actualOffset = offset;
        },
        onDragCanceled: () {
          onDragCanceledCallCounter++;
        },
      );
      await tester.pumpAndSettle();

      final firstLocation = tester.getCenter(find.text('Source'));
      final gesture = await tester.startGesture(firstLocation, pointer: 7);
      await tester.pump(givenLongPressDelay);
      await tester.pumpAndSettle();
      await gesture.moveTo(const Offset(10.0, 20.0));
      await tester.pump();

      // when
      await gesture.up();
      await tester.pump();

      // then
      expect(actualOffset, equals(const Offset(-32.75, 10.0)));
      expect(onDragCanceledCallCounter, equals(1));

      expect(find.byWidgetPredicate((widget) {
        if (widget is LongPressDraggable) {
          final boxDecoration = ((widget.feedback as DraggableFeedback)
              .decoration
              .value as BoxDecoration);
          expect(boxDecoration.boxShadow, isNull);
          return true;
        }
        return false;
      }), findsOneWidget);
    });
  });
}
