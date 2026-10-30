import 'package:flutter/widgets.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_animation_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const givenDuration = Duration(milliseconds: 123);
  const givenDefaultCurve = Curves.easeInCubic;
  const givenCurve = Curves.bounceInOut;
  Widget givenBuilder(Widget child, Animation<double> animation) => child;

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

  group('#positionChangeCurve', () {
    test(
        'GIVEN positionChangeCurve and default curve is set '
        'WHEN getting value '
        'THEN should return given curve', () {
      // given
      const config = ReorderableAnimationConfig(
        positionChangeCurve: givenCurve,
        defaultAnimationCurve: givenDefaultCurve,
      );

      // when
      final actual = config.positionChangeCurve;

      // then
      expect(actual, equals(givenCurve));
    });

    test(
        'GIVEN positionChangeCurve is not set and default curve is set '
        'WHEN getting value '
        'THEN should return default curve', () {
      // given
      const config = ReorderableAnimationConfig(
        positionChangeCurve: null,
        defaultAnimationCurve: givenDefaultCurve,
      );

      // when
      final actual = config.positionChangeCurve;

      // then
      expect(actual, equals(givenDefaultCurve));
    });
  });

  group('#draggingPositionChangeCurve', () {
    test(
        'GIVEN draggingPositionChangeCurve and default curve is set '
        'WHEN getting value '
        'THEN should return given curve', () {
      // given
      const config = ReorderableAnimationConfig(
        draggingPositionChangeCurve: givenCurve,
        defaultAnimationCurve: givenDefaultCurve,
      );

      // when
      final actual = config.draggingPositionChangeCurve;

      // then
      expect(actual, equals(givenCurve));
    });

    test(
        'GIVEN draggingPositionChangeCurve is not set and default curve is set '
        'WHEN getting value '
        'THEN should return default curve', () {
      // given
      const config = ReorderableAnimationConfig(
        draggingPositionChangeCurve: null,
        defaultAnimationCurve: givenDefaultCurve,
      );

      // when
      final actual = config.draggingPositionChangeCurve;

      // then
      expect(actual, equals(givenDefaultCurve));
    });
  });

  group('#releasedItemCurve', () {
    test(
        'GIVEN releasedItemCurve and default curve is set '
        'WHEN getting value '
        'THEN should return given curve', () {
      // given
      const config = ReorderableAnimationConfig(
        releasedItemCurve: givenCurve,
        defaultAnimationCurve: givenDefaultCurve,
      );

      // when
      final actual = config.releasedItemCurve;

      // then
      expect(actual, equals(givenCurve));
    });

    test(
        'GIVEN releasedItemCurve is not set and default curve is set '
        'WHEN getting value '
        'THEN should return default curve', () {
      // given
      const config = ReorderableAnimationConfig(
        releasedItemCurve: null,
        defaultAnimationCurve: givenDefaultCurve,
      );

      // when
      final actual = config.releasedItemCurve;

      // then
      expect(actual, equals(givenDefaultCurve));
    });
  });

  group('#fadeInCurve', () {
    test(
        'GIVEN fadeInCurve and default curve is set '
        'WHEN getting value '
        'THEN should return given curve', () {
      // given
      const config = ReorderableAnimationConfig(
        fadeInCurve: givenCurve,
        defaultAnimationCurve: givenDefaultCurve,
      );

      // when
      final actual = config.fadeInCurve;

      // then
      expect(actual, equals(givenCurve));
    });

    test(
        'GIVEN fadeInCurve is not set and default curve is set '
        'WHEN getting value '
        'THEN should return default curve', () {
      // given
      const config = ReorderableAnimationConfig(
        fadeInCurve: null,
        defaultAnimationCurve: givenDefaultCurve,
      );

      // when
      final actual = config.fadeInCurve;

      // then
      expect(actual, equals(givenDefaultCurve));
    });
  });

  group('#fadeOutDuration', () {
    const givenDuration = Duration(milliseconds: 567);

    test(
        'GIVEN enableAnimations true '
        'WHEN getting value '
        'THEN should return configured duration', () {
      // given
      const config = ReorderableAnimationConfig(
        enableAnimations: true,
        fadeOutDuration: givenDuration,
      );

      // when
      final actual = config.fadeOutDuration;

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
        fadeOutDuration: Duration(milliseconds: 567),
      );

      // when
      final actual = config.fadeOutDuration;

      // then
      expect(actual, equals(Duration.zero));
    });
  });

  group('#fadeOutCurve', () {
    test(
        'GIVEN fadeOutCurve and default curve is set '
        'WHEN getting value '
        'THEN should return given curve', () {
      // given
      const config = ReorderableAnimationConfig(
        fadeOutCurve: givenCurve,
        defaultAnimationCurve: givenDefaultCurve,
      );

      // when
      final actual = config.fadeOutCurve;

      // then
      expect(actual, equals(givenCurve));
    });

    test(
        'GIVEN fadeOutCurve is not set and default curve is set '
        'WHEN getting value '
        'THEN should return default curve', () {
      // given
      const config = ReorderableAnimationConfig(
        fadeOutCurve: null,
        defaultAnimationCurve: givenDefaultCurve,
      );

      // when
      final actual = config.fadeOutCurve;

      // then
      expect(actual, equals(givenDefaultCurve));
    });
  });

  group('#dragFeedbackCurve', () {
    test(
        'GIVEN dragFeedbackCurve and default curve is set '
        'WHEN getting value '
        'THEN should return given curve', () {
      // given
      const config = ReorderableAnimationConfig(
        dragFeedbackCurve: givenCurve,
        defaultAnimationCurve: givenDefaultCurve,
      );

      // when
      final actual = config.dragFeedbackCurve;

      // then
      expect(actual, equals(givenCurve));
    });

    test(
        'GIVEN dragFeedbackCurve is not set and default curve is set '
        'WHEN getting value '
        'THEN should return default curve', () {
      // given
      const config = ReorderableAnimationConfig(
        dragFeedbackCurve: null,
        defaultAnimationCurve: givenDefaultCurve,
      );

      // when
      final actual = config.dragFeedbackCurve;

      // then
      expect(actual, equals(givenDefaultCurve));
    });
  });

  group('#changePositionAfterFadeOut', () {
    test(
        'GIVEN nothing '
        'WHEN getting value '
        'THEN should return default value', () {
      // given
      const config = ReorderableAnimationConfig();

      // when
      final actual = config.changePositionAfterFadeOut;

      // then
      expect(actual, isFalse);
    });
  });

  group('#insert', () {
    test(
        'GIVEN insert without curve, default curve and enableAnimations = false '
        'WHEN getting insert '
        'THEN should return Duration.zero, default curve and given builder',
        () {
      // given
      final config = ReorderableAnimationConfig(
        insert: ReorderableItemTransition(
          duration: givenDuration,
          builder: givenBuilder,
        ),
        // ignore: deprecated_member_use_from_same_package
        fadeInDuration: Duration(milliseconds: 999),
        defaultAnimationCurve: givenDefaultCurve,
        enableAnimations: false,
      );

      // when
      final actual = config.insert;

      // then
      expect(actual.duration, equals(Duration.zero));
      expect(actual.curve, equals(givenDefaultCurve));
      expect(actual.builder, equals(givenBuilder));
    });

    test(
        'GIVEN no insert but deprecated fadeInDuration and fadeInCurve '
        'WHEN getting insert '
        'THEN should return deprecated values without builder', () {
      // given
      const config = ReorderableAnimationConfig(
        // ignore: deprecated_member_use_from_same_package
        fadeInDuration: givenDuration,
        // ignore: deprecated_member_use_from_same_package
        fadeInCurve: givenCurve,
        defaultAnimationCurve: givenDefaultCurve,
      );

      // when
      final actual = config.insert;

      // then
      expect(actual.duration, equals(givenDuration));
      expect(actual.curve, equals(givenCurve));
      expect(actual.builder, isNull);
    });
  });

  group('#remove', () {
    test(
        'GIVEN remove without curve, default curve and enableAnimations = false '
        'WHEN getting remove '
        'THEN should return Duration.zero, default curve and given builder',
        () {
      // given
      final config = ReorderableAnimationConfig(
        remove: ReorderableItemTransition(
          duration: givenDuration,
          builder: givenBuilder,
        ),
        // ignore: deprecated_member_use_from_same_package
        fadeOutDuration: Duration(milliseconds: 999),
        defaultAnimationCurve: givenDefaultCurve,
        enableAnimations: false,
      );

      // when
      final actual = config.remove;

      // then
      expect(actual.duration, equals(Duration.zero));
      expect(actual.curve, equals(givenDefaultCurve));
      expect(actual.builder, equals(givenBuilder));
    });

    test(
        'GIVEN no remove but deprecated fadeOutDuration and fadeOutCurve '
        'WHEN getting remove '
        'THEN should return deprecated values without builder', () {
      // given
      const config = ReorderableAnimationConfig(
        // ignore: deprecated_member_use_from_same_package
        fadeOutDuration: givenDuration,
        // ignore: deprecated_member_use_from_same_package
        fadeOutCurve: givenCurve,
        defaultAnimationCurve: givenDefaultCurve,
      );

      // when
      final actual = config.remove;

      // then
      expect(actual.duration, equals(givenDuration));
      expect(actual.curve, equals(givenCurve));
      expect(actual.builder, isNull);
    });
  });

  group('#dragFeedback', () {
    test(
        'GIVEN dragFeedback without curve, default curve and enableAnimations = false '
        'WHEN getting dragFeedback '
        'THEN should return Duration.zero, default curve and given builder',
        () {
      // given
      final config = ReorderableAnimationConfig(
        dragFeedback: ReorderableItemTransition(
          duration: givenDuration,
          builder: givenBuilder,
        ),
        // ignore: deprecated_member_use_from_same_package
        dragFeedbackDuration: Duration(milliseconds: 999),
        defaultAnimationCurve: givenDefaultCurve,
        enableAnimations: false,
      );

      // when
      final actual = config.dragFeedback;

      // then
      expect(actual.duration, equals(Duration.zero));
      expect(actual.curve, equals(givenDefaultCurve));
      expect(actual.builder, equals(givenBuilder));
    });

    test(
        'GIVEN no dragFeedback but deprecated dragFeedbackDuration and dragFeedbackCurve '
        'WHEN getting dragFeedback '
        'THEN should return deprecated values without builder', () {
      // given
      const config = ReorderableAnimationConfig(
        // ignore: deprecated_member_use_from_same_package
        dragFeedbackDuration: givenDuration,
        // ignore: deprecated_member_use_from_same_package
        dragFeedbackCurve: givenCurve,
        defaultAnimationCurve: givenDefaultCurve,
      );

      // when
      final actual = config.dragFeedback;

      // then
      expect(actual.duration, equals(givenDuration));
      expect(actual.curve, equals(givenCurve));
      expect(actual.builder, isNull);
    });
  });
}
