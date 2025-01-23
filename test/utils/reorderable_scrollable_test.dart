import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/utils/reorderable_scrollable.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helper/fakes/fake_build_context.dart';
import '../helper/fakes/fake_scroll_controller.dart';

void main() {
  late ReorderableScrollable reorderableScrollable;

  late FakeScrollController fakeScrollController;
  late FakeBuildContext fakeBuildContext;

  setUp(() {
    fakeScrollController = FakeScrollController();
    fakeBuildContext = FakeBuildContext();

    reorderableScrollable = ReorderableScrollable.of(
      fakeBuildContext,
      scrollController: fakeScrollController,
    );
  });

  group('#isScrollOutside', () {
    test(
        'GIVEN _scrollController = null '
        'WHEN calling isScrollOutside '
        'THEN should return true', () {
      // given
      reorderableScrollable = ReorderableScrollable.of(
        fakeBuildContext,
        scrollController: null,
      );

      // when
      final actual = reorderableScrollable.isScrollOutside;

      // then
      expect(actual, isTrue);
    });

    test(
        'GIVEN _scrollController != null '
        'WHEN calling isScrollOutside '
        'THEN should return true', () {
      // given
      reorderableScrollable = ReorderableScrollable.of(
        fakeBuildContext,
        scrollController: fakeScrollController,
      );

      // when
      final actual = reorderableScrollable.isScrollOutside;

      // then
      expect(actual, isFalse);
    });
  });

  group('#scrollDirection', () {
    test(
        'GIVEN _scrollController != null '
        'WHEN calling scrollDirection '
        'THEN should return axis', () {
      // given
      const givenAxis = Axis.horizontal;
      final fakeScrollController = FakeScrollController(axis: givenAxis);

      reorderableScrollable = ReorderableScrollable.of(
        fakeBuildContext,
        scrollController: fakeScrollController,
      );

      // when
      final actual = reorderableScrollable.scrollDirection;

      // then
      expect(actual, equals(givenAxis));
    });
  });

  group('#pixels', () {
    test(
        'GIVEN _scrollController != null '
        'WHEN calling pixels '
        'THEN should return offset', () {
      // given
      const givenOffset = 12.34;
      final fakeScrollController = FakeScrollController(offset: givenOffset);

      reorderableScrollable = ReorderableScrollable.of(
        fakeBuildContext,
        scrollController: fakeScrollController,
      );

      // when
      final actual = reorderableScrollable.pixels;

      // then
      expect(actual, equals(givenOffset));
    });
  });

  group('#maxScrollExtent', () {
    test(
        'GIVEN _scrollController != null '
        'WHEN calling maxScrollExtent '
        'THEN should return maxScrollExtent', () {
      // given
      const givenMaxScrollExtent = 56.78;
      final fakeScrollController = FakeScrollController(
        maxScrollExtent: givenMaxScrollExtent,
      );

      reorderableScrollable = ReorderableScrollable.of(
        fakeBuildContext,
        scrollController: fakeScrollController,
      );

      // when
      final actual = reorderableScrollable.maxScrollExtent;

      // then
      expect(actual, equals(givenMaxScrollExtent));
    });
  });

  group('#maxScrollExtent', () {
    test(
        'GIVEN value '
        'WHEN calling jumpTo '
        'THEN should call jumpTo of ScrollController with given value', () {
      // given
      const givenValue = 9.10;

      // when
      reorderableScrollable.jumpTo(value: givenValue);

      // then
      fakeScrollController.verifyJumpTo(givenValue);
    });
  });
}
