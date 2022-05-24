import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_scrolling_listener.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final givenreorderableContentKey = GlobalKey();

  Future<void> pumpWidget(
    WidgetTester tester, {
    required bool isDragging,
    required GlobalKey reorderableContentKey,
    bool enableScrollingWhileDragging = true,
    double automaticScrollExtent = 50.0,
    VoidCallback? onDragEnd,
    ScrollController? scrollController,
    PointerMoveEventListener? onDragUpdate,
    Function(double scroll)? onScrollUpdate,
  }) =>
      tester.pumpWidget(
        MaterialApp(
          home: ReorderableScrollingListener(
            onDragEnd: onDragEnd ?? () {},
            enableScrollingWhileDragging: enableScrollingWhileDragging,
            scrollController: scrollController,
            isDragging: isDragging,
            onDragUpdate: onDragUpdate ?? (_) {},
            automaticScrollExtent: automaticScrollExtent,
            onScrollUpdate: onScrollUpdate ?? (_) {},
            reorderableChildKey: reorderableContentKey,
            child: SizedBox(
              key: givenreorderableContentKey,
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
      );

  testWidgets(
      'GIVEN - '
      'WHEN pumping [ReorderableScrollingListener] '
      'THEN should show expected widgets', (WidgetTester tester) async {
    // given

    // when
    await pumpWidget(
      tester,
      isDragging: false,
      reorderableContentKey: givenreorderableContentKey,
    );

    // then
    expect(
        find.byWidgetPredicate((widget) =>
            widget is Listener &&
            widget.child?.key == givenreorderableContentKey),
        findsOneWidget);
    expect(find.byKey(givenreorderableContentKey), findsOneWidget);
  });

  testWidgets(
      'GIVEN [ReorderableScrollingListener], isDragging = true, onDragUpdate and onDragEnd '
      'but scrolling not working because scrollController is null '
      'WHEN moving and releasing the pointer '
      'THEN should call given functions', (WidgetTester tester) async {
    // given
    var actualDragUpdateCallCounter = 0;
    var actualDragEndCallCounter = 0;
    await pumpWidget(
      tester,
      isDragging: true,
      reorderableContentKey: givenreorderableContentKey,
      onDragUpdate: (_) {
        actualDragUpdateCallCounter++;
      },
      onDragEnd: () {
        actualDragEndCallCounter++;
      },
    );

    // when
    const moved = Offset(20, 30);
    final center = tester.getCenter(find.byKey(givenreorderableContentKey));
    final TestGesture gesture = await tester.startGesture(center);
    await gesture.moveBy(moved);
    await gesture.up();

    // then
    expect(actualDragUpdateCallCounter, equals(1));
    expect(actualDragEndCallCounter, equals(1));
  });

  testWidgets(
      'GIVEN [ReorderableScrollingListener], isDragging = true, scrollController, '
      'onScrollUpdate and enableScrollingWhileDragging = false '
      'WHEN moving to bottom and changing isDragging to false '
      'THEN should not scroll automatic to bottom and not call onScrollUpdate',
      (WidgetTester tester) async {
    // given
    final scrollController = ScrollController();
    double? actualScrollValue;
    await tester.pumpWidget(
      MaterialApp(
        home: _UpdateReorderableScrollingListener(
          isDragging: false,
          enableScrollingWhileDragging: false,
          // will be true in when part trigger calculations of size and offset
          scrollController: scrollController,
          reorderableContentKey: givenreorderableContentKey,
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

    const moved = Offset(20, 295);
    final center = tester.getCenter(find.byKey(givenreorderableContentKey));
    final TestGesture gesture = await tester.startGesture(center);
    await gesture.moveBy(moved);
    await gesture.up();
    await tester.pumpAndSettle();

    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    // then
    expect(actualScrollValue, isNull);
  });

  testWidgets(
      'GIVEN [ReorderableScrollingListener], isDragging = true, scrollController and '
      'onScrollUpdate '
      'WHEN moving to bottom and changing isDragging to false '
      'THEN should scroll automatic to bottom and call onScrollUpdate',
      (WidgetTester tester) async {
    // given
    final scrollController = ScrollController();
    late double actualScrollValue;
    await tester.pumpWidget(
      MaterialApp(
        home: _UpdateReorderableScrollingListener(
          isDragging: false,
          // will be true in when part trigger calculations of size and offset
          scrollController: scrollController,
          reorderableContentKey: givenreorderableContentKey,
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

    const moved = Offset(20, 295);
    final center = tester.getCenter(find.byKey(givenreorderableContentKey));
    final TestGesture gesture = await tester.startGesture(center);
    await gesture.moveBy(moved);
    await gesture.up();
    await tester.pumpAndSettle();

    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    // then
    expect(actualScrollValue > 0, isTrue);
  });

  testWidgets(
      'GIVEN [ReorderableScrollingListener], isDragging = true, scrollController, '
      'onScrollUpdate and widget scrolled down '
      'WHEN moving to top and changing isDragging to false '
      'THEN should scroll automatic to top and call onScrollUpdate',
      (WidgetTester tester) async {
    // given
    final scrollController = ScrollController();
    late double actualScrollValue;
    await tester.pumpWidget(
      MaterialApp(
        home: _UpdateReorderableScrollingListener(
          isDragging: false,
          // will be true in when part trigger calculations of size and offset
          scrollController: scrollController,
          reorderableContentKey: givenreorderableContentKey,
          onScrollUpdate: (value) {
            actualScrollValue = value;
          },
        ),
      ),
    );

    // isDragging to true to trigger calculation of size and offset
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    const moved = Offset(20, 295);
    final center = tester.getCenter(find.byKey(givenreorderableContentKey));
    final TestGesture gestureBottom = await tester.startGesture(center);
    await gestureBottom.moveBy(moved);
    await tester.pump();
    await gestureBottom.up();
    await tester.pumpAndSettle();
    final actualScrollValueBeforeScrollingToTop = actualScrollValue;

    // when
    final top = tester.getTopLeft(find.byKey(givenreorderableContentKey));
    final TestGesture gestureTop = await tester.startGesture(top);
    await gestureTop.moveBy(Offset.zero);
    await tester.pump();
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    await gestureTop.up();
    await tester.pumpAndSettle();

    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    // then
    expect(actualScrollValue < actualScrollValueBeforeScrollingToTop, isTrue);
  });

  group('#Scrolling with widget that is outside ReorderableSCrollingListener',
      () {
    testWidgets(
        'GIVEN [ReorderableScrollingListener], isDragging = true, scrollController and '
        'onScrollUpdate '
        'WHEN moving to bottom and changing isDragging to false '
        'THEN should scroll automatic to bottom and call onScrollUpdate',
        (WidgetTester tester) async {
      // given
      final scrollController = ScrollController();
      late double actualScrollValue;
      await tester.pumpWidget(
        MaterialApp(
          home: _UpdateReorderableOutsideScrollingListener(
            isDragging: false,
            // will be true in when part trigger calculations of size and offset
            scrollController: scrollController,
            reorderableContentKey: givenreorderableContentKey,
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

      final topLeft =
          tester.getTopLeft(find.byType(ReorderableScrollingListener));
      final TestGesture gesture = await tester.startGesture(topLeft);
      final bottom = tester.getBottomRight(find.byType(Scaffold));
      await gesture.moveBy(bottom);
      await gesture.up();
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      // then
      expect(actualScrollValue > 0, isTrue);
    });

    testWidgets(
        'GIVEN [ReorderableScrollingListener], isDragging = true, scrollController, '
        'onScrollUpdate and widget scrolled down '
        'WHEN moving to top and changing isDragging to false '
        'THEN should scroll automatic to top and call onScrollUpdate',
        (WidgetTester tester) async {
      // given
      final scrollController = ScrollController();
      late double actualScrollValue;
      await tester.pumpWidget(
        MaterialApp(
          home: _UpdateReorderableOutsideScrollingListener(
            isDragging: false,
            // will be true in when part trigger calculations of size and offset
            scrollController: scrollController,
            reorderableContentKey: givenreorderableContentKey,
            onScrollUpdate: (value) {
              actualScrollValue = value;
            },
          ),
        ),
      );

      // isDragging to true to trigger calculation of size and offset
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      final topLeft =
          tester.getTopLeft(find.byType(ReorderableScrollingListener));
      final TestGesture gestureBottom = await tester.startGesture(topLeft);
      final bottom = tester.getBottomRight(find.byType(Scaffold));
      await gestureBottom.moveBy(bottom);
      await tester.pump();
      await gestureBottom.up();
      await tester.pumpAndSettle();
      final actualScrollValueBeforeScrollingToTop = actualScrollValue;

      // when
      final TestGesture gestureTop = await tester.startGesture(topLeft);
      await gestureTop.moveBy(const Offset(0.0, -100.0));
      await tester.pump();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await gestureTop.up();
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      // then
      expect(actualScrollValue < actualScrollValueBeforeScrollingToTop, isTrue);
    });
  });
}

class _UpdateReorderableScrollingListener extends StatefulWidget {
  final bool isDragging;
  final bool enableScrollingWhileDragging;
  final ScrollController? scrollController;
  final Function(double scrollValue)? onScrollUpdate;
  final GlobalKey? reorderableContentKey;

  const _UpdateReorderableScrollingListener({
    required this.isDragging,
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
        onDragEnd: () {},
        enableScrollingWhileDragging: widget.enableScrollingWhileDragging,
        scrollController: widget.scrollController,
        isDragging: isDragging,
        onDragUpdate: (_) {},
        automaticScrollExtent: 80.0,
        onScrollUpdate: widget.onScrollUpdate ?? (_) {},
        reorderableChildKey: widget.reorderableContentKey ?? GlobalKey(),
        child: SizedBox(
          key: widget.reorderableContentKey ?? GlobalKey(),
          height: 300,
          child: SingleChildScrollView(
            controller: widget.scrollController,
            child: Container(
              color: Colors.red,
              height: 2000,
              width: 100,
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
  final Function(double scrollValue) onScrollUpdate;
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
                onDragEnd: () {},
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
