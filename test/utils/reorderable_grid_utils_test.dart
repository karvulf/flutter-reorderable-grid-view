import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/entities/grid_item_entity.dart';
import 'package:flutter_reorderable_grid_view/utils/reorderable_grid_utils.dart';
import 'package:flutter_test/flutter_test.dart';

import '../services/reorderable_grid_view_builder.dart';

void main() {
  final builder = ReorderableGridViewBuilder();

  group('#getItemsCollision', () {
    test(
        'GIVEN orderId = 0 and children with no ids '
        'WHEN calling #getItemsCollision '
        'THEN should return null', () {
      // given
      const givenOrderId = 0;
      const givenPosition = Offset(0, 0);
      const givenSize = Size(100, 100);
      final givenChildren = <int, GridItemEntity>{};

      // when
      final actual = getItemsCollision(
        orderId: givenOrderId,
        position: givenPosition,
        size: givenSize,
        childrenIdMap: givenChildren,
        lockedChildren: [],
      );

      // then
      expect(actual, isNull);
    });

    test(
        'GIVEN oderId = 0, children but id is in lockedChildren '
        'WHEN calling #getItemsCollision '
        'THEN should return null', () {
      // given
      const givenOrderId = 0;
      const givenPosition = Offset(0, 0);
      final givenChildren = <int, GridItemEntity>{};
      const givenSize = Size(100, 100);

      // when
      final actual = getItemsCollision(
        orderId: givenOrderId,
        position: givenPosition,
        size: givenSize,
        childrenIdMap: givenChildren,
        lockedChildren: [givenOrderId],
      );

      // then
      expect(actual, isNull);
    });

    test(
        'GIVEN position dx with width is less than globalPosition '
        'WHEN calling #getItemsCollision '
        'THEN should return null', () {
      // given
      const givenOrderId = 0;
      const givenPosition = Offset(99, 200);
      const givenSize = Size(200, 200);
      final givenChildren = <int, GridItemEntity>{
        0: builder.getGridItemEntity(
          localPosition: const Offset(200, 200),
          size: givenSize,
          orderId: givenOrderId,
        ),
      };

      // when
      final actual = getItemsCollision(
        orderId: givenOrderId,
        position: givenPosition,
        size: givenSize,
        childrenIdMap: givenChildren,
        lockedChildren: [],
      );

      // then
      expect(actual, isNull);
    });

    test(
        'GIVEN position dy with height is less than globalPosition '
        'WHEN calling #getItemsCollision '
        'THEN should return null', () {
      // given
      const givenOrderId = 0;
      const givenPosition = Offset(200, 99);
      const givenSize = Size(200, 200);
      final givenChildren = <int, GridItemEntity>{
        0: builder.getGridItemEntity(
          localPosition: const Offset(200, 200),
          size: givenSize,
          orderId: givenOrderId,
        ),
      };

      final actual = getItemsCollision(
        orderId: givenOrderId,
        position: givenPosition,
        size: givenSize,
        childrenIdMap: givenChildren,
        lockedChildren: [],
      );

      // then
      expect(actual, isNull);
    });

    test(
        'GIVEN position dx with width is bigger than globalPosition '
        'WHEN calling #getItemsCollision '
        'THEN should return null', () {
      // given
      const givenOrderId = 0;
      const givenPosition = Offset(301, 200);
      const givenSize = Size(200, 200);
      final givenChildren = <int, GridItemEntity>{
        0: builder.getGridItemEntity(
          localPosition: const Offset(200, 200),
          size: givenSize,
          orderId: givenOrderId,
        ),
      };

      // when
      final actual = getItemsCollision(
        orderId: givenOrderId,
        position: givenPosition,
        size: givenSize,
        childrenIdMap: givenChildren,
        lockedChildren: [],
      );

      // then
      expect(actual, isNull);
    });

    test(
        'GIVEN position dy with width is bigger than globalPosition '
        'WHEN calling #getItemsCollision '
        'THEN should return null', () {
      // given
      const givenOrderId = 0;
      const givenPosition = Offset(200, 301);
      const givenSize = Size(200, 200);
      final givenChildren = <int, GridItemEntity>{
        0: builder.getGridItemEntity(
          localPosition: const Offset(200, 200),
          size: givenSize,
          orderId: givenOrderId,
        ),
      };

      // when
      final actual = getItemsCollision(
        orderId: givenOrderId,
        position: givenPosition,
        size: givenSize,
        childrenIdMap: givenChildren,
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
      const givenOrderId = 0;
      const givenCollisionId = 1;
      const givenPosition = Offset(200, 400);
      const givenSize = Size(200, 200);
      final givenChildren = <int, GridItemEntity>{
        0: builder.getGridItemEntity(
          localPosition: const Offset(-200, -200),
          size: givenSize,
          orderId: givenOrderId,
        ),
        1: builder.getGridItemEntity(
          localPosition: const Offset(200, 200),
          size: givenSize,
          orderId: givenCollisionId,
        ),
      };

      // when
      final actual = getItemsCollision(
        orderId: givenOrderId,
        position: givenPosition,
        size: givenSize,
        childrenIdMap: givenChildren,
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
      const givenOrderId = 0;
      const givenPosition = Offset(100, 300);
      const givenSize = Size(200, 200);
      final givenChildren = <int, GridItemEntity>{
        0: builder.getGridItemEntity(
          localPosition: const Offset(200, 200),
          size: givenSize,
          orderId: givenOrderId,
        ),
      };

      // when
      final actual = getItemsCollision(
        orderId: givenOrderId,
        position: givenPosition,
        size: givenSize,
        childrenIdMap: givenChildren,
        lockedChildren: [],
      );

      // then
      expect(actual, equals(givenOrderId));
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
                dragOrderId: givenId,
                collisionOrderId: givenId,
                childrenIdMap: {},
                lockedChildren: [],
                onReorder: (_, __) {},
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
      const givenDragLocalPosition = Offset(2, 2);

      const givenCollisionId = 1;
      const givenCollisionOrderId = 3;
      const givenCollisionLocalPosition = Offset(3, 3);

      final givenDragChild = builder.getGridItemEntity(
        orderId: givenDragOrderId,
        localPosition: givenDragLocalPosition,
      );
      final givenCollisionChild = builder.getGridItemEntity(
        orderId: givenCollisionOrderId,
        localPosition: givenCollisionLocalPosition,
      );
      final givenChildrenIdMap = {
        givenDragId: givenDragChild,
        givenCollisionId: givenCollisionChild,
      };

      int? actualOldIndex;
      int? actualNewIndex;

      // when
      handleOneCollision(
        dragOrderId: givenDragId,
        collisionOrderId: givenCollisionId,
        childrenIdMap: givenChildrenIdMap,
        lockedChildren: [givenCollisionId],
        onReorder: (oldIndex, newIndex) {
          actualOldIndex = oldIndex;
          actualNewIndex = newIndex;
        },
      );

      // then
      expect(
          hasGridItemEntityValues(
            givenChildrenIdMap[givenDragId]!,
            orderId: givenDragOrderId,
            localPosition: givenDragLocalPosition,
          ),
          isTrue);

      expect(
          hasGridItemEntityValues(
            givenChildrenIdMap[givenCollisionId]!,
            orderId: givenCollisionOrderId,
            localPosition: givenCollisionLocalPosition,
          ),
          isTrue);

      expect(actualOldIndex, isNull);
      expect(actualNewIndex, isNull);
    });

    test(
        'GIVEN two [GridItemEntity] '
        'WHEN calling #handleOneCollision '
        'THEN should swap their values', () {
      // given
      const givenDragId = 0;
      const givenDragOrderId = 2;
      const givenDragLocalPosition = Offset(2, 2);

      const givenCollisionId = 1;
      const givenCollisionOrderId = 3;
      const givenCollisionLocalPosition = Offset(3, 3);

      final givenDragChild = builder.getGridItemEntity(
        orderId: givenDragOrderId,
        localPosition: givenDragLocalPosition,
      );
      final givenCollisionChild = builder.getGridItemEntity(
        orderId: givenCollisionOrderId,
        localPosition: givenCollisionLocalPosition,
      );
      final givenChildrenIdMap = {
        givenDragId: givenDragChild,
        givenCollisionId: givenCollisionChild,
      };

      int? actualOldIndex;
      int? actualNewIndex;

      // when
      handleOneCollision(
        dragOrderId: givenDragOrderId,
        collisionOrderId: givenCollisionOrderId,
        childrenIdMap: givenChildrenIdMap,
        lockedChildren: [],
        onReorder: (oldIndex, newIndex) {
          actualOldIndex = oldIndex;
          actualNewIndex = newIndex;
        },
      );

      // then
      expect(
          hasGridItemEntityValues(
            givenChildrenIdMap[givenDragId]!,
            orderId: givenCollisionOrderId,
            localPosition: givenCollisionLocalPosition,
          ),
          isTrue);

      expect(
          hasGridItemEntityValues(
            givenChildrenIdMap[givenCollisionId]!,
            orderId: givenDragOrderId,
            localPosition: givenDragLocalPosition,
          ),
          isTrue);

      expect(actualOldIndex, equals(givenDragOrderId));
      expect(actualNewIndex, equals(givenCollisionOrderId));
    });
  });

  group('#handleMultipleCollisionsBackward', () {
    test(
        'GIVEN 4 children and last and first child in orderId changes position '
        'and no children are in lockedChildren '
        'WHEN calling #handleMultipleCollisionsBackward '
        'THEN should swap all positions correctly', () {
      // given
      // sorted by orderId
      const givenCollisionId = 0;
      const givenCollisionOrderId = 0;
      const givenCollisionLocalPosition = Offset(2, 2);

      const givenChildId = 3;
      const givenChildOrderId = 1;
      const givenChildLocalPosition = Offset(5, 5);

      const givenChildId2 = 2;
      const givenChildOrderId2 = 2;
      const givenChildLocalPosition2 = Offset(7, 7);

      const givenDragId = 1;
      const givenDragOrderId = 3;
      const givenDragLocalPosition = Offset(3, 3);

      // sorted by id
      final givenCollisionChild = builder.getGridItemEntity(
        orderId: givenCollisionOrderId,
        localPosition: givenCollisionLocalPosition,
      );
      final givenChild = builder.getGridItemEntity(
        orderId: givenChildOrderId,
        localPosition: givenChildLocalPosition,
      );
      final givenChild2 = builder.getGridItemEntity(
        orderId: givenChildOrderId2,
        localPosition: givenChildLocalPosition2,
      );
      final givenDragChild = builder.getGridItemEntity(
        orderId: givenDragOrderId,
        localPosition: givenDragLocalPosition,
      );

      final givenChildrenIdMap = {
        givenCollisionId: givenCollisionChild,
        givenChildId2: givenChild2,
        givenChildId: givenChild,
        givenDragId: givenDragChild,
      };

      List<int> actualOldIndexList = <int>[];
      List<int> actualNewIndexList = <int>[];

      // when
      handleMultipleCollisionsBackward(
        dragOrderId: givenDragOrderId,
        collisionOrderId: givenCollisionOrderId,
        childrenIdMap: givenChildrenIdMap,
        lockedChildren: [],
        onReorder: (oldIndex, newIndex) {
          actualOldIndexList.add(oldIndex);
          actualNewIndexList.add(newIndex);
        },
      );

      // then
      // collisionChild -> child
      expect(
          hasGridItemEntityValues(
            // collision has new values but same id (id can't change)
            givenChildrenIdMap[givenCollisionId]!,
            // collision was moved to child and get his orderId
            orderId: givenChildOrderId,
            // collision was moved to child and get his localPosition
            localPosition: givenChildLocalPosition,
          ),
          isTrue);

      // child -> child2
      expect(
          hasGridItemEntityValues(
            givenChildrenIdMap[givenChildId]!,
            orderId: givenChildOrderId2,
            localPosition: givenChildLocalPosition2,
          ),
          isTrue);

      // child2 -> dragChild
      expect(
          hasGridItemEntityValues(
            givenChildrenIdMap[givenChildId2]!,
            orderId: givenDragOrderId,
            localPosition: givenDragLocalPosition,
          ),
          isTrue);

      // dragChild -> collisionChild
      expect(
          hasGridItemEntityValues(
            givenChildrenIdMap[givenDragId]!,
            orderId: givenCollisionOrderId,
            localPosition: givenCollisionLocalPosition,
          ),
          isTrue);

      expect(
          actualOldIndexList,
          equals([
            givenDragOrderId,
            givenChildOrderId2,
            givenChildOrderId,
          ]));
      expect(
          actualNewIndexList,
          equals([
            givenChildOrderId2,
            givenChildOrderId,
            givenCollisionOrderId,
          ]));
    });

    test(
        'GIVEN 4 children and last and first child in orderId changes position '
        'and second child is in lockedChildren '
        'WHEN calling #handleMultipleCollisionsBackward '
        'THEN should swap all positions correctly but second child', () {
      // given
      // sorted by orderId
      const givenCollisionId = 0;
      const givenCollisionOrderId = 0;
      const givenCollisionLocalPosition = Offset(2, 2);

      const givenLockedChildId = 3;
      const givenLockedChildOrderId = 1;
      const givenLockedChildLocalPosition = Offset(5, 5);

      const givenChildId = 2;
      const givenChildOrderId = 2;
      const givenChildLocalPosition = Offset(7, 7);

      const givenDragId = 1;
      const givenDragOrderId = 3;
      const givenDragLocalPosition = Offset(3, 3);

      // sorted by id
      final givenCollisionChild = builder.getGridItemEntity(
        orderId: givenCollisionOrderId,
        localPosition: givenCollisionLocalPosition,
      );
      final givenLockedChild = builder.getGridItemEntity(
        orderId: givenLockedChildOrderId,
        localPosition: givenLockedChildLocalPosition,
      );
      final givenChild = builder.getGridItemEntity(
        orderId: givenChildOrderId,
        localPosition: givenChildLocalPosition,
      );
      final givenDragChild = builder.getGridItemEntity(
        orderId: givenDragOrderId,
        localPosition: givenDragLocalPosition,
      );

      final givenChildrenIdMap = {
        givenCollisionId: givenCollisionChild,
        givenLockedChildId: givenLockedChild,
        givenChildId: givenChild,
        givenDragId: givenDragChild,
      };

      List<int> actualOldIndexList = <int>[];
      List<int> actualNewIndexList = <int>[];

      // when
      handleMultipleCollisionsBackward(
        dragOrderId: givenDragOrderId,
        collisionOrderId: givenCollisionOrderId,
        childrenIdMap: givenChildrenIdMap,
        lockedChildren: [givenLockedChildOrderId],
        onReorder: (oldIndex, newIndex) {
          actualOldIndexList.add(oldIndex);
          actualNewIndexList.add(newIndex);
        },
      );

      // then
      // collisionChild -> child
      expect(
          hasGridItemEntityValues(
            givenChildrenIdMap[givenCollisionId]!,
            orderId: givenChildOrderId,
            localPosition: givenChildLocalPosition,
          ),
          isTrue);

      // child does not change because locked
      expect(
          hasGridItemEntityValues(
            givenChildrenIdMap[givenLockedChildId]!,
            orderId: givenLockedChildOrderId,
            localPosition: givenLockedChildLocalPosition,
          ),
          isTrue);

      // child2 -> dragChild
      expect(
          hasGridItemEntityValues(
            givenChildrenIdMap[givenChildId]!,
            orderId: givenDragOrderId,
            localPosition: givenDragLocalPosition,
          ),
          isTrue);

      // dragChild -> collisionChild
      expect(
          hasGridItemEntityValues(
            givenChildrenIdMap[givenDragId]!,
            orderId: givenCollisionOrderId,
            localPosition: givenCollisionLocalPosition,
          ),
          isTrue);
      expect(
          actualOldIndexList,
          equals([
            givenDragOrderId,
            givenChildOrderId,
          ]));
      expect(
          actualNewIndexList,
          equals([
            givenChildOrderId,
            givenCollisionOrderId,
          ]));
    });
  });

  group('#handleMultipleCollisionsForward', () {
    test(
        'GIVEN 4 children and first and last child in orderId changes position '
        'and there are no locked children '
        'WHEN calling #handleMultipleCollisionsForward '
        'THEN should swap all positions correctly', () {
      // given
      // sorted by orderId
      const givenDragId = 1;
      const givenDragOrderId = 0;
      const givenDragLocalPosition = Offset(2, 2);

      const givenChildId = 3;
      const givenChildOrderId = 1;
      const givenChildLocalPosition = Offset(5, 5);

      const givenChildId2 = 2;
      const givenChildOrderId2 = 2;
      const givenChildLocalPosition2 = Offset(7, 7);

      const givenCollisionId = 0;
      const givenCollisionOrderId = 3;
      const givenCollisionLocalPosition = Offset(3, 3);

      // sorted by id
      final givenDragChild = builder.getGridItemEntity(
        orderId: givenDragOrderId,
        localPosition: givenDragLocalPosition,
      );
      final givenChild = builder.getGridItemEntity(
        orderId: givenChildOrderId,
        localPosition: givenChildLocalPosition,
      );
      final givenChild2 = builder.getGridItemEntity(
        orderId: givenChildOrderId2,
        localPosition: givenChildLocalPosition2,
      );
      final givenCollisionChild = builder.getGridItemEntity(
        orderId: givenCollisionOrderId,
        localPosition: givenCollisionLocalPosition,
      );

      final givenChildrenIdMap = {
        givenDragId: givenDragChild,
        givenChildId2: givenChild2,
        givenChildId: givenChild,
        givenCollisionId: givenCollisionChild,
      };

      List<int> actualOldIndexList = <int>[];
      List<int> actualNewIndexList = <int>[];

      // when
      handleMultipleCollisionsForward(
        dragOrderId: givenDragOrderId,
        collisionOrderId: givenCollisionOrderId,
        childrenIdMap: givenChildrenIdMap,
        lockedChildren: [],
        onReorder: (oldIndex, newIndex) {
          actualOldIndexList.add(oldIndex);
          actualNewIndexList.add(newIndex);
        },
      );

      // then
      // dragChild -> collisionChild
      expect(
          hasGridItemEntityValues(
            givenChildrenIdMap[givenDragId]!,
            orderId: givenCollisionOrderId,
            localPosition: givenCollisionLocalPosition,
          ),
          isTrue);

      // child -> dragChild
      expect(
          hasGridItemEntityValues(
            givenChildrenIdMap[givenChildId]!,
            orderId: givenDragOrderId,
            localPosition: givenDragLocalPosition,
          ),
          isTrue);

      // child2 -> child
      expect(
          hasGridItemEntityValues(
            givenChildrenIdMap[givenChildId2]!,
            orderId: givenChildOrderId,
            localPosition: givenChildLocalPosition,
          ),
          isTrue);

      // collisionChild -> child
      expect(
          hasGridItemEntityValues(
            givenChildrenIdMap[givenCollisionId]!,
            orderId: givenChildOrderId2,
            localPosition: givenChildLocalPosition2,
          ),
          isTrue);

      expect(
          actualOldIndexList,
          equals([
            givenDragOrderId,
            givenChildOrderId,
            givenChildOrderId2,
          ]));
      expect(
          actualNewIndexList,
          equals([
            givenChildOrderId,
            givenChildOrderId2,
            givenCollisionOrderId,
          ]));
    });
    test(
        'GIVEN 4 children and first and last child in orderId changes position '
        'but second and third child is in lockedChildren '
        'WHEN calling #handleMultipleCollisionsForward '
        'THEN should swap only positions of dragged and collisioned item', () {
      // given
      // sorted by orderId
      const givenDragId = 1;
      const givenDragOrderId = 0;
      const givenDragLocalPosition = Offset(2, 2);

      const givenChildId = 3;
      const givenChildOrderId = 1;
      const givenChildLocalPosition = Offset(5, 5);

      const givenChildId2 = 2;
      const givenChildOrderId2 = 2;
      const givenChildLocalPosition2 = Offset(7, 7);

      const givenCollisionId = 0;
      const givenCollisionOrderId = 3;
      const givenCollisionLocalPosition = Offset(3, 3);

      // sorted by id
      final givenDragChild = builder.getGridItemEntity(
        orderId: givenDragOrderId,
        localPosition: givenDragLocalPosition,
      );
      final givenChild = builder.getGridItemEntity(
        orderId: givenChildOrderId,
        localPosition: givenChildLocalPosition,
      );
      final givenChild2 = builder.getGridItemEntity(
        orderId: givenChildOrderId2,
        localPosition: givenChildLocalPosition2,
      );
      final givenCollisionChild = builder.getGridItemEntity(
        orderId: givenCollisionOrderId,
        localPosition: givenCollisionLocalPosition,
      );
      final givenChildrenIdMap = {
        givenDragId: givenDragChild,
        givenChildId2: givenChild2,
        givenCollisionId: givenCollisionChild,
        givenChildId: givenChild,
      };

      List<int> actualOldIndexList = <int>[];
      List<int> actualNewIndexList = <int>[];

      // when
      handleMultipleCollisionsForward(
        dragOrderId: givenDragOrderId,
        collisionOrderId: givenCollisionOrderId,
        childrenIdMap: givenChildrenIdMap,
        lockedChildren: [givenChildOrderId, givenChildOrderId2],
        onReorder: (oldIndex, newIndex) {
          actualOldIndexList.add(oldIndex);
          actualNewIndexList.add(newIndex);
        },
      );

      // then
      // dragChild -> collisionChild
      expect(
          hasGridItemEntityValues(
            givenChildrenIdMap[givenDragId]!,
            orderId: givenCollisionOrderId,
            localPosition: givenCollisionLocalPosition,
          ),
          isTrue);

      // child should not change because locked
      expect(
          hasGridItemEntityValues(
            givenChildrenIdMap[givenChildId]!,
            orderId: givenChildOrderId,
            localPosition: givenChildLocalPosition,
          ),
          isTrue);

      // child2 should not change because locked
      expect(
          hasGridItemEntityValues(
            givenChildrenIdMap[givenChildId2]!,
            orderId: givenChildOrderId2,
            localPosition: givenChildLocalPosition2,
          ),
          isTrue);

      // collisionChild -> child
      expect(
          hasGridItemEntityValues(
            givenChildrenIdMap[givenCollisionId]!,
            orderId: givenDragOrderId,
            localPosition: givenDragLocalPosition,
          ),
          isTrue);
      expect(actualOldIndexList, equals([givenDragOrderId]));
      expect(actualNewIndexList, equals([givenCollisionOrderId]));
    });
  });
}

bool hasGridItemEntityValues(
  GridItemEntity item, {
  required int orderId,
  required Offset localPosition,
}) {
  return item.orderId == orderId && item.localPosition == localPosition;
}
