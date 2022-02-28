import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/order_update_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/animated/reorderable_animated_container.dart';
import 'package:flutter_reorderable_grid_view/widgets/animated/reorderable_draggable.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpWidgetWithGridView(
    WidgetTester tester, {
    required List<Widget> children,
    List<int> lockedIndices = const [],
    ReorderListCallback? onReorder,
  }) =>
      tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableBuilder(
              children: children,
              onReorder: onReorder ?? (_) {},
              lockedIndices: lockedIndices,
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
          ),
        ),
      );

  group('#Building [ReorderableBuilder]', () {
    testWidgets(
        'GIVEN no children and [GridView] '
        'WHEN pumping [ReorderableBuilder] '
        'THEN should show expected widgets and values',
        (WidgetTester tester) async {
      // given

      // when
      await pumpWidgetWithGridView(tester, children: const []);

      // then
      expect(find.byType(ReorderableBuilder), findsOneWidget);
      expect(
          find.byWidgetPredicate((widget) =>
              widget is GridView &&
              (widget.childrenDelegate as SliverChildListDelegate)
                  .children
                  .isEmpty),
          findsOneWidget);
    });

    testWidgets(
        'GIVEN 2 children and [GridView] '
        'WHEN pumping [ReorderableBuilder] '
        'THEN should show expected widgets and values',
        (WidgetTester tester) async {
      // given
      final givenChildren = _generateChildren(length: 2);

      // when
      await pumpWidgetWithGridView(tester, children: givenChildren);

      // then
      expect(find.byType(ReorderableAnimatedContainer),
          findsNWidgets(givenChildren.length));
      expect(_findReorderableAnimatedContainer(key: givenChildren[0].key),
          findsOneWidget);
      expect(_findReorderableAnimatedContainer(key: givenChildren[1].key),
          findsOneWidget);
    });

    testWidgets(
        'GIVEN 2 children and [GridView] '
        'WHEN changing orientation '
        'THEN should still display all widgets', (WidgetTester tester) async {
      // given
      // rotate to portrait
      tester.binding.window.physicalSizeTestValue = const Size(400, 1600);
      tester.binding.window.devicePixelRatioTestValue = 1;

      final givenChildren = _generateChildren(length: 2);
      await pumpWidgetWithGridView(tester, children: givenChildren);

      // when
      // rotate to landscape
      tester.binding.window.physicalSizeTestValue = const Size(1600, 400);
      tester.binding.window.devicePixelRatioTestValue = 1;

      await tester.pumpAndSettle();

      // then
      expect(find.byType(ReorderableAnimatedContainer),
          findsNWidgets(givenChildren.length));
      expect(_findReorderableAnimatedContainer(key: givenChildren[0].key),
          findsOneWidget);
      expect(_findReorderableAnimatedContainer(key: givenChildren[1].key),
          findsOneWidget);

      tester.binding.window.clearAllTestValues();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    testWidgets(
        'GIVEN 2 children with same keys and [GridView] '
        'WHEN pumping [ReorderableBuilder] '
        'THEN should throw assertion error', (WidgetTester tester) async {
      // given
      final givenChildren = List.generate(
        2,
        (index) => Container(
          key: const Key('same'),
          child: Text(index.toString()),
        ),
      );

      // when
      await pumpWidgetWithGridView(tester, children: givenChildren);

      // then
      expect(tester.takeException(), isInstanceOf<Exception>());
    });

    testWidgets(
        'GIVEN 2 children and [GridView] with missing onReorder but enableReorder = true '
        'WHEN pumping [ReorderableBuilder] '
        'THEN should throw assertion error', (WidgetTester tester) async {
      // given
      final givenChildren = _generateChildren(length: 2);

      // when

      // then
      expect(
          () => tester.pumpWidget(
                MaterialApp(
                  home: ReorderableBuilder(
                    children: givenChildren,
                    enableDraggable: true,
                    builder: (children, scrollController) => GridView(
                      controller: scrollController,
                      children: children,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 8,
                      ),
                    ),
                  ),
                ),
              ),
          throwsAssertionError);
    });

    testWidgets(
        'GIVEN 2 children and [GridView.count] '
        'WHEN pumping [ReorderableBuilder] '
        'THEN should show expected widgets and values',
        (WidgetTester tester) async {
      // given
      final givenChildren = _generateChildren(length: 2);

      // when
      await tester.pumpWidget(
        MaterialApp(
          home: ReorderableBuilder(
            children: givenChildren,
            onReorder: (_) {},
            builder: (children, scrollController) => GridView.count(
              controller: scrollController,
              children: children,
              crossAxisCount: 3,
            ),
          ),
        ),
      );

      // then
      expect(find.byType(ReorderableAnimatedContainer),
          findsNWidgets(givenChildren.length));
      expect(_findReorderableAnimatedContainer(key: givenChildren[0].key),
          findsOneWidget);
      expect(_findReorderableAnimatedContainer(key: givenChildren[1].key),
          findsOneWidget);
    });

    testWidgets(
        'GIVEN 2 children and [GridView.extent] '
        'WHEN pumping [ReorderableBuilder] '
        'THEN should show expected widgets and values',
        (WidgetTester tester) async {
      // given
      final givenChildren = _generateChildren(length: 2);

      // when
      await tester.pumpWidget(
        MaterialApp(
          home: ReorderableBuilder(
            children: givenChildren,
            onReorder: (_) {},
            builder: (children, scrollController) => GridView.extent(
              controller: scrollController,
              children: children,
              maxCrossAxisExtent: 200,
            ),
          ),
        ),
      );

      // then
      expect(find.byType(ReorderableAnimatedContainer),
          findsNWidgets(givenChildren.length));
      expect(_findReorderableAnimatedContainer(key: givenChildren[0].key),
          findsOneWidget);
      expect(_findReorderableAnimatedContainer(key: givenChildren[1].key),
          findsOneWidget);
    });

    testWidgets(
        'GIVEN 2 children and [GridView.builder] '
        'WHEN pumping [ReorderableBuilder] '
        'THEN should show expected widgets and values',
        (WidgetTester tester) async {
      // given
      final givenChildren = _generateChildren(length: 2);

      // when
      await tester.pumpWidget(
        MaterialApp(
          home: ReorderableBuilder(
            children: givenChildren,
            onReorder: (_) {},
            builder: (children, scrollController) => GridView.builder(
              key: const Key('builder'),
              controller: scrollController,
              itemCount: children.length,
              itemBuilder: (context, index) {
                return children[index];
              },
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 4,
                crossAxisSpacing: 8,
              ),
            ),
          ),
        ),
      );

      // then
      expect(find.byType(ReorderableAnimatedContainer),
          findsNWidgets(givenChildren.length));
      expect(_findReorderableAnimatedContainer(key: givenChildren[0].key),
          findsOneWidget);
      expect(_findReorderableAnimatedContainer(key: givenChildren[1].key),
          findsOneWidget);
    });
  });

  group('#Updating children', () {
    testWidgets(
        'GIVEN 2 children and [ReorderableBuilder] '
        'WHEN adding child '
        'THEN should update with new child', (WidgetTester tester) async {
      // given
      final givenChildren = _generateChildren(length: 2);
      await tester.pumpWidget(
        MaterialApp(
          home: _UpdateChildrenReorderableBuilderTest(
            children: givenChildren,
          ),
        ),
      );

      // when
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // then
      expect(find.byType(ReorderableAnimatedContainer),
          findsNWidgets(givenChildren.length + 1));
      expect(_findReorderableAnimatedContainer(key: givenChildren[0].key),
          findsOneWidget);
      expect(_findReorderableAnimatedContainer(key: givenChildren[1].key),
          findsOneWidget);
      expect(_findReorderableAnimatedContainer(key: const Key('new')),
          findsOneWidget);
    });

    testWidgets(
        'GIVEN 2 children and [ReorderableBuilder] '
        'WHEN adding child with duplicated key '
        'THEN should throw exception', (WidgetTester tester) async {
      // given
      final givenChildren = _generateChildren(length: 2);
      await tester.pumpWidget(
        MaterialApp(
          home: _UpdateChildrenReorderableBuilderTest(
            children: givenChildren,
            updateChildrenWithDuplicatedKey: true,
          ),
        ),
      );

      // when
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // then
      FlutterError.onError = null; // weird
      expect(tester.takeException(), isInstanceOf<Exception>());
    });

    testWidgets(
        'GIVEN 4 children and [ReorderableBuilder] '
        'WHEN removing child at index 2 '
        'THEN should update children without removed child',
        (WidgetTester tester) async {
      // given
      final givenChildren = _generateChildren(length: 4);
      await tester.pumpWidget(
        MaterialApp(
          home: _UpdateChildrenReorderableBuilderTest(
            children: givenChildren,
          ),
        ),
      );

      // when
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();

      // then
      expect(find.byType(ReorderableAnimatedContainer),
          findsNWidgets(givenChildren.length - 1));
      expect(_findReorderableAnimatedContainer(key: givenChildren[0].key),
          findsOneWidget);
      expect(_findReorderableAnimatedContainer(key: givenChildren[1].key),
          findsOneWidget);
      expect(_findReorderableAnimatedContainer(key: givenChildren[2].key),
          findsNothing);
      expect(_findReorderableAnimatedContainer(key: givenChildren[3].key),
          findsOneWidget);
    });

    testWidgets(
        'GIVEN 2 children and [ReorderableBuilder] '
        'WHEN updating first child '
        'THEN should update children', (WidgetTester tester) async {
      // given
      final givenChildren = _generateChildren(length: 2);
      await tester.pumpWidget(
        MaterialApp(
          home: _UpdateChildrenReorderableBuilderTest(
            children: givenChildren,
          ),
        ),
      );

      // when
      await tester.tap(find.text('Replace'));
      await tester.pumpAndSettle();

      // then
      expect(find.byType(ReorderableAnimatedContainer),
          findsNWidgets(givenChildren.length));
      expect(_findReorderableAnimatedContainer(key: givenChildren[0].key),
          findsNothing);
      expect(_findReorderableAnimatedContainer(key: const Key('replace')),
          findsOneWidget);
    });
  });

  group('#Drag and Drop in positive direction', () {
    testWidgets(
        'GIVEN 10 children and [ReorderableBuilder] '
        'WHEN dragging the first to the last child and releasing '
        'THEN should call onReorder', (WidgetTester tester) async {
      // given
      var actualOrderUpdateEntities = <OrderUpdateEntity>[];
      final givenChildren = _generateChildren(length: 10);
      await pumpWidgetWithGridView(
        tester,
        children: givenChildren,
        onReorder: (orderUpdateEntities) {
          actualOrderUpdateEntities = orderUpdateEntities;
        },
      );
      await tester.pumpAndSettle();

      // when
      final firstLocation = tester.getCenter(find.text('0'));
      final gesture = await tester.startGesture(firstLocation, pointer: 7);
      await tester.pump(kLongPressTimeout);

      final secondLocation = tester.getCenter(find.text('9'));
      await gesture.moveTo(secondLocation);
      await tester.pump();

      await gesture.up();
      await tester.pump();

      // then
      const expectedOrderUpdateEntities = [
        OrderUpdateEntity(oldIndex: 0, newIndex: 9),
      ];
      expect(actualOrderUpdateEntities, equals(expectedOrderUpdateEntities));
    });
  });

  group('#Drag and Drop in negative direction', () {
    testWidgets(
        'GIVEN 10 children and [ReorderableBuilder] '
        'WHEN dragging the last to the first child and releasing '
        'THEN should call onReorder', (WidgetTester tester) async {
      // given
      var actualOrderUpdateEntities = <OrderUpdateEntity>[];
      final givenChildren = _generateChildren(length: 10);
      await pumpWidgetWithGridView(
        tester,
        children: givenChildren,
        onReorder: (orderUpdateEntities) {
          actualOrderUpdateEntities = orderUpdateEntities;
        },
      );
      await tester.pumpAndSettle();

      // when
      final firstLocation = tester.getCenter(find.text('9'));
      final gesture = await tester.startGesture(firstLocation, pointer: 7);
      await tester.pump(kLongPressTimeout);

      final secondLocation = tester.getCenter(find.text('0'));
      await gesture.moveTo(secondLocation);
      await tester.pump();

      await gesture.up();
      await tester.pump();

      // then
      const expectedOrderUpdateEntities = [
        OrderUpdateEntity(oldIndex: 9, newIndex: 0),
      ];
      expect(actualOrderUpdateEntities, equals(expectedOrderUpdateEntities));
    });
  });

  group('#Drag and Drop with lockedIndices', () {
    testWidgets(
        'GIVEN 4 children, [ReorderableBuilder] and lockedIndices = [2] '
        'WHEN dragging the first to the locked child and releasing '
        'THEN should not call onReorder', (WidgetTester tester) async {
      // given
      var actualOrderUpdateEntities = <OrderUpdateEntity>[];
      final givenChildren = _generateChildren(length: 4);
      await pumpWidgetWithGridView(
        tester,
        children: givenChildren,
        lockedIndices: [1],
        onReorder: (orderUpdateEntities) {
          actualOrderUpdateEntities = orderUpdateEntities;
        },
      );
      await tester.pumpAndSettle();

      // when
      final firstLocation = tester.getCenter(find.text('0'));
      final gesture = await tester.startGesture(firstLocation, pointer: 7);
      await tester.pump(kLongPressTimeout);

      final secondLocation = tester.getCenter(find.text('1'));
      await gesture.moveTo(secondLocation);
      await tester.pump();

      await gesture.up();
      await tester.pump();

      // then
      expect(actualOrderUpdateEntities, isEmpty);
    });

    testWidgets(
        'GIVEN 20 children, [ReorderableBuilder] and lockedIndices = [2, 10, 11] '
        'WHEN dragging the first to the last child and releasing '
        'THEN should call onReorder', (WidgetTester tester) async {
      // given
      var actualOrderUpdateEntities = <OrderUpdateEntity>[];
      final givenChildren = _generateChildren(length: 20);
      final actualChildren = List<Widget>.from(givenChildren);
      await pumpWidgetWithGridView(
        tester,
        children: givenChildren,
        lockedIndices: [2, 10, 11],
        onReorder: (orderUpdateEntities) {
          actualOrderUpdateEntities = orderUpdateEntities;
          for (final orderUpdateEntity in orderUpdateEntities) {
            final child = actualChildren.removeAt(orderUpdateEntity.oldIndex);
            actualChildren.insert(orderUpdateEntity.newIndex, child);
          }
        },
      );
      await tester.pumpAndSettle();

      // when
      final firstLocation = tester.getCenter(find.text('0'));
      final gesture = await tester.startGesture(firstLocation, pointer: 7);
      await tester.pump(kLongPressTimeout);

      final secondLocation =
          tester.getCenter(find.text('19', skipOffstage: false));
      await gesture.moveTo(secondLocation);
      await tester.pump();

      await gesture.up();
      await tester.pump();

      // then
      const expectedOrderUpdateEntities = [
        OrderUpdateEntity(oldIndex: 0, newIndex: 19),
        OrderUpdateEntity(oldIndex: 2, newIndex: 1),
        OrderUpdateEntity(oldIndex: 11, newIndex: 9),
      ];
      expect(actualOrderUpdateEntities, equals(expectedOrderUpdateEntities));
      final expectedChildren = [
        givenChildren[1],
        givenChildren[3],
        givenChildren[2],
        givenChildren[4],
        givenChildren[5],
        givenChildren[6],
        givenChildren[7],
        givenChildren[8],
        givenChildren[9],
        givenChildren[12],
        givenChildren[10],
        givenChildren[11],
        givenChildren[13],
        givenChildren[14],
        givenChildren[15],
        givenChildren[16],
        givenChildren[17],
        givenChildren[18],
        givenChildren[19],
        givenChildren[0],
      ];
      expect(actualChildren, equals(expectedChildren));
    });

    testWidgets(
        'GIVEN 8 children, [ReorderableBuilder] and lockedIndices = [2, 3, 4] '
        'WHEN dragging the last to the first child and releasing '
        'THEN should call onReorder', (WidgetTester tester) async {
      // given
      var actualOrderUpdateEntities = <OrderUpdateEntity>[];
      final givenChildren = _generateChildren(length: 8);
      final actualChildren = List<Widget>.from(givenChildren);
      await pumpWidgetWithGridView(
        tester,
        children: givenChildren,
        lockedIndices: [2, 3, 4],
        onReorder: (orderUpdateEntities) {
          actualOrderUpdateEntities = orderUpdateEntities;
          for (final orderUpdateEntity in orderUpdateEntities) {
            final child = actualChildren.removeAt(orderUpdateEntity.oldIndex);
            actualChildren.insert(orderUpdateEntity.newIndex, child);
          }
        },
      );
      await tester.pumpAndSettle();

      // when
      final firstLocation = tester.getCenter(find.text('7'));
      final gesture = await tester.startGesture(firstLocation, pointer: 7);
      await tester.pump(kLongPressTimeout);

      final secondLocation = tester.getCenter(find.text('0'));
      await gesture.moveTo(secondLocation);
      await tester.pump();

      await gesture.up();
      await tester.pump();

      // then
      const expectedOrderUpdateEntities = [
        OrderUpdateEntity(oldIndex: 7, newIndex: 0),
        OrderUpdateEntity(oldIndex: 2, newIndex: 5),
      ];
      expect(actualOrderUpdateEntities, equals(expectedOrderUpdateEntities));
      final expectedChildren = [
        givenChildren[7],
        givenChildren[0],
        givenChildren[2],
        givenChildren[3],
        givenChildren[4],
        givenChildren[1],
        givenChildren[5],
        givenChildren[6],
      ];
      expect(actualChildren, equals(expectedChildren));
    });
  });
}

Finder _findReorderableAnimatedContainer({required Key? key}) {
  return find.byWidgetPredicate((widget) =>
      widget is ReorderableAnimatedContainer &&
      widget.key == Key(key.hashCode.toString()) &&
      (widget.child as ReorderableDraggable).key == key);
}

List<Widget> _generateChildren({required int length}) => List.generate(
      length,
      (index) => Container(
        key: Key(index.toString()),
        child: Text(index.toString()),
      ),
    );

class _UpdateChildrenReorderableBuilderTest extends StatefulWidget {
  final List<Widget> children;
  final bool updateChildrenWithDuplicatedKey;

  const _UpdateChildrenReorderableBuilderTest({
    required this.children,
    this.updateChildrenWithDuplicatedKey = false,
    Key? key,
  }) : super(key: key);

  @override
  _UpdateChildrenReorderableBuilderTestState createState() =>
      _UpdateChildrenReorderableBuilderTestState();
}

class _UpdateChildrenReorderableBuilderTestState
    extends State<_UpdateChildrenReorderableBuilderTest> {
  late List<Widget> children;

  @override
  void initState() {
    super.initState();
    children = List<Widget>.from(widget.children);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              TextButton(
                onPressed: () {
                  final updatedChildren = List<Widget>.from(children);
                  updatedChildren[0] = Container(
                    key: const Key('replace'),
                    child: const Text('replace'),
                  );
                  setState(() {
                    children = updatedChildren;
                  });
                },
                child: const Text('Replace'),
              ),
              TextButton(
                onPressed: () {
                  final updatedChildren = List<Widget>.from(children);
                  updatedChildren.removeAt(2);
                  setState(() {
                    children = updatedChildren;
                  });
                },
                child: const Text('Remove'),
              ),
              TextButton(
                onPressed: () {
                  final updatedChildren = List<Widget>.from(children);
                  updatedChildren.insert(
                    0,
                    Container(
                      key: widget.updateChildrenWithDuplicatedKey
                          ? children.first.key
                          : const Key('new'),
                      child: const Text('new'),
                    ),
                  );
                  setState(() {
                    children = updatedChildren;
                  });
                },
                child: const Text('Add'),
              ),
            ],
          ),
          Expanded(
            child: ReorderableBuilder(
              children: children,
              onReorder: (_) {},
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
          ),
        ],
      ),
    );
  }
}
