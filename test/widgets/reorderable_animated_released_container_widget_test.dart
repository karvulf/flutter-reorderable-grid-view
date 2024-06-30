import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/released_reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_animated_released_container.dart';
import 'package:flutter_test/flutter_test.dart';

import '../reorderable_builder.dart';

// ignore_for_file: unused_element

void main() {
  final reorderableBuilder = ReorderableBuilder();

  const givenReleasedChildDuration = Duration(milliseconds: 555);
  final givenReorderableEntity = reorderableBuilder.getEntity(
    updatedOffset: const Offset(123.0, 456.0),
  );
  final givenReleasedReorderableEntity = reorderableBuilder.getReleasedEntity();
  const givenScrollOffset = Offset(1.0, 2.0);
  const givenChild = Placeholder();

  Future<void> pumpWidget(WidgetTester tester) async => tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableAnimatedReleasedContainer(
              releasedChildDuration: givenReleasedChildDuration,
              releasedReorderableEntity: givenReleasedReorderableEntity,
              reorderableEntity: givenReorderableEntity,
              scrollOffset: givenScrollOffset,
              child: givenChild,
            ),
          ),
        ),
      );

  testWidgets(
      "GIVEN _offsetAnimation = null "
      "WHEN pumping [ReorderableAnimatedReleasedContainer] "
      "THEN should show expected widgets", (WidgetTester tester) async {
    // given

    // when
    await pumpWidget(tester);

    // then
    expect(find.byWidget(givenChild), findsOneWidget);
    expect(
        find.byWidgetPredicate(
            (widget) => widget is Transform && widget.child == givenChild),
        findsNothing);
  });

  group('#didUpdateWidget', () {
    Future<void> pumpWidgetAndUpdate(
      WidgetTester tester, {
      required ReleasedReorderableEntity releasedEntity,
      required ReleasedReorderableEntity? updatedReleasedEntity,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TestUpdateReorderableAnimatedReleasedContainer(
              releasedChildDuration: givenReleasedChildDuration,
              releasedEntity: releasedEntity,
              updatedReleasedEntity: updatedReleasedEntity,
              reorderableEntity: givenReorderableEntity,
              scrollOffset: givenScrollOffset,
              child: givenChild,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(TextButton));
    }

    testWidgets(
        "GIVEN updated ReleasedReorderableEntity same "
        "WHEN pumping [ReorderableAnimatedReleasedContainer] "
        "THEN should show expected widgets", (WidgetTester tester) async {
      // given
      final givenReleasedEntity = reorderableBuilder.getReleasedEntity();

      // when
      await pumpWidgetAndUpdate(
        tester,
        releasedEntity: givenReleasedEntity,
        updatedReleasedEntity: givenReleasedEntity,
      );
      await tester.pumpAndSettle(givenReleasedChildDuration);

      // then
      expect(find.byWidget(givenChild), findsOneWidget);
      expect(
          find.byWidgetPredicate(
              (widget) => widget is Transform && widget.child == givenChild),
          findsNothing);
    });

    testWidgets(
        "GIVEN updated ReleasedReorderableEntity changed but is null "
        "WHEN pumping [ReorderableAnimatedReleasedContainer] "
        "THEN should show expected widgets", (WidgetTester tester) async {
      // given
      final givenReleasedEntity = reorderableBuilder.getReleasedEntity();

      // when
      await pumpWidgetAndUpdate(
        tester,
        releasedEntity: givenReleasedEntity,
        updatedReleasedEntity: null,
      );
      await tester.pumpAndSettle(givenReleasedChildDuration);

      // then
      expect(find.byWidget(givenChild), findsOneWidget);
      expect(
          find.byWidgetPredicate(
              (widget) => widget is Transform && widget.child == givenChild),
          findsNothing);
    });

    testWidgets(
        "GIVEN updated ReleasedReorderableEntity changed but key has changed "
        "WHEN pumping [ReorderableAnimatedReleasedContainer] "
        "THEN should show expected widgets", (WidgetTester tester) async {
      // given
      final givenReleasedEntity = reorderableBuilder.getReleasedEntity(
        dropOffset: const Offset(100.0, 200.0),
        reorderableEntity: givenReorderableEntity,
      );
      final givenUpdatedReleasedEntity = reorderableBuilder.getReleasedEntity(
        dropOffset: const Offset(111.0, 222.0),
        reorderableEntity: reorderableBuilder.getEntity(key: 'updated'),
      );

      // when
      await pumpWidgetAndUpdate(
        tester,
        releasedEntity: givenReleasedEntity,
        updatedReleasedEntity: givenUpdatedReleasedEntity,
      );
      await tester.pumpAndSettle(givenReleasedChildDuration);

      // then
      expect(find.byWidget(givenChild), findsOneWidget);
      expect(
          find.byWidgetPredicate(
              (widget) => widget is Transform && widget.child == givenChild),
          findsNothing);
    });

    testWidgets(
        "GIVEN updated ReleasedReorderableEntity changed "
        "WHEN pumping [ReorderableAnimatedReleasedContainer] "
        "THEN should show expected widgets", (WidgetTester tester) async {
      // given
      final givenReleasedEntity = reorderableBuilder.getReleasedEntity(
        dropOffset: const Offset(100.0, 200.0),
        reorderableEntity: givenReorderableEntity,
      );
      final givenUpdatedReleasedEntity = reorderableBuilder.getReleasedEntity(
        dropOffset: const Offset(111.0, 222.0),
        reorderableEntity: givenReorderableEntity,
      );

      // when
      await pumpWidgetAndUpdate(
        tester,
        releasedEntity: givenReleasedEntity,
        updatedReleasedEntity: givenUpdatedReleasedEntity,
      );
      await tester.pump();

      // then
      final expectedOffset = givenUpdatedReleasedEntity.dropOffset -
          givenReorderableEntity.updatedOffset +
          givenScrollOffset;
      expect(
          find.byWidgetPredicate((widget) =>
              widget is Transform &&
              widget.transform ==
                  Matrix4.translationValues(
                      expectedOffset.dx, expectedOffset.dy, 0.0) &&
              widget.child == givenChild),
          findsOneWidget);
    });
  });
}

class _TestUpdateReorderableAnimatedReleasedContainer extends StatefulWidget {
  final Widget child;
  final ReorderableEntity reorderableEntity;

  final Duration releasedChildDuration;
  final Offset scrollOffset;

  final ReleasedReorderableEntity releasedEntity;
  final ReleasedReorderableEntity? updatedReleasedEntity;

  const _TestUpdateReorderableAnimatedReleasedContainer({
    required this.child,
    required this.reorderableEntity,
    required this.releasedChildDuration,
    required this.scrollOffset,
    required this.releasedEntity,
    required this.updatedReleasedEntity,
    super.key,
  });

  @override
  State<_TestUpdateReorderableAnimatedReleasedContainer> createState() =>
      _TestUpdateReorderableAnimatedReleasedContainerState();
}

class _TestUpdateReorderableAnimatedReleasedContainerState
    extends State<_TestUpdateReorderableAnimatedReleasedContainer> {
  late ReleasedReorderableEntity? releasedEntity = widget.releasedEntity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextButton(
            onPressed: () {
              setState(() {
                releasedEntity = widget.updatedReleasedEntity;
              });
            },
            child: const Text('Update'),
          ),
          ReorderableAnimatedReleasedContainer(
            releasedChildDuration: widget.releasedChildDuration,
            releasedReorderableEntity: releasedEntity,
            reorderableEntity: widget.reorderableEntity,
            scrollOffset: widget.scrollOffset,
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
