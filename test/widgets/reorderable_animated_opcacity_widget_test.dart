import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_animated_opcacity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../reorderable_builder.dart';

void main() {
  final reorderableBuilder = ReorderableBuilder();
  const givenChild = SizedBox.square(
    dimension: 200.0,
    child: Placeholder(),
  );
  const givenFadeInDuration = Duration(milliseconds: 1000);

  Future<void> pumpWidget(
    WidgetTester tester, {
    required ReorderableEntity reorderableEntity,
    required VoidCallback onAnimationStarted,
  }) async =>
      tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableAnimatedOpacity(
              fadeInDuration: givenFadeInDuration,
              onAnimationStarted: onAnimationStarted,
              reorderableEntity: reorderableEntity,
              child: givenChild,
            ),
          ),
        ),
      );

  testWidgets(
      'GIVEN fadeInDuration and reorderableEntity is new '
      'WHEN pumping [ReorderableAnimatedOpacity] '
      'THEN should show expected AnimatedOpacity', (WidgetTester tester) async {
    // given
    final givenReorderableEntity = reorderableBuilder.getEntity(
      originalOrderId: -1,
    );
    int callCounter = 0;

    // when
    await pumpWidget(
      tester,
      reorderableEntity: givenReorderableEntity,
      onAnimationStarted: () {
        callCounter++;
      },
    );
    await tester.pump();
    await tester.pump(givenFadeInDuration);

    // then
    expect(
        find.byWidgetPredicate((widget) =>
            widget is FadeTransition &&
            widget.opacity.value == 1.0 &&
            widget.child == givenChild),
        findsOneWidget);
    expect(callCounter, equals(1));
  });

  testWidgets(
      'GIVEN reorderableEntity which is NOT new  '
      'WHEN pumping [ReorderableAnimatedOpacity] '
      'THEN should NOT call onAnimationStarted', (WidgetTester tester) async {
    // given
    final givenReorderableEntity = reorderableBuilder.getEntity(
      originalOrderId: 0,
    );
    int callCounter = 0;

    // when
    await pumpWidget(
      tester,
      reorderableEntity: givenReorderableEntity,
      onAnimationStarted: () {
        callCounter++;
      },
    );
    await tester.pumpAndSettle();

    // then
    expect(
        find.byWidgetPredicate((widget) =>
            widget is FadeTransition &&
            widget.opacity.value == 1.0 &&
            widget.child == givenChild),
        findsOneWidget);

    expect(callCounter, equals(0));
  });

  testWidgets(
      'GIVEN pumped [ReorderableAnimatedOpacity] '
      'WHEN reorderableEntity is updated but isNew = false '
      'THEN should call onOpacityFinished only one time (from initState)',
      (WidgetTester tester) async {
    // given
    final givenReorderableEntity = reorderableBuilder.getEntity(
      key: '0',
      originalOrderId: -1,
    );
    final givenUpdatedReorderableEntity = reorderableBuilder.getEntity(
      key: '1',
    );
    int callCounter = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: _TestUpdatedReorderableAnimatedOpacity(
          reorderableEntity: givenReorderableEntity,
          updatedReorderableEntity: givenUpdatedReorderableEntity,
          onAnimationStarted: () {
            callCounter++;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // when
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // then
    expect(callCounter, equals(1));
  });

  testWidgets(
      'GIVEN pumped [ReorderableAnimatedOpacity] '
      'WHEN reorderableEntity is updated and isNew = true '
      'THEN should call onOpacityFinished two times (from initState)',
      (WidgetTester tester) async {
    // given
    final givenReorderableEntity = reorderableBuilder.getEntity(
      key: '0',
      originalOrderId: -1,
    );
    final givenUpdatedReorderableEntity = reorderableBuilder.getEntity(
      key: '1',
      originalOrderId: -1,
    );
    int callCounter = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: _TestUpdatedReorderableAnimatedOpacity(
          reorderableEntity: givenReorderableEntity,
          updatedReorderableEntity: givenUpdatedReorderableEntity,
          onAnimationStarted: () {
            callCounter++;
          },
        ),
      ),
    );
    await tester.pump(givenFadeInDuration);

    // when
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    await tester.pump();

    // then
    expect(callCounter, equals(2));
  });
}

class _TestUpdatedReorderableAnimatedOpacity extends StatefulWidget {
  final ReorderableEntity reorderableEntity;
  final ReorderableEntity updatedReorderableEntity;
  final VoidCallback onAnimationStarted;

  const _TestUpdatedReorderableAnimatedOpacity({
    required this.reorderableEntity,
    required this.updatedReorderableEntity,
    required this.onAnimationStarted,
  });

  @override
  State<_TestUpdatedReorderableAnimatedOpacity> createState() =>
      _TestUpdatedReorderableAnimatedOpacityState();
}

class _TestUpdatedReorderableAnimatedOpacityState
    extends State<_TestUpdatedReorderableAnimatedOpacity> {
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
          ElevatedButton(
            onPressed: () {
              setState(() {
                reorderableEntity = widget.updatedReorderableEntity;
              });
            },
            child: const Text('press me'),
          ),
          ReorderableAnimatedOpacity(
            fadeInDuration: Duration.zero,
            onAnimationStarted: widget.onAnimationStarted,
            reorderableEntity: reorderableEntity,
            child: const Placeholder(),
          ),
        ],
      ),
    );
  }
}
