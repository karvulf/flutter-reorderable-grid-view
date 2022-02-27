import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/animated/reorderable_animated_opacity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const givenChild = Text('hallo');

  Future<void> pumpWidget(
    WidgetTester tester, {
    required ReorderableEntity reorderableEntity,
    required OnOpacityFinishedCallback onOpacityFinished,
  }) =>
      tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableAnimatedOpacity(
              reorderableEntity: reorderableEntity,
              child: givenChild,
              onOpacityFinished: onOpacityFinished,
            ),
          ),
        ),
      );

  testWidgets(
      'GIVEN reorderableEntity with isNew = false '
      'WHEN pumping [ReorderableAnimatedOpacity] '
      'THEN should show expected widget with expected values and '
      'should not call onOpacityFinished', (WidgetTester tester) async {
    // given
    int? actualKeyHashCode;
    const givenReorderableEntity = ReorderableEntity(
      child: givenChild,
      originalOrderId: 0,
      updatedOrderId: 0,
      isBuilding: false,
      isNew: false,
    );

    // when
    await pumpWidget(
      tester,
      reorderableEntity: givenReorderableEntity,
      onOpacityFinished: (keyHashCode) {
        actualKeyHashCode = keyHashCode;
      },
    );
    await tester.pumpAndSettle();

    // then
    expect(
        find.byWidgetPredicate(
            (widget) => widget is Opacity && widget.opacity == 1.0),
        findsOneWidget);
    expect(actualKeyHashCode, isNull);
  });

  testWidgets(
      'GIVEN reorderableEntity with isNew = true '
      'WHEN pumping [ReorderableAnimatedOpacity] '
      'THEN should show expected widget with expected values and call onOpacityFinished',
      (WidgetTester tester) async {
    // given
    int? actualKeyHashCode;
    const givenReorderableEntity = ReorderableEntity(
      child: givenChild,
      originalOrderId: 0,
      updatedOrderId: 0,
      isBuilding: false,
      isNew: true,
    );

    // when
    await pumpWidget(
      tester,
      reorderableEntity: givenReorderableEntity,
      onOpacityFinished: (keyHashCode) {
        actualKeyHashCode = keyHashCode;
      },
    );
    await tester.pumpAndSettle();

    // then
    expect(
        find.byWidgetPredicate(
            (widget) => widget is Opacity && widget.opacity == 1.0),
        findsOneWidget);
    expect(actualKeyHashCode, equals(givenChild.key.hashCode));
  });

  testWidgets(
      'GIVEN [ReorderableAnimatedOpacity] '
      'WHEN updating given reorderableEntity isNew from false to true '
      'THEN should call onOpacityFinished', (WidgetTester tester) async {
    // given
    int? actualKeyHashCode;
    const givenReorderableEntity = ReorderableEntity(
      child: givenChild,
      originalOrderId: 0,
      updatedOrderId: 0,
      isBuilding: false,
      isNew: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: _UpdateReorderableEntityTest(
          reorderableEntity: givenReorderableEntity,
          onOpacityFinished: (keyHashCode) {
            actualKeyHashCode = keyHashCode;
          },
          updatedReorderableEntity: givenReorderableEntity.copyWith(
            isNew: true,
          ),
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
            (widget) => widget is Opacity && widget.opacity == 1.0),
        findsOneWidget);
    expect(actualKeyHashCode, equals(givenChild.key.hashCode));
  });
}

class _UpdateReorderableEntityTest extends StatefulWidget {
  final ReorderableEntity reorderableEntity;
  final ReorderableEntity updatedReorderableEntity;
  final OnOpacityFinishedCallback onOpacityFinished;

  const _UpdateReorderableEntityTest({
    required this.reorderableEntity,
    required this.updatedReorderableEntity,
    required this.onOpacityFinished,
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
          ReorderableAnimatedOpacity(
            reorderableEntity: reorderableEntity,
            child: const Text('hello'),
            onOpacityFinished: widget.onOpacityFinished,
          ),
        ],
      ),
    );
  }
}
