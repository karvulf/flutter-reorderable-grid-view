import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/removed_reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_animation_config.dart';
import 'package:flutter_reorderable_grid_view/widgets/removed/reorderable_animated_removed_child.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const givenChild = Placeholder();
  const givenRemoveDuration = Duration(milliseconds: 200);
  const givenRemovedEntity = RemovedReorderableEntity(
    key: ValueKey('removed'),
    child: givenChild,
    offset: Offset(20.0, 40.0),
    size: Size(100.0, 50.0),
  );

  Future<void> pumpWidget(
    WidgetTester tester, {
    ScrollController? scrollController,
    ValueGetter<Offset>? getScrollOffset,
    VoidCallback? onFinished,
    ReorderableAnimationConfig animationConfig =
        const ReorderableAnimationConfig(
      remove: ReorderableItemTransition(duration: givenRemoveDuration),
    ),
  }) async =>
      tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                if (scrollController != null)
                  SingleChildScrollView(
                    controller: scrollController,
                    child: const SizedBox(height: 2000.0),
                  ),
                ReorderableAnimatedRemovedChild(
                  removedEntity: givenRemovedEntity,
                  animationConfig: animationConfig,
                  scrollController: scrollController,
                  getScrollOffset: getScrollOffset ?? () => Offset.zero,
                  onFinished: onFinished ?? () {},
                ),
              ],
            ),
          ),
        ),
      );

  double getOpacity(WidgetTester tester) => tester
      .widget<FadeTransition>(
        find.byWidgetPredicate(
          (widget) => widget is FadeTransition && widget.child == givenChild,
        ),
      )
      .opacity
      .value;

  testWidgets(
      'GIVEN removedEntity and scroll offset '
      'WHEN pumping [ReorderableAnimatedRemovedChild] '
      'THEN should show expected widgets', (tester) async {
    // given
    const givenScrollOffset = Offset(0.0, 10.0);

    // when
    await pumpWidget(tester, getScrollOffset: () => givenScrollOffset);

    // then
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Positioned &&
            widget.left == 20.0 &&
            widget.top == 30.0 &&
            widget.width == 100.0 &&
            widget.height == 50.0 &&
            widget.child is IgnorePointer,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) => widget is FadeTransition && widget.child == givenChild,
      ),
      findsOneWidget,
    );
    expect(getOpacity(tester), equals(1.0));
  });

  testWidgets(
      'GIVEN remove with builder and curve '
      'WHEN pumping [ReorderableAnimatedRemovedChild] '
      'THEN should show child built by builder with reversed curved animation',
      (tester) async {
    // given
    final animationConfig = ReorderableAnimationConfig(
      remove: ReorderableItemTransition(
        duration: givenRemoveDuration,
        curve: Curves.easeIn,
        builder: (child, animation) => ScaleTransition(
          scale: animation,
          child: child,
        ),
      ),
    );

    // when
    await pumpWidget(tester, animationConfig: animationConfig);

    // then
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is ScaleTransition &&
            widget.scale.value == 1.0 &&
            widget.scale is ReverseAnimation &&
            (widget.scale as ReverseAnimation).parent is CurvedAnimation &&
            ((widget.scale as ReverseAnimation).parent as CurvedAnimation)
                    .curve ==
                Curves.easeIn &&
            widget.child == givenChild,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) => widget is FadeTransition && widget.child == givenChild,
      ),
      findsNothing,
    );
  });

  testWidgets(
      'GIVEN [ReorderableAnimatedRemovedChild] '
      'WHEN animating out '
      'THEN should call onFinished only after the animation', (tester) async {
    // given
    int callCounter = 0;
    await pumpWidget(tester, onFinished: () => callCounter++);

    // when
    await tester.pumpAndSettle();

    // then
    expect(getOpacity(tester), equals(0.0));
    expect(callCounter, equals(1));
  });

  testWidgets(
      'GIVEN [ReorderableAnimatedRemovedChild] with scrollController '
      'WHEN scrolling '
      'THEN should move the removed child with the scroll offset',
      (tester) async {
    // given
    final givenScrollController = ScrollController();
    await pumpWidget(
      tester,
      scrollController: givenScrollController,
      getScrollOffset: () => Offset(0.0, givenScrollController.offset),
    );

    // when
    givenScrollController.jumpTo(15.0);
    await tester.pump();

    // then
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Positioned && widget.left == 20.0 && widget.top == 25.0,
      ),
      findsOneWidget,
    );
  });
}
