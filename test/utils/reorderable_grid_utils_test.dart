import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/entities/grid_item_entity.dart';
import 'package:flutter_reorderable_grid_view/utils/reorderable_grid_utils.dart';
import 'package:flutter_test/flutter_test.dart';

import '../services/reorderable_grid_view_builder.dart';

void main() {
  final builder = ReorderableGridViewBuilder();

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
        childrenIdMap: givenChildren,
        scrollPixelsY: givenScrollPixelsY,
        lockedChildren: [],
      );

      // then
      expect(actual, isNull);
    });

    test(
        'GIVEN id = 0, children but id is in lockedChildren '
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
        childrenIdMap: givenChildren,
        scrollPixelsY: givenScrollPixelsY,
        lockedChildren: [givenId],
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
        childrenIdMap: givenChildren,
        scrollPixelsY: givenScrollPixelsY,
        lockedChildren: [],
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
        childrenIdMap: givenChildren,
        scrollPixelsY: givenScrollPixelsY,
        lockedChildren: [],
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
        childrenIdMap: givenChildren,
        scrollPixelsY: givenScrollPixelsY,
        lockedChildren: [],
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
        childrenIdMap: givenChildren,
        scrollPixelsY: givenScrollPixelsY,
        lockedChildren: [],
      );

      // then
      expect(actual, isNull);
    });

    test(
        'GIVEN position is inside globalPosition '
        'but collision id is in lockedChildren '
        'WHEN calling #getItemsCollision '
        'THEN should return null', () {
      // given
      const givenId = 0;
      const givenCollisionId = 1;
      const givenPosition = Offset(200, 400);
      final givenChildren = <int, GridItemEntity>{
        givenId: builder.getGridItemEntity(
          globalPosition: const Offset(-200, -200),
          size: const Size(200, 200),
        ),
        givenCollisionId: builder.getGridItemEntity(
          globalPosition: const Offset(200, 200),
          size: const Size(200, 200),
        ),
      };
      const givenScrollPixelsY = 0.0;

      // when
      final actual = getItemsCollision(
        id: givenId,
        position: givenPosition,
        childrenIdMap: givenChildren,
        scrollPixelsY: givenScrollPixelsY,
        lockedChildren: [givenCollisionId],
      );

      // then
      expect(actual, isNull);
    });

    test(
        'GIVEN position is inside globalPosition '
        'WHEN calling #getItemsCollision '
        'THEN should return given id', () {
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
        childrenIdMap: givenChildren,
        scrollPixelsY: givenScrollPixelsY,
        lockedChildren: [],
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
                childrenIdMap: {},
                childrenOrderIdMap: {},
                lockedChildren: [],
              ),
          throwsAssertionError);
    });

    test(
        'GIVEN two [GridItemEntity] but collisionId is inside lockedChildren '
        'WHEN calling #handleOneCollision '
        'THEN should not change any values', () {
      // given
      const givenDragId = 0;
      const givenDragOrderId = 2;
      const givenDragGlobalPosition = Offset(0, 0);
      const givenDragLocalPosition = Offset(2, 2);

      const givenCollisionId = 1;
      const givenCollisionOrderId = 3;
      const givenCollisionGlobalPosition = Offset(1, 1);
      const givenCollisionLocalPosition = Offset(3, 3);

      final givenDragChild = builder.getGridItemEntity(
        id: givenDragId,
        orderId: givenDragOrderId,
        localPosition: givenDragLocalPosition,
        globalPosition: givenDragGlobalPosition,
      );
      final givenCollisionChild = builder.getGridItemEntity(
        id: givenCollisionId,
        orderId: givenCollisionOrderId,
        globalPosition: givenCollisionGlobalPosition,
        localPosition: givenCollisionLocalPosition,
      );
      final givenChildrenIdMap = {
        givenDragId: givenDragChild,
        givenCollisionId: givenCollisionChild,
      };
      final givenChildrenOrderIdMap = {
        givenDragOrderId: givenDragChild,
        givenCollisionOrderId: givenCollisionChild,
      };

      // when
      handleOneCollision(
        dragId: givenDragId,
        collisionId: givenCollisionId,
        childrenIdMap: givenChildrenIdMap,
        childrenOrderIdMap: givenChildrenOrderIdMap,
        lockedChildren: [givenCollisionId],
      );

      // then
      expect(
          hasGridItemEntityValues(
            givenChildrenIdMap[givenDragId]!,
            id: givenDragId,
            orderId: givenDragOrderId,
            globalPosition: givenDragGlobalPosition,
            localPosition: givenDragLocalPosition,
          ),
          isTrue);

      expect(
          hasGridItemEntityValues(
            givenChildrenOrderIdMap[givenDragOrderId]!,
            id: givenDragId,
            orderId: givenDragOrderId,
            globalPosition: givenDragGlobalPosition,
            localPosition: givenDragLocalPosition,
          ),
          isTrue);

      expect(
          hasGridItemEntityValues(
            givenChildrenIdMap[givenCollisionId]!,
            id: givenCollisionId,
            orderId: givenCollisionOrderId,
            globalPosition: givenCollisionGlobalPosition,
            localPosition: givenCollisionLocalPosition,
          ),
          isTrue);

      expect(
          hasGridItemEntityValues(
            givenChildrenOrderIdMap[givenCollisionOrderId]!,
            id: givenCollisionId,
            orderId: givenCollisionOrderId,
            globalPosition: givenCollisionGlobalPosition,
            localPosition: givenCollisionLocalPosition,
          ),
          isTrue);
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

      final givenDragChild = builder.getGridItemEntity(
        id: givenDragId,
        orderId: givenDragOrderId,
        localPosition: givenDragLocalPosition,
        globalPosition: givenDragGlobalPosition,
      );
      final givenCollisionChild = builder.getGridItemEntity(
        id: givenCollisionId,
        orderId: givenCollisionOrderId,
        globalPosition: givenCollisionGlobalPosition,
        localPosition: givenCollisionLocalPosition,
      );
      final givenChildrenIdMap = {
        givenDragId: givenDragChild,
        givenCollisionId: givenCollisionChild,
      };
      final givenChildrenOrderIdMap = {
        givenDragOrderId: givenDragChild,
        givenCollisionOrderId: givenCollisionChild,
      };

      // when
      handleOneCollision(
        dragId: givenDragId,
        collisionId: givenCollisionId,
        childrenIdMap: givenChildrenIdMap,
        childrenOrderIdMap: givenChildrenOrderIdMap,
        lockedChildren: [],
      );

      // then
      expect(
          hasGridItemEntityValues(
            givenChildrenIdMap[givenDragId]!,
            id: givenDragId,
            orderId: givenCollisionOrderId,
            globalPosition: givenCollisionGlobalPosition,
            localPosition: givenCollisionLocalPosition,
          ),
          isTrue);
      expect(
          hasGridItemEntityValues(
            givenChildrenOrderIdMap[givenCollisionOrderId]!,
            id: givenDragId,
            orderId: givenCollisionOrderId,
            globalPosition: givenCollisionGlobalPosition,
            localPosition: givenCollisionLocalPosition,
          ),
          isTrue);

      expect(
          hasGridItemEntityValues(
            givenChildrenIdMap[givenCollisionId]!,
            id: givenCollisionId,
            orderId: givenDragOrderId,
            globalPosition: givenDragGlobalPosition,
            localPosition: givenDragLocalPosition,
          ),
          isTrue);
      expect(
          hasGridItemEntityValues(
            givenChildrenOrderIdMap[givenDragOrderId]!,
            id: givenCollisionId,
            orderId: givenDragOrderId,
            globalPosition: givenDragGlobalPosition,
            localPosition: givenDragLocalPosition,
          ),
          isTrue);
    });
  });

  group('#handleMultipleCollisionsBackward', () {
    test(
        'GIVEN 4 childs and last and first child in orderId changes position '
        'and no childs are in lockedChildren '
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
      final givenDragChild = builder.getGridItemEntity(
        id: givenDragId,
        orderId: givenDragOrderId,
        localPosition: givenDragLocalPosition,
        globalPosition: givenDragGlobalPosition,
      );
      final givenChild = builder.getGridItemEntity(
        id: givenChildId,
        orderId: givenChildOrderId,
        localPosition: givenChildLocalPosition,
        globalPosition: givenChildGlobalPosition,
      );
      final givenChild2 = builder.getGridItemEntity(
        id: givenChildId2,
        orderId: givenChildOrderId2,
        localPosition: givenChildLocalPosition2,
        globalPosition: givenChildGlobalPosition2,
      );
      final givenCollisionChild = builder.getGridItemEntity(
        id: givenCollisionId,
        orderId: givenCollisionOrderId,
        globalPosition: givenCollisionGlobalPosition,
        localPosition: givenCollisionLocalPosition,
      );
      final givenChildrenIdMap = {
        givenDragId: givenDragChild,
        givenChildId2: givenChild2,
        givenCollisionId: givenCollisionChild,
        givenChildId: givenChild,
      };
      final givenChildrenOrderIdMap = {
        givenDragOrderId: givenDragChild,
        givenChildOrderId2: givenChild2,
        givenCollisionOrderId: givenCollisionChild,
        givenChildOrderId: givenChild,
      };

      // when
      handleMultipleCollisionsBackward(
        dragItemOrderId: givenDragOrderId,
        collisionItemOrderId: givenCollisionOrderId,
        childrenIdMap: givenChildrenIdMap,
        childrenOrderIdMap: givenChildrenOrderIdMap,
        lockedChildren: [],
      );

      // then
      // collisionChild -> child
      expect(
          hasGridItemEntityValues(
            // collision has new values but same id (id can't change)
            givenChildrenIdMap[givenCollisionId]!,
            id: givenCollisionId,
            // collision was moved to child and get his orderId
            orderId: givenChildOrderId,
            // collision was moved to child and get his globalPosition
            globalPosition: givenChildGlobalPosition,
            // collision was moved to child and get his localPosition
            localPosition: givenChildLocalPosition,
          ),
          isTrue);
      expect(
          hasGridItemEntityValues(
            // updated position with drag child
            givenChildrenOrderIdMap[givenCollisionOrderId]!,
            // dragged child was moved to collision child
            id: givenDragId,
            // the draggedChild has now orderId of the collision child
            orderId: givenCollisionOrderId,
            // the draggedChild has now globalPosition of the collision child
            globalPosition: givenCollisionGlobalPosition,
            // the draggedChild has now localPosition of the collision child
            localPosition: givenCollisionLocalPosition,
          ),
          isTrue);

      // child -> child2
      expect(
          hasGridItemEntityValues(
            givenChildrenIdMap[givenChildId]!,
            id: givenChildId,
            orderId: givenChildOrderId2,
            globalPosition: givenChildGlobalPosition2,
            localPosition: givenChildLocalPosition2,
          ),
          isTrue);
      expect(
          hasGridItemEntityValues(
            givenChildrenOrderIdMap[givenChildOrderId]!,
            id: givenCollisionId,
            orderId: givenChildOrderId,
            globalPosition: givenChildGlobalPosition,
            localPosition: givenChildLocalPosition,
          ),
          isTrue);

      // child2 -> dragChild
      expect(
          hasGridItemEntityValues(
            givenChildrenIdMap[givenChildId2]!,
            id: givenChildId2,
            orderId: givenDragOrderId,
            globalPosition: givenDragGlobalPosition,
            localPosition: givenDragLocalPosition,
          ),
          isTrue);
      expect(
          hasGridItemEntityValues(
            givenChildrenOrderIdMap[givenChildOrderId2]!,
            id: givenChildId,
            orderId: givenChildOrderId2,
            globalPosition: givenChildGlobalPosition2,
            localPosition: givenChildLocalPosition2,
          ),
          isTrue);

      // dragChild -> collisionChild
      expect(
          hasGridItemEntityValues(
            givenChildrenIdMap[givenDragId]!,
            id: givenDragId,
            orderId: givenCollisionOrderId,
            globalPosition: givenCollisionGlobalPosition,
            localPosition: givenCollisionLocalPosition,
          ),
          isTrue);
      expect(
          hasGridItemEntityValues(
            givenChildrenOrderIdMap[givenDragOrderId]!,
            id: givenChildId2,
            orderId: givenDragOrderId,
            globalPosition: givenDragGlobalPosition,
            localPosition: givenDragLocalPosition,
          ),
          isTrue);
    });

    test(
        'GIVEN 4 childs and last and first child in orderId changes position '
        'and second child is in lockedChildren '
        'WHEN calling #handleMultipleCollisionsBackward '
        'THEN should swap all positions correctly but second child', () {
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
      final givenDragChild = builder.getGridItemEntity(
        id: givenDragId,
        orderId: givenDragOrderId,
        localPosition: givenDragLocalPosition,
        globalPosition: givenDragGlobalPosition,
      );
      final givenChild = builder.getGridItemEntity(
        id: givenChildId,
        orderId: givenChildOrderId,
        localPosition: givenChildLocalPosition,
        globalPosition: givenChildGlobalPosition,
      );
      final givenChild2 = builder.getGridItemEntity(
        id: givenChildId2,
        orderId: givenChildOrderId2,
        localPosition: givenChildLocalPosition2,
        globalPosition: givenChildGlobalPosition2,
      );
      final givenCollisionChild = builder.getGridItemEntity(
        id: givenCollisionId,
        orderId: givenCollisionOrderId,
        globalPosition: givenCollisionGlobalPosition,
        localPosition: givenCollisionLocalPosition,
      );
      final givenChildrenIdMap = {
        givenDragId: givenDragChild,
        givenChildId2: givenChild2,
        givenCollisionId: givenCollisionChild,
        givenChildId: givenChild,
      };
      final givenChildrenOrderIdMap = {
        givenDragOrderId: givenDragChild,
        givenChildOrderId2: givenChild2,
        givenCollisionOrderId: givenCollisionChild,
        givenChildOrderId: givenChild,
      };

      // when
      handleMultipleCollisionsBackward(
        dragItemOrderId: givenDragOrderId,
        collisionItemOrderId: givenCollisionOrderId,
        childrenIdMap: givenChildrenIdMap,
        childrenOrderIdMap: givenChildrenOrderIdMap,
        lockedChildren: [givenChildId],
      );

      // then
      // collisionChild -> child
      expect(
          hasGridItemEntityValues(
            givenChildrenIdMap[givenCollisionId]!,
            id: givenCollisionId,
            orderId: givenChildOrderId2,
            globalPosition: givenChildGlobalPosition2,
            localPosition: givenChildLocalPosition2,
          ),
          isTrue);
      expect(
          hasGridItemEntityValues(
            givenChildrenOrderIdMap[givenCollisionOrderId]!,
            id: givenDragId,
            orderId: givenCollisionOrderId,
            globalPosition: givenCollisionGlobalPosition,
            localPosition: givenCollisionLocalPosition,
          ),
          isTrue);

      // child does not change because locked
      expect(
          hasGridItemEntityValues(
            givenChildrenIdMap[givenChildId]!,
            id: givenChildId,
            orderId: givenChildOrderId,
            globalPosition: givenChildGlobalPosition,
            localPosition: givenChildLocalPosition,
          ),
          isTrue);
      expect(
          hasGridItemEntityValues(
            givenChildrenOrderIdMap[givenChildOrderId]!,
            id: givenChildId,
            orderId: givenChildOrderId,
            globalPosition: givenChildGlobalPosition,
            localPosition: givenChildLocalPosition,
          ),
          isTrue);

      // child2 -> dragChild
      expect(
          hasGridItemEntityValues(
            givenChildrenIdMap[givenChildId2]!,
            id: givenChildId2,
            orderId: givenDragOrderId,
            globalPosition: givenDragGlobalPosition,
            localPosition: givenDragLocalPosition,
          ),
          isTrue);
      expect(
          hasGridItemEntityValues(
            givenChildrenOrderIdMap[givenChildOrderId2]!,
            id: givenCollisionId,
            orderId: givenChildOrderId2,
            globalPosition: givenChildGlobalPosition2,
            localPosition: givenChildLocalPosition2,
          ),
          isTrue);

      // dragChild -> collisionChild
      expect(
          hasGridItemEntityValues(
            givenChildrenIdMap[givenDragId]!,
            id: givenDragId,
            orderId: givenCollisionOrderId,
            globalPosition: givenCollisionGlobalPosition,
            localPosition: givenCollisionLocalPosition,
          ),
          isTrue);
      expect(
          hasGridItemEntityValues(
            givenChildrenOrderIdMap[givenDragOrderId]!,
            id: givenChildId2,
            orderId: givenDragOrderId,
            globalPosition: givenDragGlobalPosition,
            localPosition: givenDragLocalPosition,
          ),
          isTrue);
    });
  });

  group('#handleMultipleCollisionsForward', () {
    test(
        'GIVEN 4 childs and first and last child in orderId changes position '
        'and there are no locked children '
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
      final givenDragChild = builder.getGridItemEntity(
        id: givenDragId,
        orderId: givenDragOrderId,
        localPosition: givenDragLocalPosition,
        globalPosition: givenDragGlobalPosition,
      );
      final givenChild = builder.getGridItemEntity(
        id: givenChildId,
        orderId: givenChildOrderId,
        localPosition: givenChildLocalPosition,
        globalPosition: givenChildGlobalPosition,
      );
      final givenChild2 = builder.getGridItemEntity(
        id: givenChildId2,
        orderId: givenChildOrderId2,
        localPosition: givenChildLocalPosition2,
        globalPosition: givenChildGlobalPosition2,
      );
      final givenCollisionChild = builder.getGridItemEntity(
        id: givenCollisionId,
        orderId: givenCollisionOrderId,
        globalPosition: givenCollisionGlobalPosition,
        localPosition: givenCollisionLocalPosition,
      );
      final givenChildrenIdMap = {
        givenDragId: givenDragChild,
        givenChildId2: givenChild2,
        givenCollisionId: givenCollisionChild,
        givenChildId: givenChild,
      };
      final givenChildrenOrderIdMap = {
        givenDragOrderId: givenDragChild,
        givenChildOrderId2: givenChild2,
        givenCollisionOrderId: givenCollisionChild,
        givenChildOrderId: givenChild,
      };

      // when
      handleMultipleCollisionsForward(
        dragItemOrderId: givenDragOrderId,
        collisionItemOrderId: givenCollisionOrderId,
        childrenIdMap: givenChildrenIdMap,
        childrenOrderIdMap: givenChildrenOrderIdMap,
        lockedChildren: [],
      );

      // then
      // dragChild -> collisionChild
      expect(
          hasGridItemEntityValues(
            givenChildrenIdMap[givenDragId]!,
            id: givenDragId,
            orderId: givenCollisionOrderId,
            globalPosition: givenCollisionGlobalPosition,
            localPosition: givenCollisionLocalPosition,
          ),
          isTrue);
      expect(
          hasGridItemEntityValues(
            givenChildrenOrderIdMap[givenDragOrderId]!,
            id: givenChildId,
            orderId: givenDragOrderId,
            globalPosition: givenDragGlobalPosition,
            localPosition: givenDragLocalPosition,
          ),
          isTrue);

      // child -> dragChild
      expect(
          hasGridItemEntityValues(
            givenChildrenIdMap[givenChildId]!,
            id: givenChildId,
            orderId: givenDragOrderId,
            globalPosition: givenDragGlobalPosition,
            localPosition: givenDragLocalPosition,
          ),
          isTrue);
      expect(
          hasGridItemEntityValues(
            givenChildrenOrderIdMap[givenChildOrderId]!,
            id: givenChildId2,
            orderId: givenChildOrderId,
            globalPosition: givenChildGlobalPosition,
            localPosition: givenChildLocalPosition,
          ),
          isTrue);

      // child2 -> child
      expect(
          hasGridItemEntityValues(
            givenChildrenIdMap[givenChildId2]!,
            id: givenChildId2,
            orderId: givenChildOrderId,
            globalPosition: givenChildGlobalPosition,
            localPosition: givenChildLocalPosition,
          ),
          isTrue);
      expect(
          hasGridItemEntityValues(
            givenChildrenOrderIdMap[givenChildOrderId2]!,
            id: givenCollisionId,
            orderId: givenChildOrderId2,
            globalPosition: givenChildGlobalPosition2,
            localPosition: givenChildLocalPosition2,
          ),
          isTrue);

      // collisionChild -> child
      expect(
          hasGridItemEntityValues(
            givenChildrenIdMap[givenCollisionId]!,
            id: givenCollisionId,
            orderId: givenChildOrderId2,
            globalPosition: givenChildGlobalPosition2,
            localPosition: givenChildLocalPosition2,
          ),
          isTrue);
      expect(
          hasGridItemEntityValues(
            givenChildrenOrderIdMap[givenCollisionOrderId]!,
            id: givenDragId,
            orderId: givenCollisionOrderId,
            globalPosition: givenCollisionGlobalPosition,
            localPosition: givenCollisionLocalPosition,
          ),
          isTrue);
    });
    test(
        'GIVEN 4 childs and first and last child in orderId changes position '
        'but second and third child is in lockedChildren '
        'WHEN calling #handleMultipleCollisionsForward '
        'THEN should swap only positions of dragged and collisioned item', () {
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
      final givenDragChild = builder.getGridItemEntity(
        id: givenDragId,
        orderId: givenDragOrderId,
        localPosition: givenDragLocalPosition,
        globalPosition: givenDragGlobalPosition,
      );
      final givenChild = builder.getGridItemEntity(
        id: givenChildId,
        orderId: givenChildOrderId,
        localPosition: givenChildLocalPosition,
        globalPosition: givenChildGlobalPosition,
      );
      final givenChild2 = builder.getGridItemEntity(
        id: givenChildId2,
        orderId: givenChildOrderId2,
        localPosition: givenChildLocalPosition2,
        globalPosition: givenChildGlobalPosition2,
      );
      final givenCollisionChild = builder.getGridItemEntity(
        id: givenCollisionId,
        orderId: givenCollisionOrderId,
        globalPosition: givenCollisionGlobalPosition,
        localPosition: givenCollisionLocalPosition,
      );
      final givenChildrenIdMap = {
        givenDragId: givenDragChild,
        givenChildId2: givenChild2,
        givenCollisionId: givenCollisionChild,
        givenChildId: givenChild,
      };
      final givenChildrenOrderIdMap = {
        givenDragOrderId: givenDragChild,
        givenChildOrderId2: givenChild2,
        givenCollisionOrderId: givenCollisionChild,
        givenChildOrderId: givenChild,
      };

      // when
      handleMultipleCollisionsForward(
        dragItemOrderId: givenDragOrderId,
        collisionItemOrderId: givenCollisionOrderId,
        childrenIdMap: givenChildrenIdMap,
        childrenOrderIdMap: givenChildrenOrderIdMap,
        lockedChildren: [givenChildId, givenChildId2],
      );

      // then
      // dragChild -> collisionChild
      expect(
          hasGridItemEntityValues(
            givenChildrenIdMap[givenDragId]!,
            id: givenDragId,
            orderId: givenCollisionOrderId,
            globalPosition: givenCollisionGlobalPosition,
            localPosition: givenCollisionLocalPosition,
          ),
          isTrue);
      expect(
          hasGridItemEntityValues(
            givenChildrenOrderIdMap[givenDragOrderId]!,
            id: givenCollisionId,
            orderId: givenDragOrderId,
            globalPosition: givenDragGlobalPosition,
            localPosition: givenDragLocalPosition,
          ),
          isTrue);

      // child should not change because locked
      expect(
          hasGridItemEntityValues(
            givenChildrenIdMap[givenChildId]!,
            id: givenChildId,
            orderId: givenChildOrderId,
            globalPosition: givenChildGlobalPosition,
            localPosition: givenChildLocalPosition,
          ),
          isTrue);
      expect(
          hasGridItemEntityValues(
            givenChildrenOrderIdMap[givenChildOrderId]!,
            id: givenChildId,
            orderId: givenChildOrderId,
            globalPosition: givenChildGlobalPosition,
            localPosition: givenChildLocalPosition,
          ),
          isTrue);

      // child2 should not change because locked
      expect(
          hasGridItemEntityValues(
            givenChildrenIdMap[givenChildId2]!,
            id: givenChildId2,
            orderId: givenChildOrderId2,
            globalPosition: givenChildGlobalPosition2,
            localPosition: givenChildLocalPosition2,
          ),
          isTrue);
      expect(
          hasGridItemEntityValues(
            givenChildrenOrderIdMap[givenChildOrderId2]!,
            id: givenChildId2,
            orderId: givenChildOrderId2,
            globalPosition: givenChildGlobalPosition2,
            localPosition: givenChildLocalPosition2,
          ),
          isTrue);

      // collisionChild -> child
      expect(
          hasGridItemEntityValues(
            givenChildrenIdMap[givenCollisionId]!,
            id: givenCollisionId,
            orderId: givenDragOrderId,
            globalPosition: givenDragGlobalPosition,
            localPosition: givenDragLocalPosition,
          ),
          isTrue);
      expect(
          hasGridItemEntityValues(
            givenChildrenOrderIdMap[givenCollisionOrderId]!,
            id: givenDragId,
            orderId: givenCollisionOrderId,
            globalPosition: givenCollisionGlobalPosition,
            localPosition: givenCollisionLocalPosition,
          ),
          isTrue);
    });
  });
}

bool hasGridItemEntityValues(
  GridItemEntity item, {
  required int id,
  required int orderId,
  required Offset globalPosition,
  required Offset localPosition,
}) {
  return item.id == id &&
      item.orderId == orderId &&
      item.globalPosition == globalPosition &&
      item.localPosition == localPosition;
}
