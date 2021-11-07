import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_single_child_scroll_view.dart';
import 'package:flutter_test/flutter_test.dart';

import '../services/reorderable_grid_view_builder.dart';

void main() {
  final builder = ReorderableGridViewBuilder();

  testWidgets('GIVEN WHEN THEN', (WidgetTester tester) async {
    // given
    const givenHeight = 200.0;
    const givenWidth = 200.0;
    final givenChildrenIdMap = {
      0: builder.getGridItemEntity(
        child: Container(key: const Key('key')),
      ),
    };

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReorderableSingleChildScrollView(
            height: givenHeight,
            width: givenWidth,
            clipBehavior: Clip.none,
            childrenIdMap: givenChildrenIdMap,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // then
  });
}
