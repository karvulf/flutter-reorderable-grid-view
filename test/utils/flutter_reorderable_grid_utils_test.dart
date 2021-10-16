import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/entities/grid_item_entity.dart';
import 'package:flutter_reorderable_grid_view/utils/flutter_reorderable_grid_utils.dart';
import 'package:flutter_test/flutter_test.dart';

import '../services/flutter_reorderable_grid_view_builder.dart';

void main() {
  final builder = FlutterReorderableGridViewBuilder();

  group('#getItemsCollision', () {
    test(
        'GIVEN id = 0 and children with no ids '
        'WHEN calling #getItemsCollision '
        'THEN should return null', () {
      // given
      const givenId = 0;
      const givenPosition = Offset(0, 0);
      final givenChildren = <int, GridItemEntity>{};
      const givenScrollPixelsY = 0.0;

      // when
      final actual = getItemsCollision(
        id: givenId,
        position: givenPosition,
        children: givenChildren,
        scrollPixelsY: givenScrollPixelsY,
      );

      // then
      expect(actual, isNull);
    });

    test(
        'GIVEN position dx is less than globalPosition '
        'WHEN calling #getItemsCollision '
        'THEN should return null', () {
      // given
      const givenId = 0;
      const givenPosition = Offset(199, 200);
      final givenChildren = <int, GridItemEntity>{
        givenId: builder.getGridItemEntity(
          globalPosition: const Offset(200, 200),
          size: const Size(200, 200),
        ),
      };
      const givenScrollPixelsY = 0.0;

      // when
      final actual = getItemsCollision(
        id: givenId,
        position: givenPosition,
        children: givenChildren,
        scrollPixelsY: givenScrollPixelsY,
      );

      // then
      expect(actual, isNull);
    });

    test(
        'GIVEN position dy is less than globalPosition '
        'WHEN calling #getItemsCollision '
        'THEN should return null', () {
      // given
      const givenId = 0;
      const givenPosition = Offset(200, 199);
      final givenChildren = <int, GridItemEntity>{
        givenId: builder.getGridItemEntity(
          globalPosition: const Offset(200, 200),
          size: const Size(200, 200),
        ),
      };
      const givenScrollPixelsY = 0.0;

      // when
      final actual = getItemsCollision(
        id: givenId,
        position: givenPosition,
        children: givenChildren,
        scrollPixelsY: givenScrollPixelsY,
      );

      // then
      expect(actual, isNull);
    });

    test(
        'GIVEN position dx is higher than globalPosition '
        'WHEN calling #getItemsCollision '
        'THEN should return null', () {
      // given
      const givenId = 0;
      const givenPosition = Offset(401, 200);
      final givenChildren = <int, GridItemEntity>{
        givenId: builder.getGridItemEntity(
          globalPosition: const Offset(200, 200),
          size: const Size(200, 200),
        ),
      };
      const givenScrollPixelsY = 0.0;

      // when
      final actual = getItemsCollision(
        id: givenId,
        position: givenPosition,
        children: givenChildren,
        scrollPixelsY: givenScrollPixelsY,
      );

      // then
      expect(actual, isNull);
    });

    test(
        'GIVEN position dy is higher than globalPosition '
        'WHEN calling #getItemsCollision '
        'THEN should return null', () {
      // given
      const givenId = 0;
      const givenPosition = Offset(200, 401);
      final givenChildren = <int, GridItemEntity>{
        givenId: builder.getGridItemEntity(
          globalPosition: const Offset(200, 200),
          size: const Size(200, 200),
        ),
      };
      const givenScrollPixelsY = 0.0;

      // when
      final actual = getItemsCollision(
        id: givenId,
        position: givenPosition,
        children: givenChildren,
        scrollPixelsY: givenScrollPixelsY,
      );

      // then
      expect(actual, isNull);
    });

    test(
        'GIVEN position is inside globalPosition '
        'WHEN calling #getItemsCollision '
        'THEN should return null', () {
      // given
      const givenId = 0;
      const givenPosition = Offset(200, 400);
      final givenChildren = <int, GridItemEntity>{
        givenId: builder.getGridItemEntity(
          globalPosition: const Offset(200, 200),
          size: const Size(200, 200),
        ),
      };
      const givenScrollPixelsY = 0.0;

      // when
      final actual = getItemsCollision(
        id: givenId,
        position: givenPosition,
        children: givenChildren,
        scrollPixelsY: givenScrollPixelsY,
      );

      // then
      expect(actual, equals(givenId));
    });
  });

  group('#handleOneCollision', () {
    test(
        'GIVEN dragId and collisionId with 0 '
        'WHEN calling #handleOneCollision '
        'THEN should throw AssertionError', () {
      // given
      const givenId = 0;

      // when
      // then
      expect(
          () => handleOneCollision(
                dragId: givenId,
                collisionId: givenId,
                children: {},
              ),
          throwsAssertionError);
    });

    test(
        'GIVEN dragId and collisionId with 0 '
        'WHEN calling #handleOneCollision '
        'THEN should throw AssertionError', () {
      // given
      const givenId = 0;

      // when
      // then
      expect(
          () => handleOneCollision(
                dragId: givenId,
                collisionId: givenId,
                children: {},
              ),
          throwsAssertionError);
    });

    test(
        'GIVEN two [GridItemEntity] '
        'WHEN calling #handleOneCollision '
        'THEN should swap their values', () {
      // given
      const givenDragId = 0;
      const givenDragOrderId = 2;
      const givenDragGlobalPosition = Offset(0, 0);
      const givenDragLocalPosition = Offset(2, 2);

      const givenCollisionId = 1;
      const givenCollisionOrderId = 3;
      const givenCollisionGlobalPosition = Offset(1, 1);
      const givenCollisionLocalPosition = Offset(3, 3);

      final givenChildren = {
        givenDragId: builder.getGridItemEntity(
          orderId: givenDragOrderId,
          localPosition: givenDragLocalPosition,
          globalPosition: givenDragGlobalPosition,
        ),
        givenCollisionId: builder.getGridItemEntity(
          orderId: givenCollisionOrderId,
          globalPosition: givenCollisionGlobalPosition,
          localPosition: givenCollisionLocalPosition,
        ),
      };

      // when
      handleOneCollision(
        dragId: givenDragId,
        collisionId: givenCollisionId,
        children: givenChildren,
      );

      // then
      final actualChild1 = givenChildren[givenDragId]!;
      expect(actualChild1.orderId, equals(givenCollisionOrderId));
      expect(actualChild1.globalPosition, equals(givenCollisionGlobalPosition));
      expect(actualChild1.localPosition, equals(givenCollisionLocalPosition));

      final actualChild2 = givenChildren[givenCollisionId]!;
      expect(actualChild2.orderId, equals(givenDragOrderId));
      expect(actualChild2.globalPosition, equals(givenDragGlobalPosition));
      expect(actualChild2.localPosition, equals(givenDragLocalPosition));
    });
  });

  group('#handleMultipleCollisionsBackward', () {
    test(
        'GIVEN 4 childs and first and last child in orderId changes position '
        'WHEN calling #handleMultipleCollisionsBackward '
        'THEN should swap all positions correctly', () {
      // given
      // sorted by orderId
      const givenCollisionId = 0;
      const givenCollisionOrderId = 0;
      const givenCollisionGlobalPosition = Offset(0, 0);
      const givenCollisionLocalPosition = Offset(2, 2);

      const givenChildId = 3;
      const givenChildOrderId = 1;
      const givenChildGlobalPosition = Offset(4, 4);
      const givenChildLocalPosition = Offset(5, 5);

      const givenChildId2 = 2;
      const givenChildOrderId2 = 2;
      const givenChildGlobalPosition2 = Offset(6, 6);
      const givenChildLocalPosition2 = Offset(7, 7);

      const givenDragId = 1;
      const givenDragOrderId = 3;
      const givenDragGlobalPosition = Offset(1, 1);
      const givenDragLocalPosition = Offset(3, 3);

      // sorted by id
      final givenChildren = {
        givenDragId: builder.getGridItemEntity(
          orderId: givenDragOrderId,
          localPosition: givenDragLocalPosition,
          globalPosition: givenDragGlobalPosition,
        ),
        givenChildId2: builder.getGridItemEntity(
          orderId: givenChildOrderId2,
          localPosition: givenChildLocalPosition2,
          globalPosition: givenChildGlobalPosition2,
        ),
        givenCollisionId: builder.getGridItemEntity(
          orderId: givenCollisionOrderId,
          globalPosition: givenCollisionGlobalPosition,
          localPosition: givenCollisionLocalPosition,
        ),
        givenChildId: builder.getGridItemEntity(
          orderId: givenChildOrderId,
          localPosition: givenChildLocalPosition,
          globalPosition: givenChildGlobalPosition,
        ),
      };

      // when
      handleMultipleCollisionsBackward(
        dragItemOrderId: givenDragOrderId,
        collisionItemOrderId: givenCollisionOrderId,
        children: givenChildren,
      );

      // then
      final actualCollisionChild = givenChildren[givenCollisionId]!;
      final actualChild = givenChildren[givenChildId]!;
      final actualChild2 = givenChildren[givenChildId2]!;
      final actualDragChild = givenChildren[givenDragId]!;

      // collisionChild -> child
      expect(actualCollisionChild.orderId, equals(givenChildOrderId));
      expect(actualCollisionChild.globalPosition,
          equals(givenChildGlobalPosition));
      expect(
          actualCollisionChild.localPosition, equals(givenChildLocalPosition));

      // child -> child2
      expect(actualChild.orderId, equals(givenChildOrderId2));
      expect(actualChild.globalPosition, equals(givenChildGlobalPosition2));
      expect(actualChild.localPosition, equals(givenChildLocalPosition2));

      // child2 -> dragChild
      expect(actualChild2.orderId, equals(givenDragOrderId));
      expect(actualChild2.globalPosition, equals(givenDragGlobalPosition));
      expect(actualChild2.localPosition, equals(givenDragLocalPosition));

      // dragChild -> collisionChild
      expect(actualDragChild.orderId, equals(givenCollisionOrderId));
      expect(
          actualDragChild.globalPosition, equals(givenCollisionGlobalPosition));
      expect(
          actualDragChild.localPosition, equals(givenCollisionLocalPosition));
    });
  });

  group('#handleMultipleCollisionsForward', () {
    test(
        'GIVEN 4 childs and first and last child in orderId changes position '
        'WHEN calling #handleMultipleCollisionsForward '
        'THEN should swap all positions correctly', () {
      // given
      // sorted by orderId
      const givenDragId = 1;
      const givenDragOrderId = 0;
      const givenDragGlobalPosition = Offset(0, 0);
      const givenDragLocalPosition = Offset(2, 2);

      const givenChildId = 3;
      const givenChildOrderId = 1;
      const givenChildGlobalPosition = Offset(4, 4);
      const givenChildLocalPosition = Offset(5, 5);

      const givenChildId2 = 2;
      const givenChildOrderId2 = 2;
      const givenChildGlobalPosition2 = Offset(6, 6);
      const givenChildLocalPosition2 = Offset(7, 7);

      const givenCollisionId = 0;
      const givenCollisionOrderId = 3;
      const givenCollisionGlobalPosition = Offset(1, 1);
      const givenCollisionLocalPosition = Offset(3, 3);

      // sorted by id
      final givenChildren = {
        givenDragId: builder.getGridItemEntity(
          orderId: givenDragOrderId,
          localPosition: givenDragLocalPosition,
          globalPosition: givenDragGlobalPosition,
        ),
        givenChildId2: builder.getGridItemEntity(
          orderId: givenChildOrderId2,
          localPosition: givenChildLocalPosition2,
          globalPosition: givenChildGlobalPosition2,
        ),
        givenCollisionId: builder.getGridItemEntity(
          orderId: givenCollisionOrderId,
          globalPosition: givenCollisionGlobalPosition,
          localPosition: givenCollisionLocalPosition,
        ),
        givenChildId: builder.getGridItemEntity(
          orderId: givenChildOrderId,
          localPosition: givenChildLocalPosition,
          globalPosition: givenChildGlobalPosition,
        ),
      };

      // when
      handleMultipleCollisionsForward(
        dragItemOrderId: givenDragOrderId,
        collisionItemOrderId: givenCollisionOrderId,
        children: givenChildren,
      );

      // then
      final actualDragChild = givenChildren[givenDragId]!;
      final actualChild = givenChildren[givenChildId]!;
      final actualChild2 = givenChildren[givenChildId2]!;
      final actualCollisionChild = givenChildren[givenCollisionId]!;

      // dragChild -> collisionChild
      expect(actualDragChild.orderId, equals(givenCollisionOrderId));
      expect(
          actualDragChild.globalPosition, equals(givenCollisionGlobalPosition));
      expect(
          actualDragChild.localPosition, equals(givenCollisionLocalPosition));

      // child -> child2
      expect(actualChild.orderId, equals(givenDragOrderId));
      expect(actualChild.globalPosition, equals(givenDragGlobalPosition));
      expect(actualChild.localPosition, equals(givenDragLocalPosition));

      // child2 -> dragChild
      expect(actualChild2.orderId, equals(givenChildOrderId));
      expect(actualChild2.globalPosition, equals(givenChildGlobalPosition));
      expect(actualChild2.localPosition, equals(givenChildLocalPosition));

      // collisionChild -> child
      expect(actualCollisionChild.orderId, equals(givenChildOrderId2));
      expect(actualCollisionChild.globalPosition,
          equals(givenChildGlobalPosition2));
      expect(
          actualCollisionChild.localPosition, equals(givenChildLocalPosition2));
    });
  });
}
