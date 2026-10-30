import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/controller/reorderable_builder_controller.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_animation_config.dart';
import 'package:flutter_reorderable_grid_view/widgets/removed/reorderable_animated_removed_child.dart';
import 'package:flutter_reorderable_grid_view/widgets/removed/reorderable_removed_children.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../reorderable_builder.dart';

void main() {
  final reorderableBuilder = ReorderableBuilder();
  late ReorderableBuilderController controller;

  const givenRemoveDuration = Duration(milliseconds: 200);
  const givenChild1 = SizedBox(key: ValueKey('1'));
  const givenChild2 = SizedBox(key: ValueKey('2'));
  final givenEntity1 = reorderableBuilder.getEntity(
    key: '1',
    updatedOffset: Offset.zero,
    isBuildingOffset: false,
  );
  final givenEntity2 = reorderableBuilder.getEntity(
    key: '2',
    updatedOffset: const Offset(20.0, 0.0),
    isBuildingOffset: false,
  );

  setUp(() {
    controller = ReorderableBuilderController();
  });

  /// Pumps [ReorderableRemovedChildren] with a size of 400 x 400.
  ///
  /// [builtChildren] are added to the controller while building, like the
  /// GridView of ReorderableBuilder.builder does it.
  Future<void> pumpWidget(
    WidgetTester tester, {
    List<Widget>? children,
    int? itemCount,
    List<Widget> builtChildren = const [],
    ReorderableAnimationConfig animationConfig =
        const ReorderableAnimationConfig(
      remove: ReorderableItemTransition(duration: givenRemoveDuration),
    ),
  }) async =>
      tester.pumpWidget(
        MaterialApp(
          home: Align(
            alignment: Alignment.topLeft,
            child: SizedBox.square(
              dimension: 400.0,
              child: ReorderableRemovedChildren(
                children: children,
                itemCount: itemCount,
                controller: controller,
                animationConfig: animationConfig,
                scrollController: null,
                getScrollOffset: () => Offset.zero,
                child: Builder(
                  builder: (context) {
                    for (final child in builtChildren) {
                      controller.addBuiltChild(
                        key: child.key! as ValueKey,
                        child: child,
                      );
                    }
                    return const SizedBox.expand();
                  },
                ),
              ),
            ),
          ),
        ),
      );

  Finder findRemovedChild(String key) => find.byWidgetPredicate(
        (widget) =>
            widget is ReorderableAnimatedRemovedChild &&
            widget.removedEntity.key.value == key,
      );

  testWidgets(
      'GIVEN children '
      'WHEN pumping [ReorderableRemovedChildren] '
      'THEN should show expected widgets', (tester) async {
    // given

    // when
    await pumpWidget(tester, children: const [givenChild1, givenChild2]);

    // then
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Stack &&
            widget.fit == StackFit.passthrough &&
            widget.clipBehavior == Clip.none &&
            widget.children.length == 2 &&
            widget.children.first is Builder,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Positioned &&
            widget.left == 0.0 &&
            widget.top == 0.0 &&
            widget.right == 0.0 &&
            widget.bottom == 0.0 &&
            widget.child is ClipRect,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is ClipRect &&
            widget.child is Stack &&
            (widget.child! as Stack).clipBehavior == Clip.none &&
            (widget.child! as Stack).children.isEmpty,
      ),
      findsOneWidget,
    );
    expect(find.byType(ReorderableAnimatedRemovedChild), findsNothing);
  });

  group('#children', () {
    testWidgets(
        'GIVEN two visible children '
        'WHEN removing the second child '
        'THEN should animate out the second child', (tester) async {
      // given
      await pumpWidget(tester, children: const [givenChild1, givenChild2]);
      controller.lastRemovedEntities = [givenEntity2];

      // when
      await pumpWidget(tester, children: const [givenChild1]);

      // then
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is ReorderableAnimatedRemovedChild &&
              widget.removedEntity.key == givenEntity2.key &&
              widget.removedEntity.child == givenChild2 &&
              widget.removedEntity.offset == givenEntity2.updatedOffset &&
              widget.removedEntity.size == givenEntity2.size,
        ),
        findsOneWidget,
      );
    });

    testWidgets(
        'GIVEN second child outside of the visible area '
        'WHEN removing the second child '
        'THEN should not animate out the second child', (tester) async {
      // given
      await pumpWidget(tester, children: const [givenChild1, givenChild2]);
      controller.lastRemovedEntities = [
        reorderableBuilder.getEntity(
          key: '2',
          updatedOffset: const Offset(1000.0, 1000.0),
          isBuildingOffset: false,
        ),
      ];

      // when
      await pumpWidget(tester, children: const [givenChild1]);

      // then
      expect(find.byType(ReorderableAnimatedRemovedChild), findsNothing);
    });

    testWidgets(
        'GIVEN remove duration = Duration.zero '
        'WHEN removing the second child '
        'THEN should not animate out the second child', (tester) async {
      // given
      const givenAnimationConfig = ReorderableAnimationConfig(
        remove: ReorderableItemTransition(duration: Duration.zero),
      );
      await pumpWidget(
        tester,
        children: const [givenChild1, givenChild2],
        animationConfig: givenAnimationConfig,
      );
      controller.lastRemovedEntities = [givenEntity2];

      // when
      await pumpWidget(
        tester,
        children: const [givenChild1],
        animationConfig: givenAnimationConfig,
      );

      // then
      expect(find.byType(ReorderableAnimatedRemovedChild), findsNothing);
    });

    testWidgets(
        'GIVEN changePositionAfterFadeOut = true '
        'WHEN removing the second child '
        'THEN should delay position changes for one update', (tester) async {
      // given
      const givenAnimationConfig = ReorderableAnimationConfig(
        remove: ReorderableItemTransition(duration: givenRemoveDuration),
        changePositionAfterFadeOut: true,
      );
      await pumpWidget(
        tester,
        children: const [givenChild1, givenChild2],
        animationConfig: givenAnimationConfig,
      );
      controller.lastRemovedEntities = [givenEntity2];

      // when
      await pumpWidget(
        tester,
        children: const [givenChild1],
        animationConfig: givenAnimationConfig,
      );

      // then
      expect(
        controller.positionChangeDelay,
        equals(givenRemoveDuration ~/ 2),
      );
    });
  });

  group('#itemCount', () {
    setUp(() {
      controller.childrenKeyMap['1'] = givenEntity1;
      controller.childrenKeyMap['2'] = givenEntity2;
    });

    testWidgets(
        'GIVEN two visible built children '
        'WHEN decreasing itemCount and building only the first child '
        'THEN should animate out the second child after this frame',
        (tester) async {
      // given
      await pumpWidget(
        tester,
        itemCount: 2,
        builtChildren: const [givenChild1, givenChild2],
      );

      // when
      await pumpWidget(
        tester,
        itemCount: 1,
        builtChildren: const [givenChild1],
      );
      await tester.pump();

      // then
      expect(find.byType(ReorderableAnimatedRemovedChild), findsOneWidget);
      expect(findRemovedChild('2'), findsOneWidget);
    });

    testWidgets(
        'GIVEN two visible built children '
        'WHEN decreasing itemCount to 0 '
        'THEN should animate out both children in the same frame',
        (tester) async {
      // given
      await pumpWidget(
        tester,
        itemCount: 2,
        builtChildren: const [givenChild1, givenChild2],
      );

      // when
      await pumpWidget(tester, itemCount: 0);

      // then
      expect(findRemovedChild('1'), findsOneWidget);
      expect(findRemovedChild('2'), findsOneWidget);
    });
  });
}
