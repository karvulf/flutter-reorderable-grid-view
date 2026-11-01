import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/item/reorderable_init_child.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../reorderable_builder.dart';

void main() {
  final reorderableBuilder = ReorderableBuilder();

  const givenChild = Text('child');

  Future<void> pumpWidget(
    WidgetTester tester, {
    required ReorderableEntity reorderableEntity,
    void Function(GlobalKey key)? onCreated,
  }) async =>
      tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableInitChild(
              reorderableEntity: reorderableEntity,
              onCreated: onCreated ?? (_) {},
              child: givenChild,
            ),
          ),
        ),
      );

  testWidgets(
      "GIVEN reorderableEntity with isBuildingOffset = true "
      "WHEN pumping [ReorderableInitChild] "
      "THEN should show expected widgets", (WidgetTester tester) async {
    // given
    final givenReorderableEntity = reorderableBuilder.getEntity(
      isBuildingOffset: true,
    );
    GlobalKey? actualGlobalKey;

    // when
    await pumpWidget(
      tester,
      reorderableEntity: givenReorderableEntity,
      onCreated: (globalKey) {
        actualGlobalKey = globalKey;
      },
    );

    // then
    expect(actualGlobalKey, isNotNull);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is SizedBox &&
            widget.key is GlobalKey &&
            widget.child == givenChild,
      ),
      findsOneWidget,
    );
  });

  group('#didUpdateWidget', () {
    Future<void> pumpWidgetAndUpdate(
      WidgetTester tester, {
      required ReorderableEntity reorderableEntity,
      required ReorderableEntity updatedReorderableEntity,
      required void Function(GlobalKey key) onCreated,
    }) async {
      await pumpWidget(
        tester,
        reorderableEntity: reorderableEntity,
        onCreated: onCreated,
      );
      await tester.pumpAndSettle();

      await pumpWidget(
        tester,
        reorderableEntity: updatedReorderableEntity,
        onCreated: onCreated,
      );
      await tester.pumpAndSettle();
    }

    testWidgets(
        "GIVEN [ReorderableInitChild] "
        "WHEN updating unchanged ReorderableEntity "
        "THEN should call onCreated one time", (WidgetTester tester) async {
      // given
      final givenReorderableEntity = reorderableBuilder.getEntity(
        isBuildingOffset: false,
      );
      final givenUpdatedReorderableEntity = reorderableBuilder.getEntity(
        isBuildingOffset: false,
      );
      var callCounter = 0;

      // when
      await pumpWidgetAndUpdate(
        tester,
        reorderableEntity: givenReorderableEntity,
        updatedReorderableEntity: givenUpdatedReorderableEntity,
        onCreated: (_) {
          callCounter++;
        },
      );

      // then
      expect(callCounter, equals(1));
    });

    testWidgets(
        "GIVEN [ReorderableInitChild] "
        "WHEN updating ReorderableEntity with isBuildingOffset = false "
        "THEN should call onCreated one time", (WidgetTester tester) async {
      // given
      final givenReorderableEntity = reorderableBuilder.getEntity(
        isBuildingOffset: true,
      );
      final givenUpdatedReorderableEntity = reorderableBuilder.getEntity(
        isBuildingOffset: false,
      );
      var callCounter = 0;

      // when
      await pumpWidgetAndUpdate(
        tester,
        reorderableEntity: givenReorderableEntity,
        updatedReorderableEntity: givenUpdatedReorderableEntity,
        onCreated: (_) {
          callCounter++;
        },
      );

      // then
      expect(callCounter, equals(1));
    });

    testWidgets(
        "GIVEN [ReorderableInitChild] "
        "WHEN updating ReorderableEntity with isBuildingOffset = true "
        "THEN should call onCreated two times", (WidgetTester tester) async {
      // given
      final givenReorderableEntity = reorderableBuilder.getEntity(
        isBuildingOffset: false,
      );
      final givenUpdatedReorderableEntity = reorderableBuilder.getEntity(
        isBuildingOffset: true,
      );
      var callCounter = 0;

      // when
      await pumpWidgetAndUpdate(
        tester,
        reorderableEntity: givenReorderableEntity,
        updatedReorderableEntity: givenUpdatedReorderableEntity,
        onCreated: (_) {
          callCounter++;
        },
      );

      // then
      expect(callCounter, equals(2));
    });

    testWidgets(
        "GIVEN [ReorderableInitChild] with isBuildingOffset = true and "
        "updated entity with isBuildOffset = true and another updatedOrderId"
        "WHEN updating entity "
        "THEN should call onCreated two times", (WidgetTester tester) async {
      // given
      final givenReorderableEntity = reorderableBuilder.getEntity(
        updatedOrderId: 1,
        isBuildingOffset: true,
      );
      final givenUpdatedReorderableEntity = reorderableBuilder.getEntity(
        updatedOrderId: 2,
        isBuildingOffset: true,
      );
      var callCounter = 0;

      // when
      await pumpWidgetAndUpdate(
        tester,
        reorderableEntity: givenReorderableEntity,
        updatedReorderableEntity: givenUpdatedReorderableEntity,
        onCreated: (_) {
          callCounter++;
        },
      );

      // then
      expect(callCounter, equals(2));
    });

    testWidgets(
        "GIVEN [ReorderableInitChild] with isBuildingOffset = true and "
        "updated entity with isBuildingOffset = true and "
        "the same updatedOrderId "
        "WHEN updating ReorderableEntity "
        "THEN should call onCreated one time", (WidgetTester tester) async {
      // given
      final givenReorderableEntity = reorderableBuilder.getEntity(
        updatedOrderId: 1,
        isBuildingOffset: true,
      );
      final givenUpdatedReorderableEntity = reorderableBuilder.getEntity(
        updatedOrderId: 1,
        updatedOffset: const Offset(50.0, 51.0),
        isBuildingOffset: true,
      );
      var callCounter = 0;

      // when
      await pumpWidgetAndUpdate(
        tester,
        reorderableEntity: givenReorderableEntity,
        updatedReorderableEntity: givenUpdatedReorderableEntity,
        onCreated: (_) {
          callCounter++;
        },
      );

      // then
      expect(callCounter, equals(1));
    });
  });
}
