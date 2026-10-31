import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/utils/reorderable_wrap_layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Returns the offsets of children with [sizes] laid out by a real [Wrap].
  Future<List<Offset>> layoutRealWrap(
    WidgetTester tester, {
    required List<Size> sizes,
    required double maxWidth,
    required double spacing,
    required double runSpacing,
  }) async {
    final wrapKey = GlobalKey();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: maxWidth,
            child: Align(
              alignment: Alignment.topLeft,
              child: Wrap(
                key: wrapKey,
                spacing: spacing,
                runSpacing: runSpacing,
                children: [
                  for (final (index, size) in sizes.indexed)
                    SizedBox.fromSize(key: Key('$index'), size: size),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    final wrapTopLeft = tester.getTopLeft(find.byKey(wrapKey));
    return [
      for (var index = 0; index < sizes.length; index++)
        tester.getTopLeft(find.byKey(Key('$index'))) - wrapTopLeft,
    ];
  }

  final testCases = {
    'different widths and heights': [
      const Size(60, 50),
      const Size(180, 30),
      const Size(100, 70),
      const Size(140, 50),
      const Size(60, 20),
      const Size(180, 50),
    ],
    'children fitting exactly into one run': [
      const Size(100, 50),
      const Size(100, 50),
      const Size(184, 50),
      const Size(100, 50),
    ],
    'child wider than the max width': [
      const Size(50, 50),
      const Size(500, 50),
      const Size(50, 50),
    ],
    'children without size': [
      Size.zero,
      const Size(100, 50),
      Size.zero,
      const Size(300, 50),
    ],
  };

  for (final MapEntry(key: description, value: sizes) in testCases.entries) {
    for (final (spacing, runSpacing) in [(0.0, 0.0), (8.0, 4.0)]) {
      testWidgets(
          'GIVEN $description, spacing $spacing and runSpacing $runSpacing '
          'WHEN calling calculateWrapOffsets '
          'THEN should return the same offsets as Wrap', (tester) async {
        // given
        const givenMaxWidth = 400.0;
        final expected = await layoutRealWrap(
          tester,
          sizes: sizes,
          maxWidth: givenMaxWidth,
          spacing: spacing,
          runSpacing: runSpacing,
        );

        // when
        final actual = calculateWrapOffsets(
          sizes: sizes,
          maxWidth: givenMaxWidth,
          spacing: spacing,
          runSpacing: runSpacing,
        );

        // then
        expect(actual, equals(expected));
      });
    }
  }
}
