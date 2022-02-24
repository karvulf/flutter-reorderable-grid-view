import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpWidget(
    WidgetTester tester, {
    required Widget child,
  }) =>
      tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: child,
          ),
        ),
      );

  testWidgets(
      'GIVEN no children and [GridView] '
      'WHEN pumping [ReorderableBuilder] '
      'THEN should show expected widgets and values',
      (WidgetTester tester) async {
    // given

    // when
    await pumpWidget(
      tester,
      child: ReorderableBuilder(
        children: const [],
        onReorder: (orderUpdateEntities) {},
        builder: (children, scrollController) {
          return GridView(
            controller: scrollController,
            children: children,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 4,
              crossAxisSpacing: 8,
            ),
          );
        },
      ),
    );

    // then
    expect(find.byType(ReorderableBuilder), findsOneWidget);
  });
}
