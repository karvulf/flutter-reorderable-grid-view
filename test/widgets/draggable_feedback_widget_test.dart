import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/utils/definitions.dart';
import 'package:flutter_reorderable_grid_view/widgets/draggable_feedback.dart';
import 'package:flutter_test/flutter_test.dart';

import '../reorderable_builder.dart';

void main() {
  final reorderableBuilder = ReorderableBuilder();

  final givenReorderableEntity = reorderableBuilder.getEntity();
  const givenChild = Placeholder();

  Future<void> pumpWidget(
    WidgetTester tester, {
    required ReorderableEntityCallback onDeactivate,
  }) async =>
      tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TestAnimatedDraggableFeedback(
              onDeactivate: onDeactivate,
              reorderableEntity: givenReorderableEntity,
              child: givenChild,
            ),
          ),
        ),
      );

  testWidgets(
      'GIVEN reorderableEntity and child '
      'WHEN pumping [_TestAnimatedDraggableFeedback] '
      'THEN should show expected widgets', (WidgetTester tester) async {
    // given

    // when
    await pumpWidget(
      tester,
      onDeactivate: (_) {},
    );

    // then
    expect(
        find.byWidgetPredicate((widget) =>
            widget is Material && widget.color == Colors.transparent),
        findsOneWidget);
    expect(
        find.byWidgetPredicate((widget) =>
            widget is SizedBox &&
            widget.height == givenReorderableEntity.size.height &&
            widget.width == givenReorderableEntity.size.width),
        findsOneWidget);
    expect(
        find.byWidgetPredicate((widget) =>
            widget is DecoratedBoxTransition &&
            widget.position == DecorationPosition.background &&
            widget.child == givenChild),
        findsOneWidget);
  });

  testWidgets(
      'GIVEN pumped [_TestAnimatedDraggableFeedback] '
      'WHEN widget is disposed '
      'THEN should call onDeactivate', (WidgetTester tester) async {
    // given
    ReorderableEntity? actualReorderableEntity;

    // when
    await pumpWidget(
      tester,
      onDeactivate: (reorderableEntity) {
        actualReorderableEntity = reorderableEntity;
      },
    );

    // then
    addTearDown(() {
      expect(actualReorderableEntity, equals(givenReorderableEntity));
    });
  });
}

class _TestAnimatedDraggableFeedback extends StatefulWidget {
  final Widget child;
  final ReorderableEntity reorderableEntity;
  final ReorderableEntityCallback onDeactivate;

  const _TestAnimatedDraggableFeedback({
    required this.child,
    required this.reorderableEntity,
    required this.onDeactivate,
    Key? key,
  }) : super(key: key);

  @override
  State<_TestAnimatedDraggableFeedback> createState() =>
      _TestAnimatedDraggableFeedbackState();
}

class _TestAnimatedDraggableFeedbackState
    extends State<_TestAnimatedDraggableFeedback>
    with TickerProviderStateMixin {
  late final AnimationController _decoratedBoxAnimationController;
  late final DecorationTween _decorationTween;

  @override
  void initState() {
    super.initState();

    _decoratedBoxAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _decorationTween = DecorationTween(
      begin: const BoxDecoration(),
      end: const BoxDecoration(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableFeedback(
      onDeactivate: widget.onDeactivate,
      reorderableEntity: widget.reorderableEntity,
      decoration: _decorationTween.animate(
        _decoratedBoxAnimationController,
      ),
      child: widget.child,
    );
  }
}
