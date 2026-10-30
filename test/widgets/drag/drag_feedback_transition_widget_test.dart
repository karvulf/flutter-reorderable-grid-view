import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_animation_config.dart';
import 'package:flutter_reorderable_grid_view/widgets/drag/drag_feedback_transition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const givenChild = Placeholder();
  const givenAnimation = AlwaysStoppedAnimation<double>(1.0);

  Future<void> pumpWidget(
    WidgetTester tester, {
    ReorderableAnimationConfig animationConfig =
        const ReorderableAnimationConfig(),
    double? feedbackScaleFactor,
  }) =>
      tester.pumpWidget(
        MaterialApp(
          home: DragFeedbackTransition(
            animationConfig: animationConfig,
            feedbackScaleFactor: feedbackScaleFactor,
            animation: givenAnimation,
            child: givenChild,
          ),
        ),
      );

  testWidgets(
      'GIVEN dragFeedback with builder '
      'WHEN pumping [DragFeedbackTransition] '
      'THEN should show child built by builder', (WidgetTester tester) async {
    // given
    final animationConfig = ReorderableAnimationConfig(
      dragFeedback: ReorderableItemTransition(
        duration: const Duration(milliseconds: 100),
        builder: (child, animation) => RotationTransition(
          turns: animation,
          child: child,
        ),
      ),
    );

    // when
    await pumpWidget(
      tester,
      animationConfig: animationConfig,
      feedbackScaleFactor: 2.0,
    );

    // then
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RotationTransition &&
            widget.turns == givenAnimation &&
            widget.child == givenChild,
      ),
      findsOneWidget,
    );
    expect(find.byType(ScaleTransition), findsNothing);
  });

  testWidgets(
      'GIVEN no builder and feedbackScaleFactor = 2.0 '
      'WHEN pumping [DragFeedbackTransition] '
      'THEN should scale child to feedbackScaleFactor',
      (WidgetTester tester) async {
    // given

    // when
    await pumpWidget(tester, feedbackScaleFactor: 2.0);

    // then
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is ScaleTransition &&
            widget.scale.value == 2.0 &&
            widget.child == givenChild,
      ),
      findsOneWidget,
    );
  });

  testWidgets(
      'GIVEN no builder and no feedbackScaleFactor '
      'WHEN pumping [DragFeedbackTransition] '
      'THEN should scale child to 1.05', (WidgetTester tester) async {
    // given

    // when
    await pumpWidget(tester);

    // then
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is ScaleTransition &&
            widget.scale.value == 1.05 &&
            widget.child == givenChild,
      ),
      findsOneWidget,
    );
  });
}
