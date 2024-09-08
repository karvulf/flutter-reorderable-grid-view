import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_init_child.dart';
import 'package:flutter_test/flutter_test.dart';

import '../reorderable_builder.dart';

// ignore_for_file: unused_element

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
        find.byWidgetPredicate((widget) =>
            widget is Visibility &&
            widget.key != null &&
            !widget.visible &&
            widget.maintainAnimation &&
            widget.maintainSize &&
            widget.maintainState &&
            widget.child == givenChild),
        findsOneWidget);
  });

  testWidgets(
      "GIVEN reorderableEntity with isBuildingOffset = false "
      "WHEN pumping [ReorderableInitChild] "
      "THEN should show expected widgets", (WidgetTester tester) async {
    // given
    final givenReorderableEntity = reorderableBuilder.getEntity(
      isBuildingOffset: false,
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
    await tester.pump();

    // then
    expect(actualGlobalKey, isNotNull);
    expect(
        find.byWidgetPredicate((widget) =>
            widget is Visibility &&
            widget.key != null &&
            widget.visible &&
            widget.maintainAnimation &&
            widget.maintainSize &&
            widget.maintainState &&
            widget.child == givenChild),
        findsOneWidget);
  });

  group('#didUpdateWidget', () {
    Future<void> pumpWidgetAndUpdate(
      WidgetTester tester, {
      required ReorderableEntity reorderableEntity,
      required ReorderableEntity updatedReorderableEntity,
      required void Function(GlobalKey key) onCreated,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TestUpdateReorderableInitChild(
              reorderableEntity: reorderableEntity,
              updatedReorderableEntity: updatedReorderableEntity,
              onCreated: onCreated,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TextButton));
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
  });
}

class _TestUpdateReorderableInitChild extends StatefulWidget {
  final ReorderableEntity reorderableEntity;
  final ReorderableEntity updatedReorderableEntity;

  final void Function(GlobalKey key) onCreated;

  const _TestUpdateReorderableInitChild({
    required this.reorderableEntity,
    required this.updatedReorderableEntity,
    required this.onCreated,
    super.key,
  });

  @override
  State<_TestUpdateReorderableInitChild> createState() =>
      _TestUpdateReorderableInitChildState();
}

class _TestUpdateReorderableInitChildState
    extends State<_TestUpdateReorderableInitChild> {
  late ReorderableEntity reorderableEntity = widget.reorderableEntity;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () {
            setState(() {
              reorderableEntity = widget.updatedReorderableEntity;
            });
          },
          child: const Text('update'),
        ),
        ReorderableInitChild(
          reorderableEntity: reorderableEntity,
          onCreated: widget.onCreated,
          child: const Placeholder(),
        ),
      ],
    );
  }
}
