import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_overlay_child.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const givenSize = Size(100.0, 50.0);
  const givenChild = Placeholder();

  Future<void> pumpWidget(WidgetTester tester) => tester.pumpWidget(
        const MaterialApp(
          home: ReorderableOverlayChild(
            size: givenSize,
            child: givenChild,
          ),
        ),
      );

  testWidgets(
      'GIVEN size and child '
      'WHEN pumping [ReorderableOverlayChild] '
      'THEN should show expected widgets', (WidgetTester tester) async {
    // given

    // when
    await pumpWidget(tester);

    // then
    final target = tester.widget<CompositedTransformTarget>(
      find.byType(CompositedTransformTarget),
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is OverlayPortal &&
            widget.child is CompositedTransformTarget,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is CompositedTransformTarget &&
            widget.child is SizedBox &&
            (widget.child as SizedBox).width == givenSize.width &&
            (widget.child as SizedBox).height == givenSize.height &&
            (widget.child as SizedBox).child == null,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Positioned &&
            widget.left == 0.0 &&
            widget.top == 0.0 &&
            widget.child is CompositedTransformFollower,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is CompositedTransformFollower &&
            widget.link == target.link &&
            !widget.showWhenUnlinked &&
            widget.child is SizedBox &&
            (widget.child as SizedBox).width == givenSize.width &&
            (widget.child as SizedBox).height == givenSize.height &&
            (widget.child as SizedBox).child == givenChild,
      ),
      findsOneWidget,
    );
  });
}
