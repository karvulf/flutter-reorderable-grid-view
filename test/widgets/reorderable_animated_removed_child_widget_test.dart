import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/removed_reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_animation_config.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_animated_removed_child.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const givenChild = Placeholder();
  const givenFadeOutDuration = Duration(milliseconds: 200);
  const givenAnimationConfig = ReorderableAnimationConfig(
    fadeOutDuration: givenFadeOutDuration,
  );
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
                  animationConfig: givenAnimationConfig,
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
      'GIVEN [ReorderableAnimatedRemovedChild] '
      'WHEN fading out '
      'THEN should call onFinished only after the fade out', (tester) async {
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
