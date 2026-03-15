import 'package:flutter_reorderable_grid_view/entities/reorderable_animation_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const givenDuration = Duration(milliseconds: 123);

  group('ReorderableAnimationConfig', () {
    test(
        'GIVEN no params '
        'WHEN creating config '
        'THEN should have givenDuration default values', () {
      // given

      // when
      const actual = ReorderableAnimationConfig();

      // then
      expect(actual.enableAnimations, isTrue);
      expect(
        actual.positionChangeDuration,
        equals(const Duration(milliseconds: 200)),
      );
      expect(
        actual.draggingPositionChangeDuration,
        equals(const Duration(milliseconds: 200)),
      );
      expect(
        actual.releasedItemDuration,
        equals(const Duration(milliseconds: 150)),
      );
      expect(actual.fadeInDuration, equals(const Duration(milliseconds: 500)));
      expect(
        actual.dragFeedbackDuration,
        equals(const Duration(milliseconds: 150)),
      );
    });

    group('#positionChangeDuration', () {
      test(
          'GIVEN enableAnimations true '
          'WHEN getting value '
          'THEN should return configured duration', () {
        // given
        const config = ReorderableAnimationConfig(
          enableAnimations: true,
          positionChangeDuration: givenDuration,
        );

        // when
        final actual = config.positionChangeDuration;

        // then
        expect(actual, equals(givenDuration));
      });

      test(
          'GIVEN enableAnimations false '
          'WHEN getting value '
          'THEN should return Duration.zero', () {
        // given
        const config = ReorderableAnimationConfig(
          enableAnimations: false,
          positionChangeDuration: Duration(milliseconds: 123),
        );

        // when
        final actual = config.positionChangeDuration;

        // then
        expect(actual, equals(Duration.zero));
      });
    });

    group('#draggingPositionChangeDuration', () {
      test(
          'GIVEN enableAnimations true '
          'WHEN getting value '
          'THEN should return configured duration', () {
        // given
        const config = ReorderableAnimationConfig(
          enableAnimations: true,
          draggingPositionChangeDuration: givenDuration,
        );

        // when
        final actual = config.draggingPositionChangeDuration;

        // then
        expect(actual, equals(givenDuration));
      });

      test(
          'GIVEN enableAnimations false '
          'WHEN getting value '
          'THEN should return Duration.zero', () {
        // given
        const config = ReorderableAnimationConfig(
          enableAnimations: false,
          draggingPositionChangeDuration: Duration(milliseconds: 234),
        );

        // when
        final actual = config.draggingPositionChangeDuration;

        // then
        expect(actual, equals(Duration.zero));
      });
    });

    group('#releasedItemDuration', () {
      test(
          'GIVEN enableAnimations true '
          'WHEN getting value '
          'THEN should return configured duration', () {
        // given
        const givenDuration = Duration(milliseconds: 345);
        const config = ReorderableAnimationConfig(
          enableAnimations: true,
          releasedItemDuration: givenDuration,
        );

        // when
        final actual = config.releasedItemDuration;

        // then
        expect(actual, equals(givenDuration));
      });

      test(
          'GIVEN enableAnimations false '
          'WHEN getting value '
          'THEN should return Duration.zero', () {
        // given
        const config = ReorderableAnimationConfig(
          enableAnimations: false,
          releasedItemDuration: Duration(milliseconds: 345),
        );

        // when
        final actual = config.releasedItemDuration;

        // then
        expect(actual, equals(Duration.zero));
      });
    });

    group('#fadeInDuration', () {
      test(
          'GIVEN enableAnimations true '
          'WHEN getting value '
          'THEN should return configured duration', () {
        // given
        const givenDuration = Duration(milliseconds: 456);
        const config = ReorderableAnimationConfig(
          enableAnimations: true,
          fadeInDuration: givenDuration,
        );

        // when
        final actual = config.fadeInDuration;

        // then
        expect(actual, equals(givenDuration));
      });

      test(
          'GIVEN enableAnimations false '
          'WHEN getting value '
          'THEN should return Duration.zero', () {
        // given
        const config = ReorderableAnimationConfig(
          enableAnimations: false,
          fadeInDuration: Duration(milliseconds: 456),
        );

        // when
        final actual = config.fadeInDuration;

        // then
        expect(actual, equals(Duration.zero));
      });
    });

    group('#dragFeedbackDuration', () {
      test(
          'GIVEN enableAnimations true '
          'WHEN getting value '
          'THEN should return configured duration', () {
        // given
        const givenDuration = Duration(milliseconds: 567);
        const config = ReorderableAnimationConfig(
          enableAnimations: true,
          dragFeedbackDuration: givenDuration,
        );

        // when
        final actual = config.dragFeedbackDuration;

        // then
        expect(actual, equals(givenDuration));
      });

      test(
          'GIVEN enableAnimations false '
          'WHEN getting value '
          'THEN should return Duration.zero', () {
        // given
        const config = ReorderableAnimationConfig(
          enableAnimations: false,
          dragFeedbackDuration: Duration(milliseconds: 567),
        );

        // when
        final actual = config.dragFeedbackDuration;

        // then
        expect(actual, equals(Duration.zero));
      });
    });
  });
}
