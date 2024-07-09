import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_scrolling_listener.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const givenScrollOffset = Offset(12.0, 34.0);
  final givenKey = GlobalKey();
  const givenScrollExtent = 52.12;
  final givenScrollController = ScrollController();

  Future<void> pumpWidget(
    WidgetTester tester, {
    ScrollController? scrollController,
    bool enableScrollingWhileDragging = false,
    bool isDragging = false,
    GlobalKey? reorderableChildKey,
    PointerMoveEventListener? onDragUpdate,
    void Function(Offset scrollOffset)? onScrollUpdate,
  }) async =>
      tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableScrollingListener(
              getScrollOffset: () => givenScrollOffset,
              scrollController: scrollController,
              automaticScrollExtent: givenScrollExtent,
              enableScrollingWhileDragging: enableScrollingWhileDragging,
              isDragging: isDragging,
              reorderableChildKey: reorderableChildKey,
              onDragUpdate: onDragUpdate ?? (_) {},
              onScrollUpdate: onScrollUpdate ?? (_) {},
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

  Future<void> move({
    required WidgetTester tester,
    Offset moveOffset = const Offset(20.0, 30.0),
    Offset? startGestureLocation,
  }) async {
    final Offset center = tester.getCenter(find.byKey(givenKey));
    final gesture = await tester.startGesture(startGestureLocation ?? center);
    await gesture.moveBy(moveOffset);
    await gesture.up();
    await tester.pumpAndSettle();
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
        find.byWidgetPredicate((widget) =>
            widget is Listener &&
            widget.behavior == HitTestBehavior.deferToChild &&
            widget.onPointerMove != null),
        findsOneWidget);
  });

  group('#onPointerMove but scrolling disabled', () {
    var dragUpdateCallCounter = 0;
    var scrollUpdateCallCounter = 0;

    tearDown(() {
      dragUpdateCallCounter = 0;
      scrollUpdateCallCounter = 0;
    });

    testWidgets(
        "GIVEN [ReorderableScrollingListener] and isDragging = false "
        "WHEN moving pointer "
        "THEN should do nothing", (WidgetTester tester) async {
      // given
      await pumpWidget(
        tester,
        isDragging: false,
        onDragUpdate: (_) {
          dragUpdateCallCounter++;
        },
        onScrollUpdate: (_) {
          scrollUpdateCallCounter++;
        },
      );

      // when
      await move(tester: tester);

      // then
      expect(dragUpdateCallCounter, equals(0));
      expect(scrollUpdateCallCounter, equals(0));
    });

    testWidgets(
        "GIVEN [ReorderableScrollingListener], isDragging = true "
        "and enableScrollingWhileDragging = false"
        "WHEN moving pointer "
        "THEN should only call onDragUpdate", (WidgetTester tester) async {
      // given
      await pumpWidget(
        tester,
        isDragging: true,
        enableScrollingWhileDragging: false,
        onDragUpdate: (_) {
          dragUpdateCallCounter++;
        },
        onScrollUpdate: (_) {
          scrollUpdateCallCounter++;
        },
      );

      // when
      await move(tester: tester);

      // then
      expect(dragUpdateCallCounter, equals(1));
      expect(scrollUpdateCallCounter, equals(0));
    });

    testWidgets(
        "GIVEN [ReorderableScrollingListener], isDragging = true "
        "and enableScrollingWhileDragging = true, reorderableChildKey == null "
        "WHEN moving pointer "
        "THEN should only call onDragUpdate", (WidgetTester tester) async {
      // given
      await pumpWidget(
        tester,
        isDragging: true,
        enableScrollingWhileDragging: true,
        reorderableChildKey: null,
        onDragUpdate: (_) {
          dragUpdateCallCounter++;
        },
        onScrollUpdate: (_) {
          scrollUpdateCallCounter++;
        },
      );

      // when
      await move(tester: tester);

      // then
      expect(dragUpdateCallCounter, equals(1));
      expect(scrollUpdateCallCounter, equals(0));
    });

    testWidgets(
        "GIVEN [ReorderableScrollingListener], isDragging = true, "
        "enableScrollingWhileDragging = true, reorderableChildKey != null but "
        "size and offset is unknown "
        "WHEN moving pointer "
        "THEN should only call onDragUpdate", (WidgetTester tester) async {
      // given
      await pumpWidget(
        tester,
        isDragging: true,
        enableScrollingWhileDragging: true,
        reorderableChildKey: givenKey,
        onDragUpdate: (_) {
          dragUpdateCallCounter++;
        },
        onScrollUpdate: (_) {
          scrollUpdateCallCounter++;
        },
      );

      // when
      await move(tester: tester);

      // then
      expect(dragUpdateCallCounter, equals(1));
      expect(scrollUpdateCallCounter, equals(0));
    });
  });

  group('#onPointerMove and scrolling enabled', () {
    group('ScrollDirection = .vertical', () {
      testWidgets(
          "GIVEN - "
          "WHEN dragging to bottom "
          "THEN should call onDragUpdate", (WidgetTester tester) async {
        // given
        late Offset actualScrollValue;
        await tester.pumpWidget(
          MaterialApp(
            home: _UpdateReorderableScrollingListener(
              scrollDirection: Axis.vertical,
              isDragging: false,
              enableScrollingWhileDragging: true,
              scrollController: givenScrollController,
              reorderableContentKey: givenKey,
              onScrollUpdate: (value) {
                actualScrollValue = value;
              },
            ),
          ),
        );

        // when
        // isDragging to true to trigger calculation of size and offset
        await tester.tap(find.byType(TextButton));
        await tester.pumpAndSettle();
        await move(
          tester: tester,
          moveOffset: const Offset(20, 295),
        );

        await tester.tap(find.byType(TextButton));
        await tester.pumpAndSettle();

        // then
        expect(actualScrollValue.dy > 0.0, isTrue);
      });

      testWidgets(
          "GIVEN dragged to bottom "
          "WHEN dragging to top "
          "THEN should call onDragUpdate", (WidgetTester tester) async {
        // given
        late Offset actualScrollValue;
        await tester.pumpWidget(
          MaterialApp(
            home: _UpdateReorderableScrollingListener(
              scrollDirection: Axis.vertical,
              isDragging: false,
              enableScrollingWhileDragging: true,
              scrollController: givenScrollController,
              reorderableContentKey: givenKey,
              onScrollUpdate: (value) {
                actualScrollValue = value;
              },
            ),
          ),
        );

        // isDragging to true to trigger calculation of size and offset
        await tester.tap(find.byType(TextButton));
        await tester.pumpAndSettle();
        await move(
          tester: tester,
          moveOffset: const Offset(0, 200),
        );
        final actualBeforeScrollValue = actualScrollValue;

        // when
        await move(
          tester: tester,
          startGestureLocation: const Offset(20, 295),
          moveOffset: -const Offset(0, 200),
        );
        // by tapping the text button, isDragging is set to false
        await tester.tap(find.byType(TextButton));
        await tester.pumpAndSettle();

        // then
        expect(actualScrollValue.dy < actualBeforeScrollValue.dy, isTrue);
      });
    });

    group('ScrollDirection = .horizontal', () {
      testWidgets(
          "GIVEN - "
          "WHEN dragging to the right "
          "THEN should call onDragUpdate", (WidgetTester tester) async {
        // given
        late Offset actualScrollValue;
        await tester.pumpWidget(
          MaterialApp(
            home: _UpdateReorderableScrollingListener(
              scrollDirection: Axis.horizontal,
              isDragging: false,
              enableScrollingWhileDragging: true,
              scrollController: givenScrollController,
              reorderableContentKey: givenKey,
              onScrollUpdate: (value) {
                actualScrollValue = value;
              },
            ),
          ),
        );
        const givenMoveOffset = Offset(295.0, 0.0);

        // when
        // isDragging to true to trigger calculation of size and offset
        await tester.tap(find.byType(TextButton));
        await tester.pumpAndSettle();
        await move(
          tester: tester,
          moveOffset: givenMoveOffset,
        );

        await tester.tap(find.byType(TextButton));
        await tester.pumpAndSettle();

        // then
        expect(actualScrollValue.dx > givenMoveOffset.dx, isTrue);
      });
    });

    group('Scrollable widget is outside ReorderableScrollingListener', () {
      testWidgets(
          "GIVEN - "
          "WHEN dragging to bottom "
          "THEN should call onDragUpdate", (WidgetTester tester) async {
        // given
        late Offset actualScrollValue;
        await tester.pumpWidget(
          MaterialApp(
            home: _UpdateReorderableOutsideScrollingListener(
              isDragging: false,
              scrollController: givenScrollController,
              reorderableContentKey: givenKey,
              onScrollUpdate: (value) {
                actualScrollValue = value;
              },
            ),
          ),
        );

        // when
        // isDragging to true to trigger calculation of size and offset
        await tester.tap(find.byType(TextButton));
        await tester.pumpAndSettle();
        await move(
          tester: tester,
          moveOffset: const Offset(20, 295),
          startGestureLocation: const Offset(50.0, 350.0),
        );

        await tester.tap(find.byType(TextButton));
        await tester.pumpAndSettle();

        // then
        expect(actualScrollValue.dy > 0.0, isTrue);
      });
    });
  });
}

class _UpdateReorderableScrollingListener extends StatefulWidget {
  final bool isDragging;
  final bool enableScrollingWhileDragging;
  final Axis scrollDirection;
  final ScrollController? scrollController;
  final Function(Offset scrollValue)? onScrollUpdate;
  final GlobalKey? reorderableContentKey;

  const _UpdateReorderableScrollingListener({
    required this.isDragging,
    required this.scrollDirection,
    this.enableScrollingWhileDragging = true,
    this.scrollController,
    this.onScrollUpdate,
    this.reorderableContentKey,
    Key? key,
  }) : super(key: key);

  @override
  State<_UpdateReorderableScrollingListener> createState() =>
      _UpdateReorderableScrollingListenerState();
}

class _UpdateReorderableScrollingListenerState
    extends State<_UpdateReorderableScrollingListener> {
  late bool isDragging;

  @override
  void initState() {
    super.initState();

    isDragging = widget.isDragging;
  }

  @override
  Widget build(BuildContext context) {
    final isVerticalDirection = widget.scrollDirection == Axis.vertical;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Updates'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                isDragging = !isDragging;
              });
            },
            child: const Text('update isDragging'),
          ),
        ],
      ),
      body: ReorderableScrollingListener(
        getScrollOffset: () => const Offset(12.0, 13.0),
        enableScrollingWhileDragging: widget.enableScrollingWhileDragging,
        scrollController: widget.scrollController,
        isDragging: isDragging,
        onDragUpdate: (_) {},
        automaticScrollExtent: 80.0,
        onScrollUpdate: widget.onScrollUpdate ?? (_) {},
        reorderableChildKey: widget.reorderableContentKey ?? GlobalKey(),
        child: SizedBox.square(
          key: widget.reorderableContentKey ?? GlobalKey(),
          dimension: 300.0,
          child: SingleChildScrollView(
            controller: widget.scrollController,
            scrollDirection: widget.scrollDirection,
            child: Container(
              color: Colors.red,
              height: isVerticalDirection ? 2000 : 100,
              width: isVerticalDirection ? 100 : 2000,
            ),
          ),
        ),
      ),
    );
  }
}

class _UpdateReorderableOutsideScrollingListener extends StatefulWidget {
  final bool isDragging;
  final ScrollController scrollController;
  final Function(Offset scrollValue) onScrollUpdate;
  final GlobalKey reorderableContentKey;

  const _UpdateReorderableOutsideScrollingListener({
    required this.isDragging,
    required this.scrollController,
    required this.onScrollUpdate,
    required this.reorderableContentKey,
    Key? key,
  }) : super(key: key);

  @override
  State<_UpdateReorderableOutsideScrollingListener> createState() =>
      _UpdateReorderableOutsideScrollingListenerState();
}

class _UpdateReorderableOutsideScrollingListenerState
    extends State<_UpdateReorderableOutsideScrollingListener> {
  late bool isDragging;

  @override
  void initState() {
    super.initState();

    isDragging = widget.isDragging;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Updates'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                isDragging = !isDragging;
              });
            },
            child: const Text('update isDragging'),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 100,
            width: 100,
            color: Colors.red,
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              child: ReorderableScrollingListener(
                getScrollOffset: () => const Offset(12.0, 13.0),
                enableScrollingWhileDragging: true,
                scrollController: widget.scrollController,
                isDragging: isDragging,
                onDragUpdate: (_) {},
                automaticScrollExtent: 80.0,
                onScrollUpdate: widget.onScrollUpdate,
                reorderableChildKey: widget.reorderableContentKey,
                child: Container(
                  key: widget.reorderableContentKey,
                  color: Colors.red,
                  height: 2000,
                  width: 400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
