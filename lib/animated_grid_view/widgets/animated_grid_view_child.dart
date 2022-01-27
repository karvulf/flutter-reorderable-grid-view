import 'package:flutter/cupertino.dart';
import 'package:flutter_reorderable_grid_view/animated_grid_view/entities/animated_grid_view_entity.dart';

typedef OnCreatedFunction = AnimatedGridViewEntity? Function(
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

  Offset _delegateOffset = Offset.zero;

  bool isCreated = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      final gridViewEntity = widget.onCreated(
        widget.animatedGridViewEntity,
        _globalKey,
      );
      if (gridViewEntity != null) {
        setState(() {
          _delegateOffset = _getDelegateOffset(gridViewEntity);
          isCreated = true;
        });
      }
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
      transform: Matrix4.translationValues(
        widget.animatedGridViewEntity.updatedOrderId == 1 ? 20 : 0,
        0,
        0,
      ),
      child: CustomSingleChildLayout(
        delegate: AnimatedGridViewSingleChildLayoutDelegate(
          offset: _delegateOffset,
        ),
        child: widget.animatedGridViewEntity.child,
      ),
    );
  }

  Offset _getDelegateOffset(AnimatedGridViewEntity animatedGridViewEntity) {
    final key = animatedGridViewEntity.child.key;
    final originalOffset = animatedGridViewEntity.originalOffset;
    final updatedOffset = animatedGridViewEntity.updatedOffset;
    final difference = originalOffset - updatedOffset;
    print('**** key $key with diff $difference ****');
    return difference;
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
