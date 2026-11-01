import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderWrap;
import 'package:flutter_reorderable_grid_view/controller/reorderable_wrap_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const givenSizes = [
    Size(60, 50),
    Size(180, 30),
    Size(100, 70),
    Size(140, 50),
    Size(60, 20),
    Size(180, 50),
  ];

  late ReorderableWrapController controller;

  setUp(() {
    controller = ReorderableWrapController();
  });

  /// Pumps [wrap] with children of [givenSizes] inside a 400 x 500 box.
  Future<void> pumpWidget(WidgetTester tester, {required Wrap wrap}) =>
      tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(width: 400, height: 500, child: wrap),
          ),
        ),
      );

  List<Widget> buildChildren() => [
        for (final (index, size) in givenSizes.indexed)
          SizedBox.fromSize(key: Key('$index'), size: size),
      ];

  /// Returns the offsets of all children inside the pumped [Wrap].
  List<Offset> getWrapOffsets(WidgetTester tester) {
    final wrapTopLeft = tester.getTopLeft(find.byType(Wrap));
    return [
      for (var index = 0; index < givenSizes.length; index++)
        tester.getTopLeft(find.byKey(Key('$index'))) - wrapTopLeft,
    ];
  }

  group('#calculateWrapOffsets', () {
    testWidgets(
        'GIVEN [Wrap] with default layout '
        'WHEN calling calculateWrapOffsets '
        'THEN should return the same offsets as [Wrap]',
        (WidgetTester tester) async {
      // given
      await pumpWidget(
        tester,
        wrap: Wrap(spacing: 8, runSpacing: 4, children: buildChildren()),
      );

      // when
      final actual = controller.calculateWrapOffsets(
        sizes: givenSizes,
        renderWrap: tester.renderObject<RenderWrap>(find.byType(Wrap)),
      );

      // then
      expect(actual, equals(getWrapOffsets(tester)));
    });

    testWidgets(
        'GIVEN [Wrap] with no default value for every layout value '
        'WHEN calling calculateWrapOffsets '
        'THEN should return the same offsets as [Wrap]',
        (WidgetTester tester) async {
      // given
      await pumpWidget(
        tester,
        wrap: Wrap(
          direction: Axis.vertical,
          alignment: WrapAlignment.spaceBetween,
          spacing: 8,
          runAlignment: WrapAlignment.center,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.end,
          textDirection: TextDirection.rtl,
          verticalDirection: VerticalDirection.up,
          children: buildChildren(),
        ),
      );

      // when
      final actual = controller.calculateWrapOffsets(
        sizes: givenSizes,
        renderWrap: tester.renderObject<RenderWrap>(find.byType(Wrap)),
      );

      // then
      expect(actual, equals(getWrapOffsets(tester)));
    });
  });
}
