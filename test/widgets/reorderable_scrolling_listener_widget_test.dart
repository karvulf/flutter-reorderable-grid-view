import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_scrolling_listener.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final givenKey = GlobalKey();
  const givenScrollExtent = 52.12;

  Future<void> pumpWidget(
    WidgetTester tester, {
    ScrollController? scrollController,
    bool enableScrollingWhileDragging = false,
    bool isDragging = false,
    GlobalKey? reorderableChildKey,
    PointerMoveEventListener? onDragUpdate,
  }) async =>
      tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableScrollingListener(
              scrollController: scrollController,
              automaticScrollExtent: givenScrollExtent,
              enableScrollingWhileDragging: enableScrollingWhileDragging,
              isDragging: isDragging,
              reorderableChildKey: reorderableChildKey,
              reverse: false,
              onDragUpdate: onDragUpdate ?? (_) {},
              child: SizedBox(
                key: givenKey,
                height: 300,
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Container(
                    color: Colors.red,
                    height: 2000,
                    width: 100,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Future<TestGesture> move({
    required WidgetTester tester,
    required Finder startGestureFinder,
    required Offset moveOffset,
    bool isScrollableInside = false,
  }) async {
    final firstLocation = tester.getCenter(startGestureFinder);
    final gesture = await tester.startGesture(firstLocation, pointer: 7);
    await tester.pump(kLongPressTimeout);

    // won't trigger onDragStarted to the right time if the move is not started
    if (isScrollableInside) {
      await gesture.moveTo(Offset.zero);
      await tester.pumpAndSettle();
    }
    await gesture.moveTo(moveOffset);

    return gesture;
  }

  testWidgets(
      "GIVEN "
      "WHEN pumping [ReorderableScrollingListener] "
      "THEN should show expected widgets", (WidgetTester tester) async {
    // given

    // when
    await pumpWidget(tester);

    // then
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Listener &&
            widget.behavior == HitTestBehavior.deferToChild &&
            widget.onPointerMove != null,
      ),
      findsOneWidget,
    );
  });

  group('scrollable inner widget', () {
    late ScrollController scrollController;

    setUp(() {
      scrollController = ScrollController();
    });

    group('#reverse = false', () {
      testWidgets(
          'GIVEN inner scrollable widget and dragged item '
          'WHEN moving dragged item down '
          'THEN should scroll down', (WidgetTester tester) async {
        // given
        await tester.pumpWidget(
          MaterialApp(
            home: _TestInnerScrollable(
              scrollController: scrollController,
              reverse: false,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // when
        final gesture = await move(
          tester: tester,
          startGestureFinder: find.byKey(const Key('0')),
          moveOffset: const Offset(0.0, 600.0),
          isScrollableInside: true,
        );
        await gesture.up();
        await tester.pumpAndSettle();

        // then
        final scrollPositionAfter = scrollController.position.pixels;
        expect(scrollPositionAfter, equals(100.0));
      });

      testWidgets(
          'GIVEN inner scrollable widget and dragged item down '
          'WHEN moving dragged item up '
          'THEN should scroll up', (WidgetTester tester) async {
        // given
        await tester.pumpWidget(
          MaterialApp(
            home: _TestInnerScrollable(
              scrollController: scrollController,
              reverse: false,
            ),
          ),
        );
        await tester.pumpAndSettle();
        final gesture = await move(
          tester: tester,
          startGestureFinder: find.byKey(const Key('0')),
          moveOffset: const Offset(0.0, 600.0),
          isScrollableInside: true,
        );

        // when
        await gesture.moveTo(const Offset(0.0, -600.0));
        await gesture.up();
        await tester.pumpAndSettle();

        // then
        final scrollPositionAfter = scrollController.position.pixels;
        expect(scrollPositionAfter, equals(0.0));
      });
    });

    group('#reverse = true', () {
      testWidgets(
          'GIVEN inner scrollable widget and dragged item '
          'WHEN moving dragged item up '
          'THEN should scroll up', (WidgetTester tester) async {
        // given
        await tester.pumpWidget(
          MaterialApp(
            home: _TestInnerScrollable(
              scrollController: scrollController,
              reverse: true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // when
        final gesture = await move(
          tester: tester,
          startGestureFinder: find.byKey(const Key('0')),
          moveOffset: const Offset(0.0, -600.0),
          isScrollableInside: true,
        );
        await gesture.up();
        await tester.pumpAndSettle();

        // then
        final scrollPositionAfter = scrollController.position.pixels;
        expect(scrollPositionAfter, equals(100.0));
      });

      testWidgets(
          'GIVEN inner scrollable widget and dragged item up '
          'WHEN moving dragged item down '
          'THEN should scroll down', (WidgetTester tester) async {
        // given
        await tester.pumpWidget(
          MaterialApp(
            home: _TestInnerScrollable(
              scrollController: scrollController,
              reverse: true,
            ),
          ),
        );
        await tester.pumpAndSettle();
        final gesture = await move(
          tester: tester,
          startGestureFinder: find.byKey(const Key('0')),
          moveOffset: const Offset(0.0, -600.0),
        );

        // when
        await gesture.moveTo(const Offset(0.0, 600.0));
        await gesture.up();
        await tester.pumpAndSettle();

        // then
        final scrollPositionAfter = scrollController.position.pixels;
        expect(scrollPositionAfter, equals(0.0));
      });
    });
  });

  group('scrollable outer widget', () {
    testWidgets(
        'GIVEN outer scrollable widget with reverse = true and dragged item '
        'WHEN moving dragged item down '
        'THEN should scroll down', (WidgetTester tester) async {
      // given
      late BuildContext actualContext;
      await tester.pumpWidget(
        MaterialApp(
          home: _TestOuterScrollable(
            onBuilt: (context) {
              actualContext = context;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // when
      final gesture = await move(
        tester: tester,
        startGestureFinder: find.byKey(const Key('0')),
        moveOffset: const Offset(0.0, -600.0),
      );
      await gesture.up();
      await tester.pumpAndSettle();

      // then
      final scrollPositionAfter = Scrollable.of(actualContext).position.pixels;
      expect(scrollPositionAfter, equals(100.0));
    });

    testWidgets(
        'GIVEN outer scrollable widget with reverse = true and dragged item down '
        'WHEN moving dragged item up '
        'THEN should scroll up', (WidgetTester tester) async {
      // given
      late BuildContext actualContext;
      await tester.pumpWidget(
        MaterialApp(
          home: _TestOuterScrollable(
            onBuilt: (context) {
              actualContext = context;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      final gesture = await move(
        tester: tester,
        startGestureFinder: find.byKey(const Key('0')),
        moveOffset: const Offset(0.0, -600.0),
      );

      // when
      await gesture.moveTo(const Offset(0.0, 600.0));
      await gesture.up();
      await tester.pumpAndSettle();

      // then
      final scrollPositionAfter = Scrollable.of(actualContext).position.pixels;
      expect(scrollPositionAfter, equals(0.0));
    });
  });

  testWidgets(
      "GIVEN scrollable GridView between header and footer and dragged item "
      "WHEN moving dragged item to the bottom of the GridView "
      "THEN should scroll down", (WidgetTester tester) async {
    // given
    final givenScrollController = ScrollController();
    final givenChildKey = GlobalKey();
    const givenHeaderHeight = 200.0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReorderableBuilder.builder(
            scrollController: givenScrollController,
            longPressDelay: Duration.zero,
            onReorder: (_) {},
            itemCount: 200,
            childBuilder: (itemBuilder) => Column(
              key: givenChildKey,
              children: [
                const SizedBox(height: givenHeaderHeight),
                Expanded(
                  child: GridView.builder(
                    controller: givenScrollController,
                    itemCount: 200,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                    ),
                    itemBuilder: (context, index) => itemBuilder(
                      ColoredBox(
                        key: Key(index.toString()),
                        color: Colors.lightBlue,
                      ),
                      index,
                    ),
                  ),
                ),
                const SizedBox(height: givenHeaderHeight),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final gridViewRect = tester.getRect(find.byType(GridView));

    // when
    final gesture = await move(
      tester: tester,
      startGestureFinder: find.byKey(const Key('0')),
      moveOffset: Offset(gridViewRect.left + 50.0, gridViewRect.bottom - 20.0),
      isScrollableInside: true,
    );
    await tester.pump(const Duration(milliseconds: 500));

    // then
    expect(givenScrollController.offset, greaterThan(0.0));

    await gesture.up();
    await tester.pumpAndSettle();
  });

  group('outer scrollable between header and footer', () {
    final givenScrollController = ScrollController();

    Future<Rect> pumpWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const SizedBox(height: 200.0),
                Expanded(
                  child: SingleChildScrollView(
                    controller: givenScrollController,
                    child: ReorderableBuilder(
                      longPressDelay: Duration.zero,
                      automaticScrollExtent: 50.0,
                      onReorder: (_) {},
                      builder: (children) => GridView.count(
                        key: GlobalKey(),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 4,
                        children: children,
                      ),
                      children: [
                        for (var i = 0; i < 100; i++)
                          ColoredBox(
                            key: Key(i.toString()),
                            color: Colors.lightBlue,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 100.0),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return tester.getRect(find.byType(SingleChildScrollView));
    }

    testWidgets(
        "GIVEN dragged item "
        "WHEN moving dragged item to the middle of the scrollable "
        "THEN should not scroll", (WidgetTester tester) async {
      // given
      final scrollableRect = await pumpWidget(tester);

      // when
      final gesture = await move(
        tester: tester,
        startGestureFinder: find.byKey(const Key('0')),
        moveOffset: scrollableRect.center,
        isScrollableInside: true,
      );
      await tester.pump(const Duration(milliseconds: 500));

      // then
      expect(givenScrollController.offset, equals(0.0));

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets(
        "GIVEN dragged item "
        "WHEN moving dragged item to the bottom of the scrollable "
        "THEN should scroll down", (WidgetTester tester) async {
      // given
      final scrollableRect = await pumpWidget(tester);

      // when
      final gesture = await move(
        tester: tester,
        startGestureFinder: find.byKey(const Key('0')),
        moveOffset: scrollableRect.bottomCenter - const Offset(0.0, 20.0),
        isScrollableInside: true,
      );
      await tester.pump(const Duration(milliseconds: 500));

      // then
      expect(givenScrollController.offset, greaterThan(0.0));

      await gesture.up();
      await tester.pumpAndSettle();
    });
  });
}

class _TestInnerScrollable extends StatefulWidget {
  final ScrollController scrollController;
  final bool reverse;

  const _TestInnerScrollable({
    required this.scrollController,
    required this.reverse,
  });

  @override
  State<_TestInnerScrollable> createState() => _TestInnerScrollableState();
}

class _TestInnerScrollableState extends State<_TestInnerScrollable> {
  final _gridViewKey = GlobalKey();

  List<int> children = List.generate(200, (index) => index);

  @override
  Widget build(BuildContext context) {
    return ReorderableBuilder.builder(
      scrollController: widget.scrollController,
      longPressDelay: Duration.zero,
      reverse: widget.reverse,
      onReorder: (ReorderedListFunction reorderedListFunction) {
        setState(() {
          children = reorderedListFunction(children) as List<int>;
        });
      },
      itemCount: children.length,
      childBuilder: (itemBuilder) {
        return GridView.builder(
          key: _gridViewKey,
          controller: widget.scrollController,
          itemCount: children.length,
          reverse: widget.reverse,
          itemBuilder: (context, index) {
            return itemBuilder(
              ColoredBox(
                key: Key(children.elementAt(index).toString()),
                color: Colors.lightBlue,
                child: Text(
                  children.elementAt(index).toString(),
                ),
              ),
              index,
            );
          },
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 4,
            crossAxisSpacing: 8,
          ),
        );
      },
    );
  }
}

class _TestOuterScrollable extends StatefulWidget {
  final void Function(BuildContext context) onBuilt;

  const _TestOuterScrollable({
    required this.onBuilt,
  });

  @override
  State<_TestOuterScrollable> createState() => _TestOuterScrollableState();
}

class _TestOuterScrollableState extends State<_TestOuterScrollable> {
  final _gridViewKey = GlobalKey();

  List<int> children = List.generate(200, (index) => index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        reverse: true,
        child: Builder(
          builder: (context) {
            widget.onBuilt(context);
            return Column(
              children: [
                const SizedBox(
                  height: 200.0,
                  width: double.infinity,
                  child: ColoredBox(color: Colors.green),
                ),
                ReorderableBuilder.builder(
                  onReorder: (ReorderedListFunction reorderedListFunction) {
                    setState(() {
                      children = reorderedListFunction(children) as List<int>;
                    });
                  },
                  reverse: true,
                  itemCount: children.length,
                  childBuilder: (itemBuilder) {
                    return GridView.builder(
                      key: _gridViewKey,
                      reverse: true,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: children.length,
                      itemBuilder: (context, index) {
                        return itemBuilder(
                          ColoredBox(
                            key: Key(children.elementAt(index).toString()),
                            color: Colors.lightBlue,
                            child: Text(
                              children.elementAt(index).toString(),
                            ),
                          ),
                          index,
                        );
                      },
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 8,
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
