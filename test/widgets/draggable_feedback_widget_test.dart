import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_animation_config.dart';
import 'package:flutter_reorderable_grid_view/widgets/drag_feedback_transition.dart';
import 'package:flutter_reorderable_grid_view/widgets/draggable_feedback.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const givenSize = Size(100.0, 200.5);
  const givenChild = Placeholder();
  const givenFeedbackScaleFactor = 1.5;
  const givenDuration = Duration(milliseconds: 250);
  const givenDecoration = AlwaysStoppedAnimation<Decoration>(BoxDecoration());

  Future<void> pumpWidget(
    WidgetTester tester, {
    ReorderableAnimationConfig animationConfig =
        const ReorderableAnimationConfig(
      dragFeedback: ReorderableItemTransition(
        duration: givenDuration,
        curve: Curves.easeIn,
      ),
    ),
    VoidCallback? onDeactivate,
  }) =>
      tester.pumpWidget(
        MaterialApp(
          home: DraggableFeedback(
            size: givenSize,
            decoration: givenDecoration,
            feedbackScaleFactor: givenFeedbackScaleFactor,
            animationConfig: animationConfig,
            onDeactivate: onDeactivate ?? () {},
            child: givenChild,
          ),
        ),
      );

  Animation<double> getAnimation(WidgetTester tester) => tester
      .widget<DragFeedbackTransition>(find.byType(DragFeedbackTransition))
      .animation;

  testWidgets(
      'GIVEN size, decoration, feedbackScaleFactor and child '
      'WHEN pumping [DraggableFeedback] '
      'THEN should show expected widgets', (WidgetTester tester) async {
    // given

    // when
    await pumpWidget(tester);

    // then
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Material && widget.color == Colors.transparent,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is SizedBox &&
            widget.width == givenSize.width &&
            widget.height == givenSize.height,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is DragFeedbackTransition &&
            widget.feedbackScaleFactor == givenFeedbackScaleFactor &&
            widget.animation is CurvedAnimation &&
            (widget.animation as CurvedAnimation).curve == Curves.easeIn,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is DecoratedBoxTransition &&
            widget.position == DecorationPosition.background &&
            widget.decoration == givenDecoration &&
            widget.child == givenChild,
      ),
      findsOneWidget,
    );
  });

  testWidgets(
      'GIVEN dragFeedback without curve '
      'WHEN pumping [DraggableFeedback] '
      'THEN should use animation without curve', (WidgetTester tester) async {
    // given
    const animationConfig = ReorderableAnimationConfig(
      dragFeedback: ReorderableItemTransition(duration: givenDuration),
    );

    // when
    await pumpWidget(tester, animationConfig: animationConfig);

    // then
    expect(getAnimation(tester), isA<AnimationController>());
  });

  testWidgets(
      'GIVEN pumped [DraggableFeedback] '
      'WHEN removing [DraggableFeedback] '
      'THEN should call onDeactivate', (WidgetTester tester) async {
    // given
    var callCounter = 0;
    await pumpWidget(tester, onDeactivate: () => callCounter++);

    // when
    await tester.pumpWidget(const SizedBox());

    // then
    expect(callCounter, equals(1));
  });
}
