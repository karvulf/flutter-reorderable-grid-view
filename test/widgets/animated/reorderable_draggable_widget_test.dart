import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_reorderable_grid_view/widgets/animated/reorderable_draggable.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const givenChild = Text('hallo');
  const givenReorderableEntity = ReorderableEntity(
    child: givenChild,
    originalOrderId: 0,
    updatedOrderId: 0,
    isBuilding: false,
  );

  Future<void> pumpWidget(
    WidgetTester tester, {
    required bool enableDraggable,
    required bool enableLongPress,
    OnCreatedFunction? onCreated,
    OnCreatedFunction? onBuilding,
    Function(ReorderableEntity reorderableEntity)? onDragStarted,
    OnDragUpdateFunction? onDragUpdate,
    DragEndCallback? onDragEnd,
  }) =>
      tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableDraggable(
              reorderableEntity: givenReorderableEntity,
              enableDraggable: enableDraggable,
              enableLongPress: enableLongPress,
              longPressDelay: kLongPressTimeout,
              draggedReorderableEntity: null,
              onCreated: onCreated ??
                  (_, __) {
                    return null;
                  },
              onDragUpdate: onDragUpdate ?? (_) {},
              onBuilding: onBuilding ??
                  (_, __) {
                    return null;
                  },
              onDragEnd: onDragEnd ?? (_) {},
              onDragStarted: onDragStarted ?? (_) {},
              dragChildBoxDecoration: const BoxDecoration(
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.red,
                    spreadRadius: 5,
                    blurRadius: 6,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  testWidgets(
      'GIVEN enableDraggable = false '
      'WHEN pumping [ReorderableDraggable] '
      'THEN should not show any Draggable widgets',
      (WidgetTester tester) async {
    // given

    // when
    await pumpWidget(
      tester,
      enableDraggable: false,
      enableLongPress: true,
    );

    // then
    expect(find.byWidget(givenChild), findsOneWidget);
    expect(find.byType(Draggable), findsNothing);
    expect(find.byType(LongPressDraggable), findsNothing);
  });

  testWidgets(
      'GIVEN enableDraggable = true and enableLongPress = true '
      'WHEN pumping [ReorderableDraggable] '
      'THEN should show [LongPressDraggable]', (WidgetTester tester) async {
    // given

    // when
    await pumpWidget(
      tester,
      enableDraggable: true,
      enableLongPress: true,
    );

    // then
    expect(find.byWidget(givenChild), findsOneWidget);
    expect(find.byType(Draggable), findsNothing);
    expect(find.byType(LongPressDraggable), findsOneWidget);
  });

  testWidgets(
      'GIVEN enableDraggable = true and enableLongPress = false '
      'WHEN pumping [ReorderableDraggable] '
      'THEN should show [Draggable]', (WidgetTester tester) async {
    // given

    // when
    await pumpWidget(
      tester,
      enableDraggable: true,
      enableLongPress: false,
    );

    // then
    expect(find.byWidget(givenChild), findsOneWidget);
    expect(find.byType(Draggable), findsOneWidget);
    expect(find.byType(LongPressDraggable), findsNothing);
  });

  testWidgets(
      'GIVEN [ReorderableDraggable] '
      'WHEN built '
      'THEN should call #onCreated', (WidgetTester tester) async {
    // given
    late final ReorderableEntity actualReorderableEntity;
    late final GlobalKey actualKey;

    // when
    await pumpWidget(
      tester,
      enableDraggable: true,
      enableLongPress: false,
      onCreated: (
        ReorderableEntity reorderableEntity,
        GlobalKey key,
      ) {
        actualReorderableEntity = reorderableEntity;
        actualKey = key;
        return reorderableEntity;
      },
    );

    // then
    expect(actualReorderableEntity, equals(givenReorderableEntity));
    expect(actualKey, isNotNull);
  });

  testWidgets(
      'GIVEN [ReorderableDraggable] '
      'WHEN updating reorderableEntity '
      'THEN should call #onBuilding', (WidgetTester tester) async {
    // given
    final givenUpdatedReorderableEntity = givenReorderableEntity.copyWith(
      isBuilding: true,
    );
    late final ReorderableEntity actualReorderableEntity;
    late final GlobalKey actualKey;

    await tester.pumpWidget(
      MaterialApp(
        home: _UpdateReorderableEntityTest(
          reorderableEntity: givenReorderableEntity,
          updatedReorderableEntity: givenUpdatedReorderableEntity,
          enableDraggable: true,
          enableLongPress: false,
          onBuilding: (
            ReorderableEntity reorderableEntity,
            GlobalKey key,
          ) {
            actualReorderableEntity = reorderableEntity;
            actualKey = key;
            return reorderableEntity;
          },
        ),
      ),
    );

    // when
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    // then
    expect(actualReorderableEntity, equals(givenUpdatedReorderableEntity));
    expect(actualKey, isNotNull);
  });

  testWidgets(
      'GIVEN [ReorderableDraggable] '
      'WHEN start dragging '
      'THEN should call #onStartDragging', (WidgetTester tester) async {
    // given
    late final ReorderableEntity actualReorderableEntity;

    await pumpWidget(
      tester,
      enableDraggable: true,
      enableLongPress: false,
      onDragStarted: (ReorderableEntity reorderableEntity) {
        actualReorderableEntity = reorderableEntity;
      },
    );

    // when
    final firstLocation = tester.getCenter(find.byWidget(givenChild));
    await tester.startGesture(firstLocation, pointer: 7);
    await tester.pump(kLongPressTimeout);

    // then
    expect(actualReorderableEntity, equals(givenReorderableEntity));
  });

  testWidgets(
      'GIVEN [ReorderableDraggable] '
      'WHEN moving while dragging '
      'THEN should call #onDragUpdated', (WidgetTester tester) async {
    // given
    late final DragUpdateDetails actualDetails;

    await pumpWidget(
      tester,
      enableDraggable: true,
      enableLongPress: false,
      onDragUpdate: (DragUpdateDetails details) {
        actualDetails = details;
      },
    );

    final firstLocation = tester.getCenter(find.byWidget(givenChild));
    final gesture = await tester.startGesture(firstLocation, pointer: 7);
    await tester.pump(kLongPressTimeout);

    // when
    await gesture.moveTo(const Offset(10, 10));
    await tester.pump();

    // then
    expect(actualDetails, isNotNull);
  });

  testWidgets(
      'GIVEN [ReorderableDraggable] '
      'WHEN release dragging '
      'THEN should call #onDragEnd', (WidgetTester tester) async {
    // given
    late final DraggableDetails actualDetails;

    await pumpWidget(
      tester,
      enableDraggable: true,
      enableLongPress: false,
      onDragEnd: (DraggableDetails details) {
        actualDetails = details;
      },
    );

    final firstLocation = tester.getCenter(find.byWidget(givenChild));
    final gesture = await tester.startGesture(firstLocation, pointer: 7);
    await tester.pump(kLongPressTimeout);

    await gesture.moveTo(const Offset(10, 10));
    await tester.pump();

    // when
    await gesture.up();

    // then
    expect(actualDetails, isNotNull);
  });
}

class _UpdateReorderableEntityTest extends StatefulWidget {
  final ReorderableEntity reorderableEntity;
  final ReorderableEntity updatedReorderableEntity;
  final bool enableDraggable;
  final bool enableLongPress;
  final OnCreatedFunction onBuilding;

  const _UpdateReorderableEntityTest({
    required this.reorderableEntity,
    required this.updatedReorderableEntity,
    required this.enableDraggable,
    required this.enableLongPress,
    required this.onBuilding,
    Key? key,
  }) : super(key: key);

  @override
  _UpdateReorderableEntityTestState createState() =>
      _UpdateReorderableEntityTestState();
}

class _UpdateReorderableEntityTestState
    extends State<_UpdateReorderableEntityTest> {
  late ReorderableEntity reorderableEntity;

  @override
  void initState() {
    super.initState();

    reorderableEntity = widget.reorderableEntity;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextButton(
            onPressed: () {
              setState(() {
                reorderableEntity = widget.updatedReorderableEntity;
              });
            },
            child: const Text('update'),
          ),
          ReorderableDraggable(
            reorderableEntity: reorderableEntity,
            enableDraggable: widget.enableDraggable,
            enableLongPress: widget.enableLongPress,
            longPressDelay: kLongPressTimeout,
            draggedReorderableEntity: null,
            onCreated: (_, __) {
              return null;
            },
            onDragUpdate: (_) {},
            onBuilding: widget.onBuilding,
            onDragEnd: (_) {},
            onDragStarted: (_) {},
            dragChildBoxDecoration: null,
          ),
        ],
      ),
    );
  }
}
