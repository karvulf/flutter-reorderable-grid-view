import 'package:flutter/material.dart';
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

  // todo add new tests
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
        enableScrollingWhileDragging: widget.enableScrollingWhileDragging,
        scrollController: widget.scrollController,
        isDragging: isDragging,
        onDragUpdate: (_) {},
        automaticScrollExtent: 80.0,
        reverse: false,
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
  final GlobalKey reorderableContentKey;

  const _UpdateReorderableOutsideScrollingListener({
    required this.isDragging,
    required this.scrollController,
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
                enableScrollingWhileDragging: true,
                scrollController: widget.scrollController,
                isDragging: isDragging,
                onDragUpdate: (_) {},
                automaticScrollExtent: 80.0,
                reverse: false,
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
