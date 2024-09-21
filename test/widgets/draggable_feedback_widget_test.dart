import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/draggable_feedback.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const givenSize = Size(100.0, 200.5);
  const givenChild = Placeholder();
  const givenFeedbackScaleFactor = 1.5;

  Future<void> pumpWidget(
    WidgetTester tester, {
    required VoidCallback onDeactivate,
  }) async =>
      tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TestAnimatedDraggableFeedback(
              onDeactivate: onDeactivate,
              size: givenSize,
              feedbackScaleFactor: givenFeedbackScaleFactor,
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
      onDeactivate: () {},
    );

    // then
    expect(
        find.byWidgetPredicate((widget) =>
            widget is Material && widget.color == Colors.transparent),
        findsOneWidget);
    expect(
        find.byWidgetPredicate((widget) =>
            widget is Container &&
            widget.constraints == BoxConstraints.tight(givenSize) &&
            widget.transform == Matrix4.translationValues(0.0, 0.0, 0.0)),
        findsOneWidget);
    expect(
        find.byWidgetPredicate((widget) =>
            widget is DecoratedBoxTransition &&
            widget.position == DecorationPosition.background &&
            widget.child == givenChild),
        findsOneWidget);
  });

  testWidgets(
      'GIVEN [_TestAnimatedDraggableFeedback] '
      'WHEN waiting until animation of size was done  '
      'THEN should update offset and size of widget',
      (WidgetTester tester) async {
    // given
    await pumpWidget(
      tester,
      onDeactivate: () {},
    );

    // when
    await tester.pumpAndSettle();

    // then
    final expectedOffsetToCenterFeedback = Offset(
      -((givenSize.width * 1.5) - givenSize.width) / 2,
      -((givenSize.height * 1.5) - givenSize.height) / 2,
    );
    expect(
        find.byWidgetPredicate((widget) =>
            widget is Container &&
            widget.constraints == BoxConstraints.tight(givenSize * 1.5) &&
            widget.transform ==
                Matrix4.translationValues(
                  expectedOffsetToCenterFeedback.dx,
                  expectedOffsetToCenterFeedback.dy,
                  0.0,
                )),
        findsOneWidget);
  });

  testWidgets(
      'GIVEN pumped [_TestAnimatedDraggableFeedback] '
      'WHEN widget is disposed '
      'THEN should call onDeactivate', (WidgetTester tester) async {
    // given
    int callCounter = 0;

    // when
    await pumpWidget(
      tester,
      onDeactivate: () {
        callCounter++;
      },
    );

    // then
    addTearDown(() {
      expect(callCounter, equals(1));
    });
  });
}

class _TestAnimatedDraggableFeedback extends StatefulWidget {
  final Widget child;
  final Size size;
  final double feedbackScaleFactor;
  final VoidCallback onDeactivate;

  const _TestAnimatedDraggableFeedback({
    required this.child,
    required this.size,
    required this.feedbackScaleFactor,
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
      size: widget.size,
      feedbackScaleFactor: widget.feedbackScaleFactor,
      decoration: _decorationTween.animate(
        _decoratedBoxAnimationController,
      ),
      child: widget.child,
    );
  }
}
