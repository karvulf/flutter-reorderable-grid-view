import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeScrollController extends Fake implements ScrollController {
  final Axis _axis;
  final double _offset;
  final double _maxScrollExtent;
  double? _jumpToValue;

  FakeScrollController({
    Axis? axis,
    double? offset,
    double? maxScrollExtent,
  })  : _axis = axis ?? Axis.horizontal,
        _offset = offset ?? 0.0,
        _maxScrollExtent = maxScrollExtent ?? 1.0;

  @override
  ScrollPosition get position => FakeScrollPosition(
        axis: _axis,
        maxScrollExtent: _maxScrollExtent,
      );

  @override
  double get offset => _offset;

  @override
  void jumpTo(double value) {
    _jumpToValue = value;
  }

  void verifyJumpTo(double expectedValue) {
    expect(_jumpToValue, equals(expectedValue));
  }
}

class FakeScrollPosition extends Fake implements ScrollPosition {
  final Axis _axis;
  final double _maxScrollExtent;

  FakeScrollPosition({
    required Axis axis,
    required double maxScrollExtent,
  })  : _axis = axis,
        _maxScrollExtent = maxScrollExtent;

  @override
  Axis get axis => _axis;

  @override
  double get maxScrollExtent => _maxScrollExtent;
}
