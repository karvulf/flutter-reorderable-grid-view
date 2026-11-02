import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view_example/examples/page_view/page_view_grid.dart';

/// A reorderable grid on every page of a [PageView].
class PageViewExample extends StatelessWidget {
  const PageViewExample({super.key});

  @override
  Widget build(BuildContext context) => PageView.builder(
        itemCount: 3,
        itemBuilder: (context, index) =>
            PageViewGrid(color: Colors.primaries[index]),
      );
}
