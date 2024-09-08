import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_animated_opcacity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../reorderable_builder.dart';

void main() {
  final reorderableBuilder = ReorderableBuilder();
  const givenDimension = 200.0;
  const givenChild = SizedBox.square(
    dimension: givenDimension,
    child: Placeholder(),
  );
  const givenFadeInDuration = Duration(milliseconds: 200);

  Future<void> pumpWidget(
    WidgetTester tester, {
    required ReorderableEntity reorderableEntity,
    required void Function(Size? size) onOpacityFinished,
  }) async =>
      tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableAnimatedOpacity(
              fadeInDuration: givenFadeInDuration,
              onOpacityFinished: onOpacityFinished,
              reorderableEntity: reorderableEntity,
              child: givenChild,
            ),
          ),
        ),
      );

  testWidgets(
      'GIVEN fadeInDuration and reorderableEntity which is new '
      'WHEN pumping [ReorderableAnimatedOpacity] '
      'THEN should show expected AnimatedOpacity', (WidgetTester tester) async {
    // given
    final givenReorderableEntity = reorderableBuilder.getEntity(
      originalOrderId: -1,
    );

    // when
    await pumpWidget(
      tester,
      reorderableEntity: givenReorderableEntity,
      onOpacityFinished: (_) {},
    );

    // then
    expect(
        find.byWidgetPredicate((widget) =>
            widget is AnimatedOpacity &&
            widget.key is GlobalKey &&
            widget.opacity == 0.0 &&
            widget.duration == givenFadeInDuration &&
            widget.child == givenChild),
        findsOneWidget);
  });

  testWidgets(
      'GIVEN reorderableEntity which is NOT new and pumped [ReorderableAnimatedOpacity] '
      'WHEN animation ends '
      'THEN should call onOpacityFinished with expected size',
      (WidgetTester tester) async {
    // given
    final givenReorderableEntity = reorderableBuilder.getEntity(
      originalOrderId: 0,
    );
    Size? actualSize;

    // when
    await pumpWidget(
      tester,
      reorderableEntity: givenReorderableEntity,
      onOpacityFinished: (size) {
        actualSize = size;
      },
    );
    await tester.pumpAndSettle();

    // then
    expect(
        find.byWidgetPredicate(
            (widget) => widget is AnimatedOpacity && widget.opacity == 1.0),
        findsOneWidget);

    expect(actualSize, equals(const Size.square(givenDimension)));
  });

  testWidgets(
      'GIVEN pumped [ReorderableAnimatedOpacity] '
      'WHEN reorderableEntity is updated but isNew = false '
      'THEN should call onOpacityFinished only one time (from initState)',
      (WidgetTester tester) async {
    // given
    final givenReorderableEntity = reorderableBuilder.getEntity();
    final givenUpdatedReorderableEntity = reorderableBuilder.getEntity(
      originalOrderId: 123,
    );
    int callCounter = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: _TestUpdatedReorderableAnimatedOpacity(
          reorderableEntity: givenReorderableEntity,
          updatedReorderableEntity: givenUpdatedReorderableEntity,
          onOpacityFinished: (_) {
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
      originalOrderId: 0,
    );
    final givenUpdatedReorderableEntity = reorderableBuilder.getEntity(
      originalOrderId: -1,
    );
    int callCounter = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: _TestUpdatedReorderableAnimatedOpacity(
          reorderableEntity: givenReorderableEntity,
          updatedReorderableEntity: givenUpdatedReorderableEntity,
          onOpacityFinished: (_) {
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
    expect(callCounter, equals(2));
  });
}

class _TestUpdatedReorderableAnimatedOpacity extends StatefulWidget {
  final ReorderableEntity reorderableEntity;
  final ReorderableEntity updatedReorderableEntity;
  final void Function(Size? size) onOpacityFinished;

  const _TestUpdatedReorderableAnimatedOpacity({
    required this.reorderableEntity,
    required this.updatedReorderableEntity,
    required this.onOpacityFinished,
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
            onOpacityFinished: widget.onOpacityFinished,
            reorderableEntity: reorderableEntity,
            child: const Placeholder(),
          ),
        ],
      ),
    );
  }
}
