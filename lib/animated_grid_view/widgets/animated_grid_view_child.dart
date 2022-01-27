import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/animated_grid_view/entities/animated_grid_view_entity.dart';

typedef OnCreatedFunction = void Function(
  AnimatedGridViewEntity animatedGridViewEntity,
  GlobalKey key,
);

class AnimatedGridViewChild extends StatefulWidget {
  final AnimatedGridViewEntity animatedGridViewEntity;

  final OnCreatedFunction onCreated;

  const AnimatedGridViewChild({
    required this.animatedGridViewEntity,
    required this.onCreated,
    Key? key,
  }) : super(key: key);

  @override
  State<AnimatedGridViewChild> createState() => _AnimatedGridViewChildState();
}

class _AnimatedGridViewChildState extends State<AnimatedGridViewChild>
    with SingleTickerProviderStateMixin {
  final _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      widget.onCreated(widget.animatedGridViewEntity, _globalKey);
    });
  }

  @override
  void didUpdateWidget(covariant AnimatedGridViewChild oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldUpdatedOrderId = oldWidget.animatedGridViewEntity.updatedOrderId;
    final newUpdatedOrderId = widget.animatedGridViewEntity.updatedOrderId;
    if (oldUpdatedOrderId != newUpdatedOrderId) {
      final originalOffset = widget.animatedGridViewEntity.originalOffset;
      final newUpdatedOffset = widget.animatedGridViewEntity.updatedOffset;
      print(
          'Original offset originalOffset $originalOffset, Update in offset $newUpdatedOffset for child ${widget.animatedGridViewEntity.child.key}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _globalKey,
      child: CustomSingleChildLayout(
        delegate: AnimatedGridViewSingleChildLayoutDelegate(
          offset: _getDelegateOffset(),
        ),
        child: widget.animatedGridViewEntity.child,
      ),
    );
  }

  Offset _getDelegateOffset() {
    final gridViewEntity = widget.animatedGridViewEntity;
    final key = gridViewEntity.child.key;
    final difference =
        gridViewEntity.originalOffset - gridViewEntity.updatedOffset;
    // print('**** key $key with diff $difference ****');
    return Offset(
      0,
      0,
    );
  }
}

class AnimatedGridViewSingleChildLayoutDelegate
    extends SingleChildLayoutDelegate {
  final Offset offset;

  AnimatedGridViewSingleChildLayoutDelegate({required this.offset});

  @override
  bool shouldRelayout(
      covariant AnimatedGridViewSingleChildLayoutDelegate oldDelegate) {
    return true; // oldDelegate.offset != offset;
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return offset;
  }
}
