import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_type.dart';
import 'package:flutter_reorderable_grid_view/flutter_reorderable_grid_view.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('#ReorderableGridView', () {
    testWidgets(
        'GIVEN children and gridDelegate '
        'WHEN pumping [ReorderableGridView] '
        'THEN should show widget with expected default values',
        (WidgetTester tester) async {
      // given
      const givenChildren = <Widget>[
        Text('hallo'),
      ];
      const givenGridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
      );

      // when
      await tester.pumpWidget(
        MaterialApp(
          home: ReorderableGridView(
            children: givenChildren,
            onReorder: (_, __) {},
            gridDelegate: givenGridDelegate,
          ),
        ),
      );

      // then
      expect(
          find.byWidgetPredicate((widget) => hasReorderableExpectedValues(
              widget,
              reorderableType: ReorderableType.gridView,
              gridDelegate: givenGridDelegate,
              children: givenChildren)),
          findsOneWidget);
    });

    testWidgets(
        'GIVEN children, gridDelegate and lockedChildren '
        'WHEN pumping [ReorderableGridView] '
        'THEN should show widget with given values',
        (WidgetTester tester) async {
      // given
      const givenChildren = <Widget>[
        Text('hallo'),
      ];
      const givenGridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
      );

      const givenLockedChildren = [0, 1, 2];
      const givenEnableAnimation = false;
      const givenEnableLongPress = false;
      const givenLongPressDelay = Duration(days: 100);
      const givenPadding = EdgeInsets.all(20);
      const givenClip = Clip.antiAlias;
      const givenPhysics = NeverScrollableScrollPhysics();
      const givenDragChildBoxDecoration = BoxDecoration(color: Colors.orange);

      // when
      await tester.pumpWidget(
        MaterialApp(
          home: ReorderableGridView(
            children: givenChildren,
            onReorder: (_, __) {},
            gridDelegate: givenGridDelegate,
            lockedChildren: givenLockedChildren,
            enableLongPress: givenEnableLongPress,
            enableAnimation: givenEnableAnimation,
            longPressDelay: givenLongPressDelay,
            physics: givenPhysics,
            padding: givenPadding,
            clipBehavior: givenClip,
            dragChildBoxDecoration: givenDragChildBoxDecoration,
          ),
        ),
      );

      // then
      expect(
          find.byWidgetPredicate((widget) => hasReorderableExpectedValues(
                widget,
                reorderableType: ReorderableType.gridView,
                gridDelegate: givenGridDelegate,
                children: givenChildren,
                lockedChildren: givenLockedChildren,
                enableAnimation: givenEnableAnimation,
                enableLongPress: givenEnableLongPress,
                longPressDelay: givenLongPressDelay,
                padding: givenPadding,
                clipBehavior: givenClip,
                physics: givenPhysics,
                dragChildBoxDecoration: givenDragChildBoxDecoration,
              )),
          findsOneWidget);
    });
  });

  group('#ReorderableGridView.count', () {
    testWidgets(
        'GIVEN children '
        'WHEN pumping [ReorderableGridView.count] '
        'THEN should show widget with expected default values',
        (WidgetTester tester) async {
      // given
      const givenChildren = <Widget>[
        Text('hallo'),
      ];
      const givenCrossAxisCount = 5;

      // when
      await tester.pumpWidget(
        MaterialApp(
          home: ReorderableGridView.count(
            children: givenChildren,
            onReorder: (_, __) {},
            crossAxisCount: givenCrossAxisCount,
          ),
        ),
      );

      // then
      expect(
          find.byWidgetPredicate((widget) => hasReorderableExpectedValues(
              widget,
              reorderableType: ReorderableType.gridViewCount,
              crossAxisCount: givenCrossAxisCount,
              children: givenChildren)),
          findsOneWidget);
    });

    testWidgets(
        'GIVEN children '
        'WHEN pumping [ReorderableGridView.count] '
        'THEN should show widget with given values',
        (WidgetTester tester) async {
      // given
      const givenChildren = <Widget>[
        Text('hallo'),
      ];
      const givenCrossAxisCount = 5;
      const givenMainAxisSpacing = 10.0;
      const givenEnableAnimation = false;
      const givenEnableLongPress = false;
      const givenLongPressDelay = Duration(days: 100);
      const givenLockedChildren = [10, 20];
      const givenPadding = EdgeInsets.all(30);
      const givenClipBehavior = Clip.antiAliasWithSaveLayer;
      const givenPhysics = NeverScrollableScrollPhysics();
      const givenDragChildBoxDecoration = BoxDecoration(color: Colors.orange);

      // when
      await tester.pumpWidget(
        MaterialApp(
          home: ReorderableGridView.count(
            children: givenChildren,
            onReorder: (_, __) {},
            crossAxisCount: givenCrossAxisCount,
            mainAxisSpacing: givenMainAxisSpacing,
            longPressDelay: givenLongPressDelay,
            enableLongPress: givenEnableLongPress,
            enableAnimation: givenEnableAnimation,
            lockedChildren: givenLockedChildren,
            padding: givenPadding,
            clipBehavior: givenClipBehavior,
            physics: givenPhysics,
            dragChildBoxDecoration: givenDragChildBoxDecoration,
          ),
        ),
      );

      // then
      expect(
          find.byWidgetPredicate((widget) => hasReorderableExpectedValues(
                widget,
                reorderableType: ReorderableType.gridViewCount,
                crossAxisCount: givenCrossAxisCount,
                lockedChildren: givenLockedChildren,
                longPressDelay: givenLongPressDelay,
                enableAnimation: givenEnableAnimation,
                enableLongPress: givenEnableLongPress,
                mainAxisSpacing: givenMainAxisSpacing,
                children: givenChildren,
                clipBehavior: givenClipBehavior,
                padding: givenPadding,
                physics: givenPhysics,
                dragChildBoxDecoration: givenDragChildBoxDecoration,
              )),
          findsOneWidget);
    });
  });

  group('#ReorderableGridView.extent', () {
    testWidgets(
        'GIVEN children '
        'WHEN pumping [ReorderableGridView.extent] '
        'THEN should show widget with expected default values',
        (WidgetTester tester) async {
      // given
      const givenChildren = <Widget>[
        Text('hallo'),
      ];
      const givenMaxCrossAxisExtent = 100.0;

      // when
      await tester.pumpWidget(
        MaterialApp(
          home: ReorderableGridView.extent(
            children: givenChildren,
            onReorder: (_, __) {},
            maxCrossAxisExtent: givenMaxCrossAxisExtent,
          ),
        ),
      );

      // then
      expect(
          find.byWidgetPredicate((widget) => hasReorderableExpectedValues(
                widget,
                children: givenChildren,
                reorderableType: ReorderableType.gridViewExtent,
                maxCrossAxisExtent: givenMaxCrossAxisExtent,
              )),
          findsOneWidget);
    });

    testWidgets(
        'GIVEN children '
        'WHEN pumping [ReorderableGridView.extent] '
        'THEN should show widget with given values',
        (WidgetTester tester) async {
      // given
      const givenChildren = <Widget>[
        Text('hallo'),
      ];
      const givenMainAxisSpacing = 10.0;
      const givenEnableAnimation = false;
      const givenEnableLongPress = false;
      const givenLongPressDelay = Duration(days: 100);
      const givenLockedChildren = [10, 20];
      const givenPhysics = NeverScrollableScrollPhysics();
      const givenCrossAxisSpacing = 10.0;
      const givenMaxCrossAxisExtent = 100.0;
      const givenClipBehavior = Clip.none;
      const givenChildAspectRatio = 2.5;
      const givenPadding = EdgeInsets.only(top: 20);
      const givenDragChildBoxDecoration = BoxDecoration(color: Colors.orange);

      // when
      await tester.pumpWidget(
        MaterialApp(
          home: ReorderableGridView.extent(
            children: givenChildren,
            onReorder: (_, __) {},
            maxCrossAxisExtent: givenMaxCrossAxisExtent,
            mainAxisSpacing: givenMainAxisSpacing,
            crossAxisSpacing: givenCrossAxisSpacing,
            longPressDelay: givenLongPressDelay,
            enableLongPress: givenEnableLongPress,
            enableAnimation: givenEnableAnimation,
            lockedChildren: givenLockedChildren,
            physics: givenPhysics,
            clipBehavior: givenClipBehavior,
            childAspectRatio: givenChildAspectRatio,
            padding: givenPadding,
            dragChildBoxDecoration: givenDragChildBoxDecoration,
          ),
        ),
      );

      // then
      expect(
          find.byWidgetPredicate((widget) => hasReorderableExpectedValues(
                widget,
                children: givenChildren,
                reorderableType: ReorderableType.gridViewExtent,
                maxCrossAxisExtent: givenMaxCrossAxisExtent,
                lockedChildren: givenLockedChildren,
                longPressDelay: givenLongPressDelay,
                enableAnimation: givenEnableAnimation,
                enableLongPress: givenEnableLongPress,
                crossAxisSpacing: givenCrossAxisSpacing,
                physics: givenPhysics,
                clipBehavior: givenClipBehavior,
                mainAxisSpacing: givenMainAxisSpacing,
                padding: givenPadding,
                childAspectRatio: givenChildAspectRatio,
                dragChildBoxDecoration: givenDragChildBoxDecoration,
              )),
          findsOneWidget);
    });
  });
}

bool hasReorderableExpectedValues(
  Widget widget, {
  required List<Widget> children,
  required ReorderableType reorderableType,
  List<int> lockedChildren = const [],
  Duration longPressDelay = kLongPressTimeout,
  bool enableLongPress = true,
  bool enableAnimation = true,
  SliverGridDelegate gridDelegate =
      const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3,
  ),
  double mainAxisSpacing = 0.0,
  double crossAxisSpacing = 0.0,
  double maxCrossAxisExtent = 0.0,
  Clip clipBehavior = Clip.hardEdge,
  double childAspectRatio = 1.0,
  int? crossAxisCount,
  ScrollPhysics physics = const AlwaysScrollableScrollPhysics(),
  EdgeInsetsGeometry? padding,
  BoxDecoration? dragChildBoxDecoration,
}) {
  return widget is Reorderable &&
      widget.reorderableType == reorderableType &&
      widget.crossAxisCount == crossAxisCount &&
      widget.lockedChildren == lockedChildren &&
      widget.longPressDelay == longPressDelay &&
      widget.enableLongPress == enableLongPress &&
      widget.enableAnimation == enableAnimation &&
      widget.gridDelegate == gridDelegate &&
      widget.physics == physics &&
      widget.crossAxisSpacing == crossAxisSpacing &&
      widget.maxCrossAxisExtent == maxCrossAxisExtent &&
      widget.clipBehavior == clipBehavior &&
      widget.mainAxisSpacing == mainAxisSpacing &&
      widget.padding == padding &&
      widget.childAspectRatio == childAspectRatio &&
      widget.dragChildBoxDecoration == dragChildBoxDecoration;
}
