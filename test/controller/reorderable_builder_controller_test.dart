import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/controller/reorderable_builder_controller.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ReorderableBuilderController controller;

  const givenKey1 = ValueKey('child1');
  const givenKey2 = ValueKey('child2');

  setUp(() {
    controller = ReorderableBuilderController();
  });

  group('#initChildren', () {
    test(
        'GIVEN two children with different keys '
        'WHEN calling #initChildren '
        'THEN should add expected values to childrenOrderMap and childrenKeyMap',
        () {
      // given
      const givenChildren = [
        Placeholder(key: givenKey1),
        Placeholder(key: givenKey2),
      ];

      // when
      controller.initChildren(children: givenChildren);

      // then
      final expectedReorderableEntity1 = ReorderableEntity.create(
        key: givenKey1,
        updatedOrderId: 0,
      );
      final expectedReorderableEntity2 = ReorderableEntity.create(
        key: givenKey2,
        updatedOrderId: 1,
      );
      final expectedChildrenOrderMap = {-1: expectedReorderableEntity2};
      expect(controller.childrenOrderMap, equals(expectedChildrenOrderMap));
      final expectedChildrenKeyMap = {
        givenKey1.value: expectedReorderableEntity1,
        givenKey2.value: expectedReorderableEntity2,
      };
      expect(controller.childrenKeyMap, equals(expectedChildrenKeyMap));
    });

    test(
        'GIVEN two children with same keys '
        'WHEN calling #initChildren '
        'THEN should throw assertion error', () {
      // given
      const givenChildren = [
        Placeholder(key: givenKey1),
        Placeholder(key: givenKey1),
      ];

      // when
      actualCall() => controller.initChildren(children: givenChildren);

      // then
      expect(actualCall, throwsAssertionError);
    });
  });

  group('#updateChildren', () {
    test(
        'GIVEN two children with same keys '
        'WHEN calling #updateChildren '
        'THEN should add expected values to childrenOrderMap and childrenKeyMap',
        () {
      // given
      const givenSize = Size(200, 200);
      final givenChildren = [
        SizedBox(
          key: givenKey1,
          height: givenSize.height,
          width: givenSize.width,
        ),
        SizedBox(
          key: givenKey2,
          height: givenSize.height,
          width: givenSize.width,
        ),
      ];

      // when
      controller.updateChildren(children: givenChildren);

      // then
      final expectedReorderableEntity1 = ReorderableEntity.create(
        key: givenKey1,
        updatedOrderId: 0,
      );
      final expectedReorderableEntity2 = ReorderableEntity.create(
        key: givenKey2,
        updatedOrderId: 1,
      );
      final expectedChildrenOrderMap = {-1: expectedReorderableEntity2};
      expect(controller.childrenOrderMap, equals(expectedChildrenOrderMap));
      final expectedChildrenKeyMap = {
        givenKey1.value: expectedReorderableEntity1,
        givenKey2.value: expectedReorderableEntity2,
      };
      expect(controller.childrenKeyMap, equals(expectedChildrenKeyMap));
    });
  });
}
