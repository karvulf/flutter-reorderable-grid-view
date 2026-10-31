import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Calculates the offsets of children with [sizes] like a [Wrap] would do.
///
/// Only used for [ReorderableBuilder.wrap] to know the positions of the
/// children while dragging. The offsets are relative to the top left of the
/// [Wrap] and in the same order as [sizes].
///
/// Supports the default [Wrap] layout: horizontal direction, left to right,
/// top to bottom and every alignment set to start.
// ponytail: only the default Wrap layout, add other alignments and
// directions when ReorderableBuilder.wrap supports them
List<Offset> calculateWrapOffsets({
  required List<Size> sizes,
  required double maxWidth,
  required double spacing,
  required double runSpacing,
}) {
  final offsets = <Offset>[];
  var childrenInRun = 0;
  var runWidth = 0.0;
  var runHeight = 0.0;
  var runTop = 0.0;

  for (final size in sizes) {
    // same check as RenderWrap to start a new run
    final needsNewRun = childrenInRun > 0 &&
        runWidth + size.width + spacing - maxWidth > precisionErrorTolerance;

    if (needsNewRun) {
      runTop += runHeight + runSpacing;
      childrenInRun = 0;
      runWidth = 0.0;
      runHeight = 0.0;
    }

    final left = childrenInRun == 0 ? 0.0 : runWidth + spacing;
    offsets.add(Offset(left, runTop));
    childrenInRun++;
    runWidth = left + size.width;
    runHeight = runHeight > size.height ? runHeight : size.height;
  }

  return offsets;
}
