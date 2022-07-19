import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/animated/reorderable_animated_update_container.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const givenChild = Text('hallo');

  Future<void> pumpWidget(
    WidgetTester tester, {
    required ReorderableEntity reorderableEntity,
    required OnMovingFinishedCallback onMovingFinished,
    required bool isDragging,
  }) =>
      tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableAnimatedUpdatedContainer(
              reorderableEntity: reorderableEntity,
              isDragging: isDragging,
              onMovingFinished: onMovingFinished,
              child: givenChild,
            ),
          ),
        ),
      );

  testWidgets(
      'GIVEN isDragging = true, isBuilding = false and default reorderableEntity '
      'WHEN pumping [ReorderableAnimatedUpdatedContainer] '
      'THEN should show expected widgets and not call onMovingFinished',
      (WidgetTester tester) async {
    // given
    ReorderableEntity? actualReorderableEntity;
    GlobalKey? actualGlobalKey;
    const givenReorderableEntity = ReorderableEntity(
      child: givenChild,
      originalOrderId: 0,
      updatedOrderId: 0,
      isBuilding: false,
    );

    // when
    await pumpWidget(
      tester,
      reorderableEntity: givenReorderableEntity,
      onMovingFinished: (reorderableEntity, globalKey) {
        actualReorderableEntity = reorderableEntity;
        actualGlobalKey = globalKey;
      },
      isDragging: true,
    );

    // then
    expect(
        find.byWidgetPredicate(
            (widget) => widget is Visibility && widget.visible),
        findsOneWidget);
    expect(
        find.byWidgetPredicate((widget) =>
            widget is Container &&
            widget.transform == Matrix4.translationValues(0.0, 0.0, 0.0)),
        findsOneWidget);
    expect(find.byWidget(givenChild), findsOneWidget);
    expect(actualGlobalKey, isNull);
    expect(actualReorderableEntity, isNull);
  });

  testWidgets(
      'GIVEN isDragging = false, isBuilding = true, default reorderableEntity and [ReorderableAnimatedUpdatedContainer]'
      'WHEN updating reorderableEntity with different offsets '
      'THEN should not show widget and should call onMovingFinished',
      (WidgetTester tester) async {
    // given
    ReorderableEntity? actualReorderableEntity;
    GlobalKey? actualGlobalKey;
    const givenReorderableEntity = ReorderableEntity(
      child: givenChild,
      originalOrderId: 0,
      updatedOrderId: 0,
      isBuilding: true,
    );
    final givenUpdatedReorderableEntity = givenReorderableEntity.copyWith(
      updatedOffset: const Offset(100, 100),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: _UpdateReorderableEntityTest(
          isDragging: false,
          onMovingFinished: (reorderableEntity, globalKey) {
            actualReorderableEntity = reorderableEntity;
            actualGlobalKey = globalKey;
          },
          updatedReorderableEntity: givenUpdatedReorderableEntity,
          reorderableEntity: givenReorderableEntity,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // when
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    // then
    expect(
        find.byWidgetPredicate(
            (widget) => widget is Visibility && widget.visible),
        findsOneWidget);
    expect(actualGlobalKey, isNotNull);
    expect(actualReorderableEntity, equals(givenUpdatedReorderableEntity));
  });

  testWidgets(
      'GIVEN hasSwappedOrder = true, default reorderableEntity and [ReorderableAnimatedUpdatedContainer]'
      'WHEN updating reorderableEntity with different offsets '
      'THEN should call onMovingFinished', (WidgetTester tester) async {
    // given
    ReorderableEntity? actualReorderableEntity;
    GlobalKey? actualGlobalKey;
    const givenReorderableEntity = ReorderableEntity(
      child: givenChild,
      originalOrderId: 0,
      updatedOrderId: 0,
      isBuilding: false,
      hasSwappedOrder: true,
    );
    final givenUpdatedReorderableEntity = givenReorderableEntity.copyWith(
      updatedOffset: const Offset(100, 100),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: _UpdateReorderableEntityTest(
          isDragging: false,
          onMovingFinished: (reorderableEntity, globalKey) {
            actualReorderableEntity = reorderableEntity;
            actualGlobalKey = globalKey;
          },
          updatedReorderableEntity: givenUpdatedReorderableEntity,
          reorderableEntity: givenReorderableEntity,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // when
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    // then
    expect(actualGlobalKey, isNotNull);
    expect(actualReorderableEntity, equals(givenUpdatedReorderableEntity));
  });
}

class _UpdateReorderableEntityTest extends StatefulWidget {
  final ReorderableEntity reorderableEntity;
  final ReorderableEntity updatedReorderableEntity;
  final OnMovingFinishedCallback onMovingFinished;
  final bool isDragging;

  const _UpdateReorderableEntityTest({
    required this.reorderableEntity,
    required this.updatedReorderableEntity,
    required this.onMovingFinished,
    required this.isDragging,
    Key? key,
  }) : super(key: key);

  @override
  _UpdateReorderableEntityTestState createState() =>
      _UpdateReorderableEntityTestState();
}

class _UpdateReorderableEntityTestState
    extends State<_UpdateReorderableEntityTest> {
  late ReorderableEntity reorderableEntity;

  @override
  void initState() {
    super.initState();

    reorderableEntity = widget.reorderableEntity;
  }

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
            child: const Text('update'),
          ),
          ReorderableAnimatedUpdatedContainer(
            reorderableEntity: reorderableEntity,
            isDragging: widget.isDragging,
            onMovingFinished: widget.onMovingFinished,
            child: reorderableEntity.child,
          ),
        ],
      ),
    );
  }
}
