import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_scrolling_listener.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final givenScrollableContentKey = GlobalKey();

  Future<void> pumpWidget(
    WidgetTester tester, {
    required bool isDragging,
    required GlobalKey scrollableContentKey,
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
            scrollController: scrollController,
            isDragging: isDragging,
            onDragUpdate: onDragUpdate ?? (_) {},
            automaticScrollExtent: automaticScrollExtent,
            onScrollUpdate: onScrollUpdate ?? (_) {},
            scrollableContentKey: scrollableContentKey,
            child: SizedBox(
              key: givenScrollableContentKey,
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
      scrollableContentKey: givenScrollableContentKey,
    );

    // then
    expect(
        find.byWidgetPredicate((widget) =>
            widget is Listener &&
            widget.child?.key == givenScrollableContentKey),
        findsOneWidget);
    expect(find.byKey(givenScrollableContentKey), findsOneWidget);
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
      scrollableContentKey: givenScrollableContentKey,
      onDragUpdate: (_) {
        actualDragUpdateCallCounter++;
      },
      onDragEnd: () {
        actualDragEndCallCounter++;
      },
    );

    // when
    const moved = Offset(20, 30);
    final center = tester.getCenter(find.byKey(givenScrollableContentKey));
    final TestGesture gesture = await tester.startGesture(center);
    await gesture.moveBy(moved);
    await gesture.up();

    // then
    expect(actualDragUpdateCallCounter, equals(1));
    expect(actualDragEndCallCounter, equals(1));
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
          scrollableContentKey: givenScrollableContentKey,
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
    final center = tester.getCenter(find.byKey(givenScrollableContentKey));
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
          scrollableContentKey: givenScrollableContentKey,
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
    final center = tester.getCenter(find.byKey(givenScrollableContentKey));
    final TestGesture gestureBottom = await tester.startGesture(center);
    await gestureBottom.moveBy(moved);
    await tester.pump();
    await gestureBottom.up();
    await tester.pumpAndSettle();
    final actualScrollValueBeforeScrollingToTop = actualScrollValue;

    // when
    final top = tester.getTopLeft(find.byKey(givenScrollableContentKey));
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
}

class _UpdateReorderableScrollingListener extends StatefulWidget {
  final bool isDragging;
  final ScrollController? scrollController;
  final Function(double scrollValue)? onScrollUpdate;
  final GlobalKey? scrollableContentKey;

  const _UpdateReorderableScrollingListener({
    required this.isDragging,
    this.scrollController,
    this.onScrollUpdate,
    this.scrollableContentKey,
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
        scrollController: widget.scrollController,
        isDragging: isDragging,
        onDragUpdate: (_) {},
        automaticScrollExtent: 80.0,
        onScrollUpdate: widget.onScrollUpdate ?? (_) {},
        scrollableContentKey: widget.scrollableContentKey ?? GlobalKey(),
        child: SizedBox(
          key: widget.scrollableContentKey ?? GlobalKey(),
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
